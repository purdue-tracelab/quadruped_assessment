clc; clearvars; close all;

filePath1 = 'IMU1//datalog00002.TXT';
filePath2 = 'IMU2Or3//datalog00024.TXT';
filePath3 = 'IMU3Or2//datalog00013.TXT';
filePath4 = 'IMU4//datalog00004.TXT';


% gps_Lat,gps_Long,gps_Alt,gps_SIV,gps_FixType,gps_GroundSpeed,gps_Heading,gps_pDOP,output_Hz,
IMU1 = readtable(strcat(filePath1));
IMU2 = readtable(strcat(filePath2));
IMU3 = readtable(strcat(filePath3));
IMU4 = readtable(strcat(filePath4));



%% Longitude and Latitude
figure
plot(IMU1.gps_Time,IMU1.gps_Long, IMU2.gps_Time,IMU2.gps_Long,...
     IMU3.gps_Time,IMU3.gps_Long, IMU4.gps_Time,IMU4.gps_Long)
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
t1 = duration(t1);
t2 = duration(t2);
%xlim([t1,t2]);
ylim([-1000000,360000000])
legend('1','2','3','4')






