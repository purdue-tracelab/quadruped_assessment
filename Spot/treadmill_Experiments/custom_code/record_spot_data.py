"""Custom specific robot state capture"""

import sys
import argparse
import os
import time

import bosdyn.client
import bosdyn.client.util
from bosdyn.client.robot_state import RobotStateClient


def main():
    parser = argparse.ArgumentParser()
    bosdyn.client.util.add_base_arguments(parser)
    options = parser.parse_args()
    #options.hostname = '192.168.80.3'

    # Create robot object with an image client.
    sdk = bosdyn.client.create_standard_sdk('RobotStateClient')
    robot = sdk.create_robot(options.hostname)
    bosdyn.client.util.authenticate(robot)
    robot_state_client = robot.ensure_client(RobotStateClient.default_service_name)

    start_recording(robot_state_client)


def start_recording(robot_state_client):
    """Creates File in github folder to start recording
       dataPath must be changed for each motion and condition"""

    '''
    home = os.path.expanduser("~")
    dataPath = home+'/Ghost-V60/Spot/treadmill_Experiments/experiment_data/2024_tests_REDO/'
    numFiles = len(os.listdir(dataPath))

    fileName = 'experiment_' + str(numFiles+1) + '.txt'
    data_file = open(dataPath+fileName, 'w')
    print('\nFile "' + fileName + '" created for recording\n')
    '''


    home = os.path.expanduser("~")
    dataPath = home+'/Ghost-V60/Spot/treadmill_Experiments/experiment_data/2024_tests_REDO/Baseline/noMo/'
    foldername = dataPath
    try:
        os.makedirs(foldername)
    except:
        print("Directory " + foldername + " already exists!")

    filename = 'experiment_' + time.strftime("%Y-%m-%d_%H-%M-%S") + '.txt'
    data_file = open(dataPath+filename, 'w')
    print('\nFile "' + filename + '" created for recording\n')
    get_data(robot_state_client, data_file)
    data_file.close()

    print('\n**Finished Data Recording**\n')


def get_data(robot_state_client, data_file):
    """Loops get_robot_state, parses data, and records to text file"""

    data_file.write('Seconds, nanoS, fl_hx_Pos, fl_hx_Vel, fl_hx_Acc, fl_hx_Load, '
                                  + 'fl_hy_Pos, fl_hy_Vel, fl_hy_Acc, fl_hy_Load, '
                                  + 'fl_kn_Pos, fl_kn_Vel, fl_kn_Acc, fl_kn_Load, '
                                  + 'fr_hx_Pos, fr_hx_Vel, fr_hx_Acc, fr_hx_Load, '
                                  + 'fr_hy_Pos, fr_hy_Vel, fr_hy_Acc, fr_hy_Load, '
                                  + 'fr_kn_Pos, fr_kn_Vel, fr_kn_Acc, fr_kn_Load, '
                                  + 'hl_hx_Pos, hl_hx_Vel, hl_hx_Acc, hl_hx_Load, '
                                  + 'hl_hy_Pos, hl_hy_Vel, hl_hy_Acc, hl_hy_Load, '
                                  + 'hl_kn_Pos, hl_kn_Vel, hl_kn_Acc, hl_kn_Load, '
                                  + 'hr_hx_Pos, hr_hx_Vel, hr_hx_Acc, hr_hx_Load, '
                                  + 'hr_hy_Pos, hr_hy_Vel, hr_hy_Acc, hr_hy_Load, '
                                  + 'hr_kn_Pos, hr_kn_Vel, hr_kn_Acc, hr_kn_Load, '
                                  + 'fl_Contact, fr_Contact, hl_Contact, hr_Contact\n')
    
    start = time.time()
    end   = start + 65
    print('**Starting Data Recording**\n')
    curr = time.time()

    while curr < end:
        # Make a get robot state data
        robot_state  = robot_state_client.get_robot_state()
        js = robot_state.kinematic_state.joint_states
        ts = robot_state.kinematic_state.acquisition_timestamp
        
        # `foot_state` is repeated, so this is a quick-and-dirty way of pulling out the contact for each foot
        fs  = list(map(lambda s: s.contact, robot_state.foot_state))

        data_file.write(str(ts.seconds)  + ', ' + str(ts.nanos) + ', '
            + str(js[0].position.value)  + ', ' + str(js[0].velocity.value)  + ', ' + str(js[0].acceleration.value)  + ', ' + str(js[0].load.value) + ', '
            + str(js[1].position.value)  + ', ' + str(js[1].velocity.value)  + ', ' + str(js[1].acceleration.value)  + ', ' + str(js[1].load.value) + ', '
            + str(js[2].position.value)  + ', ' + str(js[2].velocity.value)  + ', ' + str(js[2].acceleration.value)  + ', ' + str(js[2].load.value) + ', '
            + str(js[3].position.value)  + ', ' + str(js[3].velocity.value)  + ', ' + str(js[3].acceleration.value)  + ', ' + str(js[3].load.value) + ', '
            + str(js[4].position.value)  + ', ' + str(js[4].velocity.value)  + ', ' + str(js[4].acceleration.value)  + ', ' + str(js[4].load.value) + ', '
            + str(js[5].position.value)  + ', ' + str(js[5].velocity.value)  + ', ' + str(js[5].acceleration.value)  + ', ' + str(js[5].load.value) + ', '
            + str(js[6].position.value)  + ', ' + str(js[6].velocity.value)  + ', ' + str(js[6].acceleration.value)  + ', ' + str(js[6].load.value) + ', '
            + str(js[7].position.value)  + ', ' + str(js[7].velocity.value)  + ', ' + str(js[7].acceleration.value)  + ', ' + str(js[7].load.value) + ', '
            + str(js[8].position.value)  + ', ' + str(js[8].velocity.value)  + ', ' + str(js[8].acceleration.value)  + ', ' + str(js[8].load.value) + ', '
            + str(js[9].position.value)  + ', ' + str(js[9].velocity.value)  + ', ' + str(js[9].acceleration.value)  + ', ' + str(js[9].load.value) + ', '
            + str(js[10].position.value) + ', ' + str(js[10].velocity.value) + ', ' + str(js[10].acceleration.value) + ', ' + str(js[10].load.value) + ', '
            + str(js[11].position.value) + ', ' + str(js[11].velocity.value) + ', ' + str(js[11].acceleration.value) + ', ' + str(js[11].load.value) + ', '
            + str(fs[0]) + ', ' + str(fs[1]) + ', ' + str(fs[2]) + ', ' + str(fs[3]) + '\n')

        time.sleep(0.01)

        curr = time.time()


    return None


if __name__ == '__main__':
    if not main():
        sys.exit(1)
