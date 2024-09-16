# Copyright (c) 2023 Boston Dynamics, Inc.  All rights reserved.
#
# Downloading, reproducing, distributing or otherwise using the SDK Software
# is subject to the terms and conditions of the Boston Dynamics Software
# Development Kit License (20191101-BDSDK-SL).

"""Tutorial to show how to use Spot's arm.
"""
import logging
import argparse
import math
import signal
import sys
import threading
import time
import os
import subprocess

import cv2
import numpy as np
from PIL import Image

import bosdyn.client
import bosdyn.client.lease
import bosdyn.client.util
from bosdyn import geometry
from bosdyn.api import geometry_pb2, image_pb2, trajectory_pb2, world_object_pb2
from bosdyn.api.spot import robot_command_pb2 as spot_command_pb2
from bosdyn.api.geometry_pb2 import SE2Velocity, SE2VelocityLimit, Vec2
from bosdyn.client import math_helpers, ResponseError, RpcError, create_standard_sdk
from bosdyn.client.frame_helpers import (BODY_FRAME_NAME, VISION_FRAME_NAME, 
                                         GRAV_ALIGNED_BODY_FRAME_NAME, ODOM_FRAME_NAME,get_a_tform_b,
                                         get_vision_tform_body)
from bosdyn.client.robot_command import (RobotCommandBuilder, RobotCommandClient,
                                         block_until_arm_arrives, blocking_stand)
from bosdyn.client.robot_state import RobotStateClient
from bosdyn.client.math_helpers import Quat, SE3Pose
from bosdyn.client.lease import LeaseClient
from bosdyn.client.lease import Error as LeaseBaseError
from bosdyn.client.robot_id import RobotIdClient, version_tuple
from bosdyn.client.power import PowerClient
from bosdyn.client.image import ImageClient, build_image_request
from bosdyn.client.world_object import WorldObjectClient

##pylint: disable=no-member
LOGGER = logging.getLogger()

# Use this length to make sure we're commanding the head of the robot
# to a position instead of the center.
BODY_LENGTH = 1.1


class ArmWithBodyFollow(object):
    """ Detect and track fiducial with gripper. """

    def __init__(self, robot, options):
        # Robot instance variable
        self._robot = robot
        self._robot_id = robot.ensure_client(RobotIdClient.default_service_name).get_id(timeout=0.4)
        self._power_client = robot.ensure_client(PowerClient.default_service_name)
        self._image_client = robot.ensure_client(ImageClient.default_service_name)
        self._robot_state_client = robot.ensure_client(RobotStateClient.default_service_name)
        self._robot_command_client = robot.ensure_client(RobotCommandClient.default_service_name)
        self._world_object_client = robot.ensure_client(WorldObjectClient.default_service_name)
        self._lock = threading.Lock()
        
        # Stopping Distance (x,y) offset from the tag and angle offset from desired angle.
        self._tag_offset = 0.2  # meters

        # Maximum speeds.
        self._max_x_vel = 0.5
        self._max_y_vel = 0.5
        self._max_ang_vel = 1.0

        # Indicator if fiducial detection's should be from the world object service using
        # spot's perception system or detected with the apriltag library. If the software version
        # does not include the world object service, than default to april tag library.
        self._use_world_object_service = (options.use_world_objects and
                                          self.check_if_version_has_world_objects(self._robot_id))
        
        # Indicators for movement and image displays.
        self._standup = True  # Stand up the robot.
        self._movement_on = True  # Let the robot walk towards the fiducial.
        self._limit_speed = options.limit_speed  # Limit the robot's walking speed.
        self._avoid_obstacles = options.avoid_obstacles  # Disable obstacle avoidance.

        # Epsilon distance between robot and desired go-to point.
        self._x_eps = .05
        self._y_eps = .05
        self._angle_eps = .075

        # Indicator for if motor power is on.
        self._powered_on = False

        # Counter for the number of iterations completed.
        self._attempts = 0

        # Maximum amount of iterations before powering off the motors.
        self._max_attempts = 100000

        # Camera intrinsics for the current camera source being analyzed.
        self._intrinsics = None

        # Transform from the robot's camera frame to the baselink frame.
        # It is a math_helpers.SE3Pose.
        self._camera_tform_body = None

        # Transform from the robot's baselink to the world frame.
        # It is a math_helpers.SE3Pose.
        self._body_tform_world = None

        # Latest detected fiducial's position in the world.
        self._current_tag_world_pose = np.array([])

        # Heading angle based on the camera source which detected the fiducial.
        self._angle_desired = None

        # Dictionary mapping camera source to it's latest image taken.
        self._image = dict()

        # List of all possible camera sources.
        self._source_names = [
            src.name for src in self._image_client.list_image_sources() if
            (src.image_type == image_pb2.ImageSource.IMAGE_TYPE_VISUAL and 'depth' not in src.name)
        ]
        #print(self._source_names)

        # Dictionary mapping camera source to previously computed extrinsics.
        self._camera_to_extrinsics_guess = self.populate_source_dict()

        # Camera source which a bounding box was last detected in.
        self._previous_source = None

    @property
    def robot_state(self):
        """Get latest robot state proto."""
        return self._robot_state_client.get_robot_state()

    @property
    def image(self):
        """Return the current image associated with each source name."""
        return self._image

    @property
    def image_sources_list(self):
        """Return the list of camera sources."""
        return self._source_names

    def populate_source_dict(self):
        """Fills dictionary of the most recently computed camera extrinsics with the camera source.
           The initial boolean indicates if the extrinsics guess should be used."""
        camera_to_extrinsics_guess = dict()
        for src in self._source_names:
            # Dictionary values: use_extrinsics_guess bool, (rotation vector, translation vector) tuple.
            camera_to_extrinsics_guess[src] = (False, (None, None))
        return camera_to_extrinsics_guess

    def check_if_version_has_world_objects(self, robot_id):
        """Check that software version contains world object service."""
        # World object service was released in spot-sdk version 1.2.0
        return version_tuple(robot_id.software_release.version) >= (1, 2, 0)


    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    def start(self):
        """A simple example that moves the arm and asks the body to move to a good position based
        on the arm's location."""
        self._robot.time_sync.wait_for_sync()

        robot_state_client = self._robot.ensure_client(RobotStateClient.default_service_name)

        lease_client = self._robot.ensure_client(bosdyn.client.lease.LeaseClient.default_service_name)
        with bosdyn.client.lease.LeaseKeepAlive(lease_client, must_acquire=True, return_at_exit=True):
            # Now, we are ready to power on the robot. This call will block until the power
            # is on. Commands would fail if this did not happen. We can also check that the robot is
            # powered at any point.
            self._robot.logger.info('Powering on robot... This may take a several seconds.')
            self._robot.power_on(timeout_sec=20)
            assert self._robot.is_powered_on(), 'Robot power on failed.'
            self._robot.logger.info('Robot powered on.')

            # Puts Spot into a sitting position to ready the stand
            self._robot.logger.info('Positioning feet to sit...')
            self._start_robot_command('sit', RobotCommandBuilder.synchro_sit_command())
            time.sleep(2.5)

            # Tell the robot to stand up. The command service is used to issue commands to a robot.
            # The set of valid commands for a robot depends on hardware configuration. See
            # RobotCommandBuilder for more detailed examples on command building. The robot
            # command service requires timesync between the robot and the client.
            self._robot.logger.info('Commanding robot to stand...')
            command_client = self._robot.ensure_client(RobotCommandClient.default_service_name)
            blocking_stand(command_client, timeout_sec=10)
            self._robot.logger.info('Robot standing.')

            # Move the arm to a spot in front of the robot, and command the body to follow the hand.
            # Build a position to move the arm to (in meters, relative to the body frame origin.)
            x = 0.78
            y = 0.0
            z = 0.6
            hand_pos_rt_body = geometry_pb2.Vec3(x=x, y=y, z=z)

            # Rotation as a quaternion.
            qw = 1
            qx = 0
            qy = 0
            qz = 0
            body_Q_hand = geometry_pb2.Quaternion(w=qw, x=qx, y=qy, z=qz)

            # Build the SE(3) pose of the desired hand position in the moving body frame.
            body_T_hand = geometry_pb2.SE3Pose(position=hand_pos_rt_body, rotation=body_Q_hand)

            # Transform the desired from the moving body frame to the odom frame.
            robot_state = robot_state_client.get_robot_state()
            odom_T_body = get_a_tform_b(robot_state.kinematic_state.transforms_snapshot,
                                        ODOM_FRAME_NAME, GRAV_ALIGNED_BODY_FRAME_NAME)
            odom_T_hand = odom_T_body * math_helpers.SE3Pose.from_proto(body_T_hand)

            # duration in seconds
            seconds = 5

            # Create the arm command.
            arm_command = RobotCommandBuilder.arm_pose_command(
                odom_T_hand.x, odom_T_hand.y, odom_T_hand.z, odom_T_hand.rot.w, odom_T_hand.rot.x,
                odom_T_hand.rot.y, odom_T_hand.rot.z, ODOM_FRAME_NAME, seconds)

            # Tell the robot's body to follow the arm
            follow_arm_command = RobotCommandBuilder.follow_arm_command()

            # Combine the arm and mobility commands into one synchronized command.
            command = RobotCommandBuilder.build_synchro_command(follow_arm_command, arm_command)

            # Send the request
            move_command_id = command_client.robot_command(command)
            self._robot.logger.info('Moving arm to initial position.')

            block_until_arm_arrives(command_client, move_command_id, 6.0)

            # ++++++++++++++++++++++++++++++++++++++++++++++++++
            # Send to custom function to move to fiducial
            self.track_fiducial_with_gripper(command_client)
            # ++++++++++++++++++++++++++++++++++++++++++++++++++

            # Power the robot off. By specifying "cut_immediately=False", a safe power off command
            # is issued to the robot. This will attempt to sit the robot before powering off.
            self._robot.power_off(cut_immediately=False, timeout_sec=20)
            assert not self._robot.is_powered_on(), 'Robot power off failed.'
            self._robot.logger.info('Robot safely powered off.')


    # =====================================================================================================
    def _start_robot_command(self, desc, command_proto, end_time_secs=None):

        def _start_command():
            self._robot_command_client.robot_command(command=command_proto,
                                                     end_time_secs=end_time_secs)

        self._try_grpc(desc, _start_command)

    def _try_grpc(self, desc, thunk):
        try:
            return thunk()
        except (ResponseError, RpcError, LeaseBaseError) as err:
            self.add_message(f'Failed {desc}: {err}')
            return None
        
    def add_message(self, msg_text):
        """Display the given message string to the user in the curses interface."""
        with self._lock:
            self._locked_messages = [msg_text] + self._locked_messages[:-1]
    
    def track_fiducial_with_gripper(self, command_client):
        """Custom section of code by SPM to track an AR marker with the gripper.
        Intended for use on the NERVE Treadmill for experimental purposes only."""
        
        # Starts recording script:
        home = os.path.expanduser("~")
        #argument = 'python3 '+home+'/spot-sdk/python/examples/custom_code/record_spot_data.py 192.168.80.3'
        #print(argument)
        #subprocess.run(argument)
        subprocess.Popen(['python3', 'record_spot_data.py', '192.168.80.3'])
        #os.system('python3 record_spot_data.py 192.168.80.3')
        
        start_time = time.time()
        end_time = start_time + 60.0    # 60 seconds after starting (trial length)
        current_time = time.time()

        while current_time < end_time:
            # Detect Fiducial location, Move the arm towards marker, and command the body to follow the hand.
            # Build a position to move the arm to (in meters, relative to the body frame origin.)
            object_rt_world = self.detect_fiducial_location(end_time)
            #print('\n Object:  ', object_rt_world)
            offset_rt_world, heading = self.offset_tag_pose(object_rt_world)
            #print('\n Offset:  ', offset_rt_world)

            #hand_pos_rt_body = geometry_pb2.Vec3(
            #    x=offset_rt_world[0], y=offset_rt_world[1], z=object_rt_world.z)
            hand_pos_rt_body = geometry_pb2.Vec3(
                 x=offset_rt_world[0], y=offset_rt_world[1], z=object_rt_world.z+0.15)            

            # Rotation as a quaternion.
            qw = 1
            qx = 0
            qy = 0
            qz = 0
            body_Q_hand = geometry_pb2.Quaternion(w=qw, x=qx, y=qy, z=qz)

            # Build the SE(3) pose of the desired hand position
            body_T_hand = geometry_pb2.SE3Pose(position=hand_pos_rt_body, rotation=body_Q_hand)
            #print('\n SE3Pose:  \n', body_T_hand)

            # Transform the desired from the moving body frame to the odom frame.
            robot_state = self._robot_state_client.get_robot_state()
            """odom_T_body = get_a_tform_b(robot_state.kinematic_state.transforms_snapshot,
                                        ODOM_FRAME_NAME, GRAV_ALIGNED_BODY_FRAME_NAME)"""
            odom_T_body = get_a_tform_b(robot_state.kinematic_state.transforms_snapshot,
                                        ODOM_FRAME_NAME, ODOM_FRAME_NAME)
            odom_T_hand = odom_T_body * math_helpers.SE3Pose.from_proto(body_T_hand)
            #print('\n odom_T_hand:  \n', odom_T_hand)

            # duration in seconds
            duration = 0.010
            # Speed limit :|
            mobility_params = self.set_mobility_params()

            # Create the arm command.
            """arm_command = RobotCommandBuilder.arm_pose_command(
                odom_T_hand.x, odom_T_hand.y, odom_T_hand.z, odom_T_hand.rot.w, odom_T_hand.rot.x,
                odom_T_hand.rot.y, odom_T_hand.rot.z, ODOM_FRAME_NAME, seconds)"""
            arm_command = RobotCommandBuilder.arm_pose_command(
                x=odom_T_hand.x, y=odom_T_hand.y, z=odom_T_hand.z, qw=odom_T_hand.rot.w, 
                qx=odom_T_hand.rot.x, qy=odom_T_hand.rot.y, qz=odom_T_hand.rot.z, 
                frame_name=VISION_FRAME_NAME, seconds=duration)
            """body_command = RobotCommandBuilder.synchro_se2_trajectory_point_command(
                goal_x=offset_rt_world[0], goal_y=offset_rt_world[1],
                goal_heading=heading, frame_name=VISION_FRAME_NAME, params=mobility_params,
                body_height=0.0)"""

            # Tell the robot's body to follow the arm
            follow_arm_command = RobotCommandBuilder.follow_arm_command()

            # Combine the arm and mobility commands into one synchronized command.
            command = RobotCommandBuilder.build_synchro_command(follow_arm_command, arm_command)

            # Send the request
            move_command_id = command_client.robot_command(command)
            block_time = 0.010
            #command_client.robot_command(lease=None, command=command, 
            #                             end_time_secs=time.time() + block_time)

            self._robot.logger.info('Moving arm to Fiducial.')

            block_until_arm_arrives(command_client, move_command_id, block_time)

            time.sleep(0.2)
            current_time = time.time()

        print('\n End Time Reached. Powering Off')
        self._robot.power_off(cut_immediately=False, timeout_sec=20)
        assert not self._robot.is_powered_on(), 'Robot power off failed.'
        self._robot.logger.info('Robot safely powered off.')
    

    def detect_fiducial_location(self, end_time):
        """Uses gripper camera to detect Fiducial and return marker location
        wrt body frame"""
        current_time = time.time()
        while current_time < end_time:
            detected_fiducial = False
            fiducial_rt_world = None
            if self._use_world_object_service:
                # Get the first fiducial object Spot detects with the world object service.
                fiducial = self.get_fiducial_objects()
                if fiducial is not None:
                    vision_tform_fiducial = get_a_tform_b(
                        fiducial.transforms_snapshot, VISION_FRAME_NAME,
                        fiducial.apriltag_properties.frame_name_fiducial).to_proto()
                    if vision_tform_fiducial is not None:
                        detected_fiducial = True
                        fiducial_rt_world = vision_tform_fiducial.position

            current_time = time.time()

            if detected_fiducial:
                # Go to the tag and stop within a certain distance
                print('\n Fiducial Detected.')
                return(fiducial_rt_world)
            
            elif current_time > end_time:
                print('\n No Fiducials found. Powering Off')
                self._robot.power_off(cut_immediately=False, timeout_sec=20)
                assert not self._robot.is_powered_on(), 'Robot power off failed.'
                self._robot.logger.info('Robot safely powered off.')
                
            else:
                print('\n No Fiducials found, trying again.')
    # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


            


    def get_fiducial_objects(self):
        """Get all fiducials that Spot detects with its perception system."""

        # Get all fiducial objects (an object of a specific type).
        request_fiducials = [world_object_pb2.WORLD_OBJECT_APRILTAG]
        fiducial_objects = self._world_object_client.list_world_objects(
            object_type=request_fiducials).world_objects
        if len(fiducial_objects) > 0:
            # Return the first detected fiducial.
            return fiducial_objects[0]
        # Return none if no fiducials are found.
        return None
    
    def offset_tag_pose(self, object_rt_world):
        """Offset the go-to location of the fiducial and compute the desired heading."""

        # Norm xy Distance to stop
        dist_margin = 0.15

        robot_rt_world = get_vision_tform_body(self.robot_state.kinematic_state.transforms_snapshot)
        robot_to_object_ewrt_world = np.array(
            [object_rt_world.x - robot_rt_world.x, object_rt_world.y - robot_rt_world.y, 0])
        robot_to_object_ewrt_world_norm = robot_to_object_ewrt_world / np.linalg.norm(
            robot_to_object_ewrt_world)
        heading = self.get_desired_angle(robot_to_object_ewrt_world_norm)
        goto_rt_world = np.array([
            object_rt_world.x - robot_to_object_ewrt_world_norm[0] * dist_margin,
            object_rt_world.y - robot_to_object_ewrt_world_norm[1] * dist_margin])
        
        # Offset distance of gripper to keep out of way of fiducial
        goto_rt_world[1] = goto_rt_world[1] #- 0.1      
        
        return goto_rt_world, heading
    
    def get_desired_angle(self, xhat):
        """Compute heading based on the vector from robot to object."""
        zhat = [0.0, 0.0, 1.0]
        yhat = np.cross(zhat, xhat)
        mat = np.array([xhat, yhat, zhat]).transpose()
        return Quat.from_matrix(mat).to_yaw()
    
    def image_to_bounding_box(self):
        """Determine which camera source has a fiducial.
           Return the bounding box of the first detected fiducial."""
        #Iterate through all five camera sources to check for a fiducial
        for i in range(len(self._source_names) + 1):
            # Get the image from the source camera.
            if i == 0:
                if self._previous_source != None:
                    # Prioritize the camera the fiducial was last detected in.
                    source_name = self._previous_source
                else:
                    continue
            elif self._source_names[i - 1] == self._previous_source:
                continue
            else:
                source_name = self._source_names[i - 1]

            img_req = build_image_request(source_name, quality_percent=100,
                                          image_format=image_pb2.Image.FORMAT_RAW)
            image_response = self._image_client.get_image([img_req])
            self._camera_tform_body = get_a_tform_b(image_response[0].shot.transforms_snapshot,
                                                    image_response[0].shot.frame_name_image_sensor,
                                                    BODY_FRAME_NAME)
            self._body_tform_world = get_a_tform_b(image_response[0].shot.transforms_snapshot,
                                                   BODY_FRAME_NAME, VISION_FRAME_NAME)

            # Camera intrinsics for the given source camera.
            self._intrinsics = image_response[0].source.pinhole.intrinsics
            width = image_response[0].shot.image.cols
            height = image_response[0].shot.image.rows

            # detect given fiducial in image and return the bounding box of it
            bboxes = self.detect_fiducial_in_image(image_response[0].shot.image, (width, height),
                                                   source_name)
            if bboxes:
                print(f'Found bounding box for {source_name}')
                return bboxes, source_name
            else:
                self._tag_not_located = True
                print(f'Failed to find bounding box for {source_name}')
        return [], None
    
    def detect_fiducial_in_image(self, image, dim, source_name):
        """Detect the fiducial within a single image and return its bounding box."""
        image_grey = np.array(
            Image.frombytes('P', (int(dim[0]), int(dim[1])), data=image.data, decoder_name='raw'))

        #Rotate each image such that it is upright
        image_grey = self.rotate_image(image_grey, source_name)

        #Make the image greyscale to use bounding box detections
        detector = apriltag(family='tag36h11')
        detections = detector.detect(image_grey)

        bboxes = []
        for i in range(len(detections)):
            # Draw the bounding box detection in the image.
            bbox = detections[i]['lb-rb-rt-lt']
            cv2.polylines(image_grey, [np.int32(bbox)], True, (0, 0, 0), 2)
            bboxes.append(bbox)

        self._image[source_name] = image_grey
        return bboxes
    
    def set_mobility_params(self):
        """Set robot mobility params to disable obstacle avoidance."""
        obstacles = spot_command_pb2.ObstacleParams(disable_vision_body_obstacle_avoidance=True,
                                                    disable_vision_foot_obstacle_avoidance=True,
                                                    disable_vision_foot_constraint_avoidance=True,
                                                    obstacle_avoidance_padding=.001)
        body_control = self.set_default_body_control()
        if self._limit_speed:
            speed_limit = SE2VelocityLimit(max_vel=SE2Velocity(
                linear=Vec2(x=self._max_x_vel, y=self._max_y_vel), angular=self._max_ang_vel))
            if not self._avoid_obstacles:
                mobility_params = spot_command_pb2.MobilityParams(
                    obstacle_params=obstacles, vel_limit=speed_limit, body_control=body_control,
                    locomotion_hint=spot_command_pb2.HINT_AUTO)
            else:
                mobility_params = spot_command_pb2.MobilityParams(
                    vel_limit=speed_limit, body_control=body_control,
                    locomotion_hint=spot_command_pb2.HINT_AUTO)
        elif not self._avoid_obstacles:
            mobility_params = spot_command_pb2.MobilityParams(
                obstacle_params=obstacles, body_control=body_control,
                locomotion_hint=spot_command_pb2.HINT_AUTO)
        else:
            #When set to none, RobotCommandBuilder populates with good default values
            mobility_params = None
        return mobility_params
    
    @staticmethod
    def set_default_body_control():
        """Set default body control params to current body position"""
        footprint_R_body = geometry.EulerZXY()
        position = geometry_pb2.Vec3(x=0.0, y=0.0, z=0.0)
        rotation = footprint_R_body.to_quaternion()
        pose = geometry_pb2.SE3Pose(position=position, rotation=rotation)
        point = trajectory_pb2.SE3TrajectoryPoint(pose=pose)
        traj = trajectory_pb2.SE3Trajectory(points=[point])
        return spot_command_pb2.BodyControlParams(base_offset_rt_footprint=traj)


class DisplayImagesAsync(object):
    """Display the images Spot sees from all five cameras."""

    def __init__(self, fiducial_follower):
        self._fiducial_follower = fiducial_follower
        self._thread = None
        self._started = False
        self._sources = []

    def get_image(self):
        """Retrieve current images (with bounding boxes) from the fiducial detector."""
        images = self._fiducial_follower.image
        image_by_source = []
        for s_name in self._sources:
            if s_name in images:
                image_by_source.append(images[s_name])
            else:
                image_by_source.append(np.array([]))
        return image_by_source

    def start(self):
        """Initialize the thread to display the images."""
        if self._started:
            return None
        self._sources = self._fiducial_follower.image_sources_list
        self._started = True
        self._thread = threading.Thread(target=self.update)
        self._thread.start()
        return self

    def update(self):
        """Update the images being displayed to match that seen by the robot."""
        while self._started:
            images = self.get_image()
            for i, image in enumerate(images):
                if image.size != 0:
                    original_height, original_width = image.shape[:2]
                    resized_image = cv2.resize(
                        image, (int(original_width * .5), int(original_height * .5)),
                        interpolation=cv2.INTER_NEAREST)
                    cv2.imshow(self._sources[i], resized_image)
                    cv2.moveWindow(self._sources[i],
                                   max(int(i * original_width * .5), int(i * original_height * .5)),
                                   0)
                    cv2.waitKey(1)

    def stop(self):
        """Stop the thread and the image displays."""
        self._started = False
        cv2.destroyAllWindows()


class Exit(object):
    """Handle exiting on SIGTERM."""

    def __init__(self):
        self._kill_now = False
        signal.signal(signal.SIGTERM, self._sigterm_handler)

    def __enter__(self):
        return self

    def __exit__(self, _type, _value, _traceback):
        return False

    def _sigterm_handler(self, _signum, _frame):
        self._kill_now = True

    @property
    def kill_now(self):
        """Return if sigterm received and program should end."""
        return self._kill_now


def main(argv):
    """Command line interface."""
    import argparse

    parser = argparse.ArgumentParser()
    bosdyn.client.util.add_base_arguments(parser)
    parser.add_argument('--limit-speed', default=True, type=lambda x: (str(x).lower() == 'true'),
                        help='If the robot should limit its maximum speed.')
    parser.add_argument('--avoid-obstacles', default=False, type=lambda x:
                        (str(x).lower() == 'true'),
                        help='If the robot should have obstacle avoidance enabled.')
    parser.add_argument('--use-world-objects', default=True, type=lambda x: (str(x).lower() == 'true'),
        help='If fiducials should be from the world object service or the apriltag library.')
    options = parser.parse_args(argv)

    # If requested, attempt import of Apriltag library
    if not options.use_world_objects:
        try:
            global apriltag
            from apriltag import apriltag
        except ImportError as e:
            print(f'Could not import the AprilTag library. Aborting. Exception: {e}')
            return False

    # See hello_spot.py for an explanation of these lines.
    bosdyn.client.util.setup_logging(options.verbose)

    # Create Robot object
    sdk = bosdyn.client.create_standard_sdk('ArmWithBodyFollowClient')
    robot = sdk.create_robot(options.hostname)
    bosdyn.client.util.authenticate(robot)
    robot.time_sync.wait_for_sync()

    assert robot.has_arm(), 'Robot requires an arm to run this example.'

    # Verify the robot is not estopped and that an external application has registered and holds
    # an estop endpoint.
    assert not robot.is_estopped(), 'Robot is estopped. Please use an external E-Stop client, ' \
                                    'such as the estop SDK example, to configure E-Stop.'

    track_w_arm = None
    image_viewer = None
    try:
        with Exit():
            bosdyn.client.util.authenticate(robot)
            robot.start_time_sync()

            track_w_arm = ArmWithBodyFollow(robot, options)
            
            # Display the detected bounding boxes on the images when using the april tag library.
            # This is disabled for MacOS-X operating systems.
            image_viewer = DisplayImagesAsync(track_w_arm)
            image_viewer.start()

            lease_client = robot.ensure_client(LeaseClient.default_service_name)
            with bosdyn.client.lease.LeaseKeepAlive(lease_client, must_acquire=True,
                                                    return_at_exit=True):
                track_w_arm.start()

    except RpcError as err:
        LOGGER.error('Failed to communicate with robot: %s', err)
    finally:
        if image_viewer is not None:
            image_viewer.stop()
    return False


if __name__ == '__main__':
    if not main(sys.argv[1:]):
        sys.exit(1)
