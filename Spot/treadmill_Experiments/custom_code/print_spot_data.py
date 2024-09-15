"""Custom specific robot state capture"""

import sys

import bosdyn.client
import bosdyn.client.util
from bosdyn.client.robot_state import RobotStateClient


def main():
    import argparse

    parser = argparse.ArgumentParser()
    bosdyn.client.util.add_base_arguments(parser)
    options = parser.parse_args()

    # Create robot object with an image client.
    sdk = bosdyn.client.create_standard_sdk('RobotStateClient')
    robot = sdk.create_robot(options.hostname)
    bosdyn.client.util.authenticate(robot)
    robot_state_client = robot.ensure_client(RobotStateClient.default_service_name)

    # Make a get robot state data
    robot_state  = robot_state_client.get_robot_state()
    joint_states = robot_state.kinematic_state.joint_states
    timestamp    = robot_state.kinematic_state.acquisition_timestamp
    
    # `foot_state` is repeated, so this is a quick-and-dirty way of pulling out the contact for each foot
    feet_state   = list(map(lambda s: s.contact, robot_state.foot_state))

    print(timestamp)
    
    return True


if __name__ == '__main__':
    if not main():
        sys.exit(1)