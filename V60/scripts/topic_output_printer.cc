#include "ros/ros.h"
#include "std_msgs/String.h"
#include "sensor_msgs/JointState.h"
#include "draper_msgs/ToeArray.h"

#include <stdio.h>      // printf
#include <time.h>       // time_t, struct tm, difftime, time, mktime 
#include <sstream>
#include <iostream>		// cin, cout
#include <string>		// std::string s="string"

/*
 * Simply outputs the all subscribed topic info once
 */

const int NUM_JOINTS = 12;
const int NUM_LIMBS  = 4;

void jointState_Callback(const sensor_msgs::JointState::ConstPtr& js_msg)
{
	std::cout << "TIME: \n  " << js_msg->header.stamp.sec << '\n' << " + " << js_msg->header.stamp.nsec << '\n';
	std::cout << "Position: \n";
	for (int i = 0; i < NUM_JOINTS; i++)
    {
        std::cout << "  " << js_msg->position[i] << '\n'; 
    } 
	std::cout << " ============== \n";
	
	std::cout << "Velocity: \n";
	for (int i = 0; i < NUM_JOINTS; i++)
    {
        std::cout << "  " << js_msg->velocity[i] << '\n'; 
    } 
	std::cout << " ============== \n";
	
	std::cout << "Effort: \n";
	for (int i = 0; i < NUM_JOINTS; i++)
    {
        std::cout << "  " << js_msg->effort[i] << '\n'; 
    } 
	std::cout << " ============== \n";
}

void toePos_Callback(const draper_msgs::ToeArray::ConstPtr& tp_msg)
{
	for (int i = 0; i < NUM_LIMBS; i++)
    {
        std::cout << "Toe " << i 
		std::cout << "  Contact: \n" 
		std::cout << "    "  << tp_msg->toes[i].contact << '\n'; 
		std::cout << "  Position: \n";
		std::cout << "    x: " << tp_msg->toes[i].position.x << '\n';
		std::cout << "    y: " << tp_msg->toes[i].position.y << '\n';
		std::cout << "    z: " << tp_msg->toes[i].position.z << '\n';
    } 
	std::cout << " ============== \n";
}
 


int main(int argc, char **argv)
{
	// Init node
	ros::init(argc, argv, "recorder_node");
	ros::NodeHandle n;
	
	// JS = Joint State, TP = Toe Position; Used to gather joint data
	ros::Subscriber jointState_sub = n.subscribe("/mcu/state/jointURDF", 3, jointState_Callback);
	ros::Subscriber toePos_sub = n.subscribe("/mcu/state/toe_array", 3, toePos_Callback);
	
	ros::spin();
	return 0;
}

/*
draper_msgs/ToeArray:

std_msgs/Header header
  uint32 seq
  time stamp
  string frame_id
draper_msgs/Toe[] toes
  bool valid
  int32 id
  int32 contact
  float32 sphase
  geometry_msgs/Point position
    float64 x
    float64 y
    float64 z
*/