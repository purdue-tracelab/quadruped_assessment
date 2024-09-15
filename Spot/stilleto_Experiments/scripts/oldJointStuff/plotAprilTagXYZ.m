clc; clearvars;

%% Walking - Pier
xyz = readmatrix('aprilTagXYZ/GOPR0182_00_50_3_40.csv');
x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);

% for i = 1:size(xyz,1)
%     if x(i) == 0
%         x(i) = nan;
%     end
% end

time = 0:(1/30):size(xyz, 1)/30 - (1/30);

maxX = max(x);
maxY = max(y);
maxZ = max(z);
maxd = max([maxX, maxY, maxZ]);

minX = min(x);
minY = min(y);
minZ = min(z);
mind = min([minX, minY, minZ]);

figure(1)
hold on
subplot(3,1,1)
plot(time, x)
title('X Position in Frame')
xlabel('Time [s]')
ylabel('X')
ylim([mind, maxd])

subplot(3,1,2)
plot(time, y)
title('Y Position in Frame')
xlabel('Time [s]')
ylabel('Y')
ylim([mind, maxd])

subplot(3,1,3)
plot(time, z)
title('Z Position in Frame')
xlabel('Time [s]')
ylabel('Z')
ylim([mind, maxd])

sgtitle('Walking - Pier')
saveas(1, 'aprilTagXYZ/walking_pier', 'jpg')
hold off

%% Strafe Underway
xyz = readmatrix('aprilTagXYZ/GOPR0186_09_30_12_35.csv');
x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);

time = 0:(1/30):size(xyz, 1)/30 - (1/30);

maxX = max(x);
maxY = max(y);
maxZ = max(z);
maxd = max([maxX, maxY, maxZ]);

minX = min(x);
minY = min(y);
minZ = min(z);
mind = min([minX, minY, minZ]);

figure(2)
hold on
subplot(3,1,1)
plot(time, x)
title('X Position in Frame')
xlabel('Time [s]')
ylabel('X')
ylim([mind, maxd])

subplot(3,1,2)
plot(time, y)
title('Y Position in Frame')
xlabel('Time [s]')
ylabel('Y')
ylim([mind, maxd])

subplot(3,1,3)
plot(time, z)
title('Z Position in Frame')
xlabel('Time [s]')
ylabel('Z')
ylim([mind, maxd])

sgtitle('Strafe - Underway')
saveas(1, 'aprilTagXYZ/Strafe_Underway', 'jpg')
hold off


%% Walking SCurves

xyz = readmatrix('aprilTagXYZ/GOPR0188_6_50_10_00.csv');
x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);

time = 0:(1/30):size(xyz, 1)/30 - (1/30);

maxX = max(x);
maxY = max(y);
maxZ = max(z);
maxd = max([maxX, maxY, maxZ]);

minX = min(x);
minY = min(y);
minZ = min(z);
mind = min([minX, minY, minZ]);

figure(3)
hold on
subplot(3,1,1)
plot(time, x)
title('X Position in Frame')
xlabel('Time [s]')
ylabel('X')
ylim([mind, maxd])

subplot(3,1,2)
plot(time, y)
title('Y Position in Frame')
xlabel('Time [s]')
ylabel('Y')
ylim([mind, maxd])

subplot(3,1,3)
plot(time, z)
title('Z Position in Frame')
xlabel('Time [s]')
ylabel('Z')
ylim([mind, maxd])

sgtitle('Walking - SCurves')
saveas(1, 'aprilTagXYZ/Walking_SCurves', 'jpg')
hold off

%% Strafe - SeaState

xyz = readmatrix('aprilTagXYZ/GOPR0188_14_30_17_40.csv');
x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);

time = 0:(1/30):size(xyz, 1)/30 - (1/30);

maxX = max(x);
maxY = max(y);
maxZ = max(z);
maxd = max([maxX, maxY, maxZ]);

minX = min(x);
minY = min(y);
minZ = min(z);
mind = min([minX, minY, minZ]);

figure(4)
hold on
subplot(3,1,1)
plot(time, x)
title('X Position in Frame')
xlabel('Time [s]')
ylabel('X')
ylim([mind, maxd])

subplot(3,1,2)
plot(time, y)
title('Y Position in Frame')
xlabel('Time [s]')
ylabel('Y')
ylim([mind, maxd])

subplot(3,1,3)
plot(time, z)
title('Z Position in Frame')
xlabel('Time [s]')
ylabel('Z')
ylim([mind, maxd])

sgtitle('Strafe - SeaState')
saveas(1, 'aprilTagXYZ/Strafe_SeaState', 'jpg')
hold off



