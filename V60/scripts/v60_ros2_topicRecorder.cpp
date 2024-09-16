#include "rclcpp/rclcpp.hpp
#include "std_msgs/msg/String.hpp"
#include "sensor_msgs/msg/JointState.hpp"
#include "draper_msgs/ToeArray.hpp"
#include "geometry_msgs/msg/Twist.hpp"

#include <memory>
#include <stdio.h>      // printf
#include <ctime>        // tm_sec, tm_min, tm_hour, tm_mday, tm_mon, tm_year 
#include <sstream>
#include <signal.h>		// SIGINT for signal interrupt
#include <exception>
#include <iostream>		// cin, cout
#include <fstream>		// Write and read file
#include <string>		// std::string s="string", to_string()
#include <unistd.h>		// get_current_dir_name()

/*
 * This code records the joint pos, vel, and efforts and toe contact and position
 *	as well as remote control input via manual_twist
 */
 
const int NUM_JOINTS = 12;
const int NUM_LEGS  = 4;

class InterruptException : public std::exception
{
	public:
		InterruptException(int sigNum) : S(sigNum) {}
		int S;
};

void keyboard_interrupt(int sigNum)
{
	// Catches [CTRL+C] to throw inturrupt to stop recording
	throw InterruptException(sigNum);
}

std::string get_time()
{// =====  Gathers Local time and puts into string for file name  =====
	time_t now = time(0);
	std::tm *ltm = localtime(&now);
	
	std::string sec   = std::to_string(ltm->tm_sec);
	std::string min   = std::to_string(ltm->tm_min);
	std::string hr    = std::to_string(ltm->tm_hour);
	std::string day   = std::to_string(ltm->tm_mday);
	std::string month = std::to_string(1 + ltm->tm_mon);
	std::string yr    = std::to_string(1900 + ltm->tm_year);
	std::string time = yr + '-' + month + '-' + day + '-' + hr + '-' + min + '-' + sec;
	
	return time;
}

// init files
std::ofstream jointStateTime;
std::ofstream jointStatePos;
std::ofstream jointStateVel;
std::ofstream jointStateEffort;
std::ofstream toeContactTime;
std::ofstream toeContact;
std::ofstream toeContactX;
std::ofstream toeContactY;
std::ofstream toeContactZ;
std::ofstream twistX;
std::ofstream twistY;
std::ofstream twistZ;

void save_data()
{// =====  Creates new file name to replace temp data  =====
	// std::string currDir = get_current_dir_name();
	std::string dataFilePath = "/home/ghost/catkin_ws/src/trace/runData/";
	std::cout << "\nSaving Data in " << dataFilePath << '\n';
	std::string time = get_time();			// Gets current Local time
	std::cout << "Local Time: " << time << "\n\n";
	
	// Create file names in correct dir for Joint States
	std::string newJST_fileName = dataFilePath + "recordedJoint_time" + time + ".txt";
	std::string newJSP_fileName = dataFilePath + "recordedJoint_position" + time + ".txt";
	std::string newJSV_fileName = dataFilePath + "recordedJoint_velocity" + time + ".txt";
	std::string newJSE_fileName = dataFilePath + "recordedJoint_effort" + time + ".txt";
	
	// Create file names in correct dir for Toe Array
	std::string newTPT_fileName = dataFilePath + "recordedToe_time" + time + ".txt";
	std::string newTPC_fileName = dataFilePath + "recordedToe_cont" + time + ".txt";
	std::string newTPX_fileName = dataFilePath + "recordedToe_xPos" + time + ".txt";
	std::string newTPY_fileName = dataFilePath + "recordedToe_yPos" + time + ".txt";
	std::string newTPZ_fileName = dataFilePath + "recordedToe_zPos" + time + ".txt";
	
	// Creat file names in correct dir for Manual Twist
	std::string newMTX_fileName = dataFilePath + "recordedTwist_X" + time + ".txt";
	std::string newMTY_fileName = dataFilePath + "recordedTwist_Y" + time + ".txt";
	std::string newMTZ_fileName = dataFilePath + "recordedTwist_Z" + time + ".txt";
	
	// Sends recorded data to a different dir and renames it with timestamp
	rename("jointStateTime.txt",   newJST_fileName.c_str());
	rename("jointStatePos.txt",    newJSP_fileName.c_str());
	rename("jointStateVel.txt",    newJSV_fileName.c_str());
	rename("jointStateEffort.txt", newJSE_fileName.c_str());
	rename("toeContactTime.txt",   newTPT_fileName.c_str());
	rename("toeContactCont.txt",   newTPC_fileName.c_str());
	rename("toeContactXPos.txt",   newTPX_fileName.c_str());
	rename("toeContactYPos.txt",   newTPY_fileName.c_str());
	rename("toeContactZPos.txt",   newTPZ_fileName.c_str());
	rename("manualTwistX.txt",     newMTX_fileName.c_str());
	rename("manualTwistY.txt",     newMTY_fileName.c_str());
	rename("manualTwistZ.txt",     newMTZ_fileName.c_str());

	
	// Remove Temp files
	remove("jointStateTime.txt");
	remove("jointStatePos.txt");
	remove("jointStateVel.txt");
	remove("jointStateEffort.txt");
	remove("toeContactTime.txt");
	remove("toeContactCont.txt");
	remove("toeContactXPos.txt");
	remove("toeContactYPos.txt");
	remove("toeContactZPos.txt");
	rename("manualTwistX.txt");
	rename("manualTwistY.txt");
	rename("manualTwistZ.txt");
}


void data_recorder(); 	// Forward declaration
void end_recorder()
{// =====  Ask if data should be saved and closes files  =====
	char input;
	std::cout << "\nSave Recording? [Y/N]\n";
	std::cin  >> input;
	
	jointStateTime.close();
	jointStatePos.close();
	jointStateVel.close();
	jointStateEffort.close();
	toeContactTime.close();
	toeContact.close();
	toeContactX.close();
	toeContactY.close();
	toeContactZ.close();
	manualTwistX.close();
	manualTwistY.close();
	manualTwistZ.close();
	
	if (input == 'Y' || input == 'y')
	{
		save_data();
	}
	else if (input == 'N' || input == 'n')
	{
		std::cout << "\nRecording discarded\n";
		// Remove Temp files
		remove("jointStateTime.txt");
		remove("jointStatePos.txt");
		remove("jointStateVel.txt");
		remove("jointStateEffort.txt");
		remove("toeContactTime.txt");
		remove("toeContactCont.txt");
		remove("toeContactXPos.txt");
		remove("toeContactYPos.txt");
		remove("toeContactZPos.txt");
		rename("manualTwistX.txt");
		rename("manualTwistY.txt");
		rename("manualTwistZ.txt");
		data_recorder();
	}
	else
	{
		std::cout << "Only [Y/N] accepted\n";
		end_recorder();
	}
}



void data_recorder()
{
	char input;
	signal(SIGINT, keyboard_interrupt); // Init signal throw to catch
	try
	{
		std::cout << "Start recording? <any_key> [Enter] \n";
		std::cin  >> input;				// Waits for input
		
		// open files and delete all within
		jointStateTime.open ("jointStateTime.txt", std::ofstream::out | std::ofstream::trunc);
		jointStatePos.open ("jointStateEffort.txt", std::ofstream::out | std::ofstream::trunc);
		jointStateVel.open ("jointStatePos.txt", std::ofstream::out | std::ofstream::trunc);
		jointStateEffort.open ("jointStateVel.txt", std::ofstream::out | std::ofstream::trunc);
		toeContactTime.open ("toeContactTime.txt", std::ofstream::out | std::ofstream::trunc);
		toeContact.open ("toeContactCont.txt", std::ofstream::out | std::ofstream::trunc);
		toeContactX.open ("toeContactXPos.txt", std::ofstream::out | std::ofstream::trunc);
		toeContactY.open ("toeContactYPos.txt", std::ofstream::out | std::ofstream::trunc);
		toeContactZ.open ("toeContactZPos.txt", std::ofstream::out | std::ofstream::trunc);
		manualTwistX.open ("manualTwistX.txt", std::ofstream::out | std::ofstream::trunc);
		manualTwistY.open ("manualTwistY.txt", std::ofstream::out | std::ofstream::trunc);
		manualTwistZ.open ("manualTwistZ.txt", std::ofstream::out | std::ofstream::trunc);

		
		std::cout << "\nRecording started \n";
		std::cout << "\n [Ctrl+C] to stop recording\n";
		rclcpp::spin(); 					// Spins ros nodes to intake data until exception caught
		end_recorder();
	}
	catch(InterruptException& e)
	{	// Catches [Ctrl+C] Event to stop recording
		std::cout << "\nSignal " << e.S << " caught\n";
		end_recorder();
	}
}





void jointState_Callback(const sensor_msgs::msg::JointState::ConstPtr& js_msg)
{// =====  Records each incoming necessary data  =====
	// Records each incoming timestamp once per line in file
	jointStateTime << js_msg->header.stamp.sec << ' ' << js_msg->header.stamp.nsec << '\n';
	// Records each joint state property for joints 0-11 then makes a new line
	for (int i = 0; i < NUM_JOINTS; i++)
    {   
	jointStatePos << js_msg->position[i] << ' ';
	jointStateVel << js_msg->velocity[i] << ' ';
    jointStateEffort << js_msg->effort[i] << ' ';
    }
	jointStatePos << '\n';
	jointStateVel << '\n';
	jointStateEffort << '\n';
}

void toePos_Callback(const draper_msgs::msg::ToeArray::ConstPtr& tp_msg)
{// =====  Records each incoming necessary data  =====
	// Records each incoming timestamp once per line in file
	toeContactTime << tp_msg->header.stamp.sec << ' ' << tp_msg->header.stamp.nsec << '\n';
	// Records each toe contaact and position for joints 0-3 then makes a new line
	for (int i = 0; i < NUM_LEGS; i++)
    {  
		toeContact  << tp_msg->toes[i].contact    << ' '; 
		toeContactX << tp_msg->toes[i].position.x << ' ';
		toeContactY << tp_msg->toes[i].position.y << ' ';
		toeContactZ << tp_msg->toes[i].position.z << ' ';
    }
	toeContact  << '\n';
	toeContactX << '\n';
	toeContactY << '\n';
	toeContactZ << '\n';
}

void manualTwist_Callback(const geometry_msgs::msg::Twist::ConstPtr& mt_msg)
{// =====  Records each incoming necessary data  =====
	// timestamp not output

	manualTwistX << mt_msg->linear.x << ' ';
	manualTwistY << mt_msg->linear.y << ' ';
	manualTwistZ << mt_msg->angular.z << ' ';
		
	manualTwistX << '\n';
	manualTwistZ << '\n';
	manualTwistY << '\n';
}






int main(int argc, char **argv)
{
	// Catching [Ctrl+C] event 
	struct sigaction sigIntHandler;
	sigIntHandler.sa_handler = keyboard_interrupt;
	sigemptyset(&sigIntHandler.sa_mask);
	sigIntHandler.sa_flags = 0;
	sigaction(SIGINT, &sigIntHandler, NULL);
	
	// Init rclcpp library and node
	rclcpp::init(argc, argv)	// library
	std::shared_ptr<rclcpp::Node> node = rclcpp::Node::make_shared("recorder_node"); // node pointer
	
	// Create each subscription
	rclcpp::Subscription<sensor_msgs::msg::JointState>::SharedPtr     jointState_sub =
		node->create_subscription<sensor_msgs::msg::JointState>("/mcu/state/jointURDF", 10, std::bind(jointState_Callback, node, _1));
		
	rclcpp::Subscription<draper_msgs::msg::ToeArray>::SharedPtr           toePos_sub =
		node->create_subscription<draper_msgs::msg::ToeArray>("/mcu/state/toe_array", 10, std::bind(toePos_Callback, node, _1));
		
	rclcpp::Subscription<geometry_msgs::msg::Twist>::SharedPtr       manualTwist_sub =
		node->create_subscription<geometry_msgs::msg::Twist>("/mcu/command/manual_twist", 10, std::bind(manualTwist_Callback, node, _1));

	
	std::cout << "Starting data recorder\n";
	data_recorder();
	return 0;
}



