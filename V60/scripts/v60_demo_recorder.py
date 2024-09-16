#!/usr/bin/env python3

#all necessary imports
import rospy
import roslib
import time
import h5py
import numpy as np
import message_filters
import math
import geometry_msgs.msg
from std_msgs.msg import String
from sensor_msgs.msg import JointState

# create subscribers for joint state, tf, wrench
#each subscriber writes data and timestamps to file (txt)
#if demo is chosen to be saved, read from the txt files
#compare timestamps
#if timestamps match, write to an array
#save array to h5 file

NUM_JOINTS = 12

def js_callback(jsmsg, js_file):
	js_file.write(str(jsmsg.header.stamp.secs) + ', ' + str(jsmsg.header.stamp.nsecs).replace(')', '').replace('(', '') + ', ' + str(jsmsg.position).replace(')', '').replace('(', '') + ', ' + str(jsmsg.velocity).replace(')', '').replace('(', '') + ', ' + str(jsmsg.effort).replace(')', '').replace('(', '') + '\n')
 
def getline_data(fp):
	return np.array([float(i) for i in fp.readline().split(', ')])
   
def save_demo():
    js_fp = open('joint_data.txt', 'r')
    js_time_arr = np.zeros((1, 2))
    js_pos_arr = np.zeros((1, NUM_JOINTS))
    js_vel_arr = np.zeros((1, NUM_JOINTS))
    js_eff_arr = np.zeros((1, NUM_JOINTS))
	
    name = 'recorded_demo ' + time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) + '.h5'
    fp = h5py.File(name, 'w')
        
    
    try:
        js_data = getline_data(js_fp)
        while True:
            js_time = js_data[0] + (js_data[1] * 10.0**-9)
            js_time_arr = np.vstack((js_time_arr, js_data[0:2]))
            js_pos_arr = np.vstack((js_pos_arr, js_data[2:2+NUM_JOINTS]))
            js_vel_arr = np.vstack((js_vel_arr, js_data[2+NUM_JOINTS:2+NUM_JOINTS+NUM_JOINTS]))
            js_eff_arr = np.vstack((js_eff_arr, js_data[2+NUM_JOINTS+NUM_JOINTS:2+NUM_JOINTS+NUM_JOINTS+NUM_JOINTS]))
            
            js_data = getline_data(js_fp)
            else:
                rospy.loginfo('Should never get here')
    except ValueError:
        rospy.loginfo('Finished demo recording')
        
    js_fp.close()

    #delete first row of 0's
    js_time_arr = np.delete(js_time_arr, 0, 0)
    js_pos_arr = np.delete(js_pos_arr, 0, 0)
    js_vel_arr = np.delete(js_vel_arr, 0, 0)
    js_eff_arr = np.delete(js_eff_arr, 0, 0)
    
    
    dset_jt = fp.create_dataset('/joint_state_info/joint_time', data=js_time_arr)
    dset_jp = fp.create_dataset('/joint_state_info/joint_positions', data=js_pos_arr)
    dset_jv = fp.create_dataset('/joint_state_info/joint_velocities', data=js_vel_arr)
    dset_je = fp.create_dataset('/joint_state_info/joint_effort', data=js_eff_arr)
    
    fp.close()
    
def end_record(js_file):
    print(time.time())
    
    js_file.close()
    
    save = input('Would you like to save this demo? (y/n)')
    rospy.loginfo("You entered: %s", save)  
    if (save == 'y'):
    	save_demo()

    cont = input('Would you like to start another demo? (y/n)')
    rospy.loginfo("You entered: %s", cont)
    if (cont == 'y'):
        demo_recorder()
   
def demo_recorder():
    print('Starting recorder')
    try:
        #create joint states file
        js_fp = open('joint_data.txt', 'w')

        rospy.init_node('demo_recorder', anonymous=True)
    	
        print('Press [Enter] to start recording')
        input()
        print(time.time())
        
        #create subscribers to topics
        
        sub_js = rospy.Subscriber("/j2s7s300_driver/out/joint_state", JointState, js_callback, js_fp)
        	
        
        	
        rospy.loginfo('Recording has started')
        	
        rospy.spin()
        end_record(js_fp)
        
    except rospy.ROSInterruptException:
        end_record(js_fp)
    except rospy.ServiceException: 
        end_record(js_fp)
        print("Service call failed")
    except KeyboardInterrupt:
        end_record(js_fp)
        
if __name__ == '__main__':
    demo_recorder()

