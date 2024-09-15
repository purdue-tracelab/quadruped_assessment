clc; clearvars; close all;

filePath1 = 'IMU1//datalog00002.TXT';
filePath2 = 'IMU2Or3//datalog00024.TXT';
filePath3 = 'IMU3Or2//datalog00013.TXT';
filePath4 = 'IMU4//datalog00004.TXT';


% gps_Lat,gps_Long,gps_Alt,gps_SIV,gps_FixType,gps_GroundSpeed,gps_Heading,gps_pDOP,output_Hz,
%IMU_data = readmatrix(strcat(filePath));
IMU1 = readtable(strcat(filePath1));
IMU2 = readtable(strcat(filePath2));
IMU3 = readtable(strcat(filePath3));
IMU4 = readtable(strcat(filePath4));

%%
%{
%IMU_times.rtcDate = datetime(IMU_times.rtcDate,'Format','MM/dd/uuuu');
%IMU_times.rtcTime = datetime(IMU_times.rtcTime,'Format','HH:mm:ss.SSS')
 
first 2 columns are rtcDate and rtcTime with poor formats
       this isnt needed, but can be corrected in the future
columns 13 and 14 are gps_Date, gps_Time


% aXYZ is [...]
aX = IMU_data(:,3); aY = IMU_data(:,4); aZ = IMU_data(:,5);
% gXYZ is [...]
gX = IMU_data(:,6); gY = IMU_data(:,7); gZ = IMU_data(:,8);
% mXYZ is [...]
mX = IMU_data(:,9); mY = IMU_data(:,10); mZ = IMU_data(:,11);

imu_degC = IMU_data(:,12);          %

% GPS coordinates
gps_Lat = IMU_data(:,15); gps_Long = IMU_data(:,16); gps_Alt = IMU_data(:,17);

gps_SIV = IMU_data(:,18);           %
gps_FixType = IMU_data(:,19);       %
gps_GroundSpeed = IMU_data(:,20);   %
gps_Heading = IMU_data(:,21);       %
gps_pDOP = IMU_data(:,22);          %
output_Hz = IMU_data(:,23);         %
%}

%% Longitude and Latitude
figure
plot(IMU1.gps_Time,IMU1.gps_Long, IMU2.gps_Time,IMU2.gps_Long,...
     IMU3.gps_Time,IMU3.gps_Long, IMU4.gps_Time,IMU4.gps_Long)
%t1 = string({'13:00:00.000'});
%t2 = string({'21:30:00.000'});
t1 = string({'14:40:00.000'});
t2 = string({'19:07:00.000'});
t1 = duration(t1);
t2 = duration(t2);
xlim([t1,t2]);
ylim([-7.61835e8,-7.6182e8])
legend('1','2','3','4')

%% Altitude
figure
plot(IMU1.gps_Time,IMU1.gps_Alt, IMU2.gps_Time,IMU2.gps_Alt,...
     IMU3.gps_Time,IMU3.gps_Alt, IMU4.gps_Time,IMU4.gps_Alt)
t1 = string({'13:00:00.000'});
t2 = string({'21:30:00.000'});
% t1 = string({'14:40:00.000'});
% t2 = string({'19:07:00.000'});
t1 = duration(t1);
t2 = duration(t2);
xlim([t1,t2]);
ylim([-160000,100000,])
legend('1','2','3','4')

%% Heading
figure
plot(IMU1.gps_Time,IMU1.gps_Heading, IMU2.gps_Time,IMU2.gps_Heading,...
     IMU3.gps_Time,IMU3.gps_Heading, IMU4.gps_Time,IMU4.gps_Heading)
t1 = string({'13:00:00.000'});
t2 = string({'21:30:00.000'});
% t1 = string({'14:40:00.000'});
% t2 = string({'19:07:00.000'});
t1 = duration(t1);
t2 = duration(t2);
%xlim([t1,t2]);
ylim([-1000000,360000000])
legend('1','2','3','4')






