clc; clearvars; close all;

%{
    This code gathers the .txt files from the .trc files which were
    generated from the Motion Capture Program. The '-platform' and '-v60'
    specific files are put into a table using readtable() and are then sent
    to 'getPlatMoCap.m' and 'getV60MoCap.m', respectively, which arranges
    the table data into a struct for ease of use.

    Plots of spot displacement and wrist distance from post are then
    generated.

    This code requires 'trc2txt.m' to be run first.
%}

filePath = '../trc_files/spot_REDO TRC/'; 
txtFiles = dir(strcat(filePath, '*.txt'));

test(size(txtFiles,1),1) = string();   % init
for i = 1:size(txtFiles,1)
    test(i, 1) = string(extractBetween(txtFiles(i).name, '', '-'));
    %     trialPath(i, 1) = strcat(filePath, string(test));
end

nTests = size(txtFiles,1);

%% Get trc data
for k = 1:2:nTests
% for k = 7
    platPath = strcat(filePath, test(k), '-platform.txt');
    spotPath  = strcat(filePath, test(k), '-v60.txt');

    platform = readtable(platPath);
    spotTabl = readtable(spotPath);
    
    % Puts table data into struct format
    plat((k+1)/2) = getPlatMoCap(platform);
    spot((k+1)/2) = getV60MoCap(spotTabl);
end

%% Find platform and base center and base angle
for j = 1:size(plat,2)
% for j = 4
    plat(j).test = test((j*2)-1, 1);    % Saves name of test, but there are  
                                        % duplicates so saves the first then skips 1
    plat(j).test = strrep(plat(j).test, '_', '__'); % Replaces '_' with '__'

% Platform Center
    pRX = (plat(j).FR.X + plat(j).AR.X)/2;  % Gets middle of right side platform X
    pLX = (plat(j).FL.X + plat(j).AL.X)/2;  % Gets middle of left side platform X
    plat(j).O.X = (pRX + pLX)/2;            % Gets middle of platform X

    pRY = (plat(j).FR.Y + plat(j).AR.Y)/2;  % Same for Y ^
    pLY = (plat(j).FL.Y + plat(j).AL.Y)/2;
    plat(j).O.Y = (pRY + pLY)/2;

    pRZ = (plat(j).FR.Z + plat(j).AR.Z)/2;  % Same for Z ^
    pLZ = (plat(j).FL.Z + plat(j).AL.Z)/2;
    plat(j).O.Z = (pRZ + pLZ)/2;

% Platform pitch
    Fy = (plat(j).FR.Y + plat(j).FL.Y)./2;  % Ave Front height
    Fz = (plat(j).FR.Z + plat(j).FL.Z)./2;  % Ave Front dist
    Ay = (plat(j).AR.Y + plat(j).AL.Y)./2;  % Ave Rear height
    Az = (plat(j).AR.Z + plat(j).AL.Z)./2;  % Ave Rear Dist 
    pH = Fy - Ay;                       % Gets Front-Aft height difference
    pL = Fz - Az;                       % Gets Front-Aft length difference
    plat(j).pitch = -atan(pH./pL);      % Calculates pitch angle with Z-axis
                                        %                 pointing backwards

% V60 Base Center
    % gets center of V60 base by taking halfay points of right and left
    % side points in XYZ
    vRX = (spot(j).FR.X + spot(j).AR.X)/2;
    vLX = (spot(j).FL.X + spot(j).AL.X)/2;
    spot(j).O.X = (vRX + vLX)/2;

    vRY = (spot(j).FR.Y + spot(j).AR.Y)/2;
    vLY = (spot(j).FL.Y + spot(j).AL.Y)/2;
    spot(j).O.Y = (vRY + vLY)/2;

    vRZ = (spot(j).FR.Z + spot(j).AR.Z)/2;
    vLZ = (spot(j).FL.Z + spot(j).AL.Z)/2;
    spot(j).O.Z = (vRZ + vLZ)/2;

    % Center of Rotation
    try
        plat(j).CoR = calcPlatCOR(plat(j));
    catch
        warning('No Pitch detected. Setting default Average of all CoR');
        plat(j).CoR.X = 0.3324;
        plat(j).CoR.Y = -150.8993;
        plat(j).CoR.Z = 28.9900;
    end
end

% Average CoR across moving trials for the stationary one
% allCoRx = plat(1).CoR.X;
% allCoRy = plat(1).CoR.Y;
% allCoRz = plat(1).CoR.Z;
% for j = 2:74
%     allCoRx = [allCoRx, plat(j).CoR.X];
%     allCoRy = [allCoRy, plat(j).CoR.Y];
%     allCoRz = [allCoRz, plat(j).CoR.Z];
% end
% aveCoR(1) = mean(allCoRx);
% aveCoR(2) = mean(allCoRy);
% aveCoR(3) = mean(allCoRz);

%% Platform Shape 2D
% figure
% plot(plat(1).FR.X(290:425), plat(1).FR.Z(290:425), 'r', ...
%      plat(1).FL.X(290:425), plat(1).FL.Z(290:425), 'c', ...
%      plat(1).AR.X(290:425), plat(1).AR.Z(290:425), 'm', ...
%      plat(1).AL.X(290:425), plat(1).AL.Z(290:425), 'k', ...
%      plat(1).Po.X(290:425), plat(1).Po.Z(290:425), 'b', ...
%      plat(1).O.X(290:425),  plat(1).O.Z(290:425),  'g', ...
%      plat(1).FR.X(290), plat(1).FR.Z(290), 'r.', ...
%      plat(1).FL.X(290), plat(1).FL.Z(290), 'c.', ...
%      plat(1).AR.X(290), plat(1).AR.Z(290), 'm.', ...
%      plat(1).AL.X(290), plat(1).AL.Z(290), 'k.', ...
%      plat(1).Po.X(290), plat(1).Po.Z(290), 'b.', ...
%      plat(1).O.X(290),  plat(1).O.Z(290),  'g.', ...
%      plat(1).FR.X(425), plat(1).FR.Z(425), 'rx', ...
%      plat(1).FL.X(425), plat(1).FL.Z(425), 'cx', ...
%      plat(1).AR.X(425), plat(1).AR.Z(425), 'mx', ...
%      plat(1).AL.X(425), plat(1).AL.Z(425), 'kx', ...
%      plat(1).Po.X(425), plat(1).Po.Z(425), 'bx', ...
%      plat(1).O.X(425),  plat(1).O.Z(425),  'gx', ...
%      0,0, 'ko')
% legend('FR', 'FL', 'AR', 'AL', 'Po', 'C', Location='northoutside', Orientation='horizontal')
% xlabel('X')
% ylabel('Z')
% title('Top-Down')
% 
% figure
% plot(plat(1).FR.X(290:425), plat(1).FR.Y(290:425), 'r', ...
%      plat(1).FL.X(290:425), plat(1).FL.Y(290:425), 'c', ...
%      plat(1).AR.X(290:425), plat(1).AR.Y(290:425), 'm', ...
%      plat(1).AL.X(290:425), plat(1).AL.Y(290:425), 'k', ...
%      plat(1).Po.X(290:425), plat(1).Po.Y(290:425), 'b', ...
%      plat(1).O.X(290:425),  plat(1).O.Y(290:425),  'g', ...
%      plat(1).FR.X(290), plat(1).FR.Y(290), 'r.', ...
%      plat(1).FL.X(290), plat(1).FL.Y(290), 'c.', ...
%      plat(1).AR.X(290), plat(1).AR.Y(290), 'm.', ...
%      plat(1).AL.X(290), plat(1).AL.Y(290), 'k.', ...
%      plat(1).Po.X(290), plat(1).Po.Y(290), 'b.', ...
%      plat(1).O.X(290),  plat(1).O.Y(290),  'g.', ...
%      plat(1).FR.X(425), plat(1).FR.Y(425), 'rx', ...
%      plat(1).FL.X(425), plat(1).FL.Y(425), 'cx', ...
%      plat(1).AR.X(425), plat(1).AR.Y(425), 'mx', ...
%      plat(1).AL.X(425), plat(1).AL.Y(425), 'kx', ...
%      plat(1).Po.X(425), plat(1).Po.Y(425), 'bx', ...
%      plat(1).O.X(425),  plat(1).O.Y(425),  'gx', ...
%      0,0, 'ko')
% legend('FR', 'FL', 'AR', 'AL', 'Po', 'C', Location='northoutside', Orientation='horizontal')
% xlabel('X')
% ylabel('Y')
% title('Front-Back')
% 
% figure
% plot(plat(1).FR.Z(290:425), plat(1).FR.Y(290:425), 'r', ...
%      plat(1).FL.Z(290:425), plat(1).FL.Y(290:425), 'c', ...
%      plat(1).AR.Z(290:425), plat(1).AR.Y(290:425), 'm', ...
%      plat(1).AL.Z(290:425), plat(1).AL.Y(290:425), 'k', ...
%      plat(1).Po.Z(290:425), plat(1).Po.Y(290:425), 'b', ...
%      plat(1).O.Z(290:425),  plat(1).O.Y(290:425),  'g', ...
%      plat(1).FR.Z(290), plat(1).FR.Y(290), 'r.', ...
%      plat(1).FL.Z(290), plat(1).FL.Y(290), 'c.', ...
%      plat(1).AR.Z(290), plat(1).AR.Y(290), 'm.', ...
%      plat(1).AL.Z(290), plat(1).AL.Y(290), 'k.', ...
%      plat(1).Po.Z(290), plat(1).Po.Y(290), 'b.', ...
%      plat(1).O.Z(290),  plat(1).O.Y(290),  'g.', ...
%      plat(1).FR.Z(425), plat(1).FR.Y(425), 'rx', ...
%      plat(1).FL.Z(425), plat(1).FL.Y(425), 'cx', ...
%      plat(1).AR.Z(425), plat(1).AR.Y(425), 'mx', ...
%      plat(1).AL.Z(425), plat(1).AL.Y(425), 'kx', ...
%      plat(1).Po.Z(425), plat(1).Po.Y(425), 'bx', ...
%      plat(1).O.Z(425),  plat(1).O.Y(425),  'gx', ...
%      0,0, 'ko')
% legend('FR', 'FL', 'AR', 'AL', 'Po', 'C', Location='northoutside', Orientation='horizontal')
% xlabel('Z')
% ylabel('Y')
% title('Left-Right')

%% Platform shape 3D
% FR2FL = [plat(1).FR.X(1), plat(1).FR.Y(1), plat(1).FR.Z(1);
%          plat(1).FL.X(1), plat(1).FL.Y(1), plat(1).FL.Z(1)];
% FR2AR = [plat(1).FR.X(1), plat(1).FR.Y(1), plat(1).FR.Z(1);
%          plat(1).AR.X(1), plat(1).AR.Y(1), plat(1).AR.Z(1)];
% FL2AL = [plat(1).FL.X(1), plat(1).FL.Y(1), plat(1).FL.Z(1);
%          plat(1).AL.X(1), plat(1).AL.Y(1), plat(1).AL.Z(1)];
% AR2AL = [plat(1).AR.X(1), plat(1).AR.Y(1), plat(1).AR.Z(1);
%          plat(1).AL.X(1), plat(1).AL.Y(1), plat(1).AL.Z(1)];
% 
% figure
% plot3(plat(1).FR.X(1), plat(1).FR.Y(1), plat(1).FR.Z(1), 'ro',...
%       plat(1).AR.X(1), plat(1).AR.Y(1), plat(1).AR.Z(1), 'co',...
%       plat(1).FL.X(1), plat(1).FL.Y(1), plat(1).FL.Z(1), 'mo',...
%       plat(1).AL.X(1), plat(1).AL.Y(1), plat(1).AL.Z(1), 'ko')
% hold on
% plot3(FR2FL(:,1), FR2FL(:,2), FR2FL(:,3))
% plot3(FR2AR(:,1), FR2AR(:,2), FR2AR(:,3))
% plot3(FL2AL(:,1), FL2AL(:,2), FL2AL(:,3))
% plot3(AR2AL(:,1), AR2AL(:,2), AR2AL(:,3))

%% Calculate Transforms
maxX = 0;
minX = 0;
maxY = 0;
minY = 0;
maxZ = 0;
minZ = 0;
W2P_PlatPos(nTests/2) = struct();
W2P_spotPos(nTests/2)  = struct();

for j = 1:size(plat,2)      % Cycle tests
% for j = 1
    W2P_spotPos(j).test = test(j*2);

    for f = 1:size(plat(j).time, 1) % Cycle Frames
        % Copy Times
        W2P_PlatPos(j).time = plat(j).time;
        W2P_spotPos(j).time  =  spot(j).time;

        a = plat(j).pitch(f);   % Set Platform Pitch angle
        
        % World frame -> Treadmill Transformation Matrix
        % Rotates world frame 90 degrees about x-axis so y-axis is towards 
        % post and z-axis is upwards and translates to Treadmill CoR
        World2treadXform = [1,          0,         0, plat(j).CoR.X;
                            0, cos(pi/2), -sin(pi/2), plat(j).CoR.Y;
                            0, sin(pi/2),  cos(pi/2), plat(j).CoR.Z;
                            0,          0,         0,             1];
        
        % Create Center Platform Position in the Treadmill Center of 
        % Rotation Frame for every frame
        PlatOPos_wrtCoR = World2treadXform * [plat(j).O.X(f);
                                              plat(j).O.Y(f);
                                              plat(j).O.Z(f);
                                                           1];    

        % Treadmill -> platform Transformation matrix
        CoR2PlatXform = [1,       0,         0, PlatOPos_wrtCoR(1);
                         0, cos(-a),  -sin(-a), PlatOPos_wrtCoR(2);
                         0, sin(-a),   cos(-a), PlatOPos_wrtCoR(3);
                         0,       0,         0,                  1];

        % Translate and rotate world frame to treadmill angle and disp
        World2Plat_Xform = World2treadXform * CoR2PlatXform;

    % Transform Marker Positions
        % Transform Platform Corner and Center to Plat Frame
        % Front Right:
        PlatFRXform = World2Plat_Xform * [plat(j).FR.X(f);
                                          plat(j).FR.Y(f);
                                          plat(j).FR.Z(f);
                                                        1];
        W2P_PlatPos(j).FR.X(f) = PlatFRXform(1);
        W2P_PlatPos(j).FR.Y(f) = PlatFRXform(2);
        W2P_PlatPos(j).FR.Z(f) = PlatFRXform(3);
        % Front Left:
        PlatFLXform = World2Plat_Xform * [plat(j).FL.X(f);
                                          plat(j).FL.Y(f);
                                          plat(j).FL.Z(f);
                                                        1];
        W2P_PlatPos(j).FL.X(f) = PlatFLXform(1);
        W2P_PlatPos(j).FL.Y(f) = PlatFLXform(2);
        W2P_PlatPos(j).FL.Z(f) = PlatFLXform(3);
        % Aft Right:
        PlatARXform = World2Plat_Xform * [plat(j).AR.X(f);
                                          plat(j).AR.Y(f);
                                          plat(j).AR.Z(f);
                                                        1];
        W2P_PlatPos(j).AR.X(f) = PlatARXform(1);
        W2P_PlatPos(j).AR.Y(f) = PlatARXform(2);
        W2P_PlatPos(j).AR.Z(f) = PlatARXform(3);
        % Aft Left:
        PlatALXform = World2Plat_Xform * [plat(j).AL.X(f);
                                          plat(j).AL.Y(f);
                                          plat(j).AL.Z(f);
                                                        1];
        W2P_PlatPos(j).AL.X(f) = PlatALXform(1);
        W2P_PlatPos(j).AL.Y(f) = PlatALXform(2);
        W2P_PlatPos(j).AL.Z(f) = PlatALXform(3);
        % Center: (Should be 0 because its origin)
        PlatCXform = World2Plat_Xform * [plat(j).O.X(f);
                                         plat(j).O.Y(f);
                                         plat(j).O.Z(f);
                                                      1];
        W2P_PlatPos(j).C.X(f) = PlatCXform(1);
        W2P_PlatPos(j).C.Y(f) = PlatCXform(2);
        W2P_PlatPos(j).C.Z(f) = PlatCXform(3);
        % Post:
        PostXform = World2Plat_Xform * [plat(j).Po.X(f);
                                        plat(j).Po.Y(f);
                                        plat(j).Po.Z(f);
                                                      1];
        W2P_PlatPos(j).Po.X(f) = PostXform(1);
        W2P_PlatPos(j).Po.Y(f) = PostXform(2);
        W2P_PlatPos(j).Po.Z(f) = PostXform(3);
        

        % Transform V60 Positions
        % Front Right:
        spotFRXform = World2Plat_Xform * [spot(j).FR.X(f);
                                         spot(j).FR.Y(f);
                                         spot(j).FR.Z(f);
                                                      1];
        W2P_spotPos(j).FR.X(f) = spotFRXform(1);
        W2P_spotPos(j).FR.Y(f) = spotFRXform(2);
        W2P_spotPos(j).FR.Z(f) = spotFRXform(3);
        % Front Left:
        spotFLXform = World2Plat_Xform * [spot(j).FL.X(f);
                                         spot(j).FL.Y(f);
                                         spot(j).FL.Z(f);
                                                      1];
        W2P_spotPos(j).FL.X(f) = spotFLXform(1);
        W2P_spotPos(j).FL.Y(f) = spotFLXform(2);
        W2P_spotPos(j).FL.Z(f) = spotFLXform(3);
        % Aft Right:
        spotARXform = World2Plat_Xform * [spot(j).AR.X(f);
                                         spot(j).AR.Y(f);
                                         spot(j).AR.Z(f);
                                                      1];
        W2P_spotPos(j).AR.X(f) = spotARXform(1);
        W2P_spotPos(j).AR.Y(f) = spotARXform(2);
        W2P_spotPos(j).AR.Z(f) = spotARXform(3);
        % Aft Left:
        spotALXform = World2Plat_Xform * [spot(j).AL.X(f);
                                         spot(j).AL.Y(f);
                                         spot(j).AL.Z(f);
                                                      1];
        W2P_spotPos(j).AL.X(f) = spotALXform(1);
        W2P_spotPos(j).AL.Y(f) = spotALXform(2);
        W2P_spotPos(j).AL.Z(f) = spotALXform(3);
        % Center:
        spotCXform = World2Plat_Xform * [spot(j).O.X(f);
                                        spot(j).O.Y(f);
                                        spot(j).O.Z(f);
                                                    1];
        W2P_spotPos(j).C.X(f) = spotCXform(1);
        W2P_spotPos(j).C.Y(f) = spotCXform(2);
        W2P_spotPos(j).C.Z(f) = spotCXform(3);
        % Wrist:
        WrisXform = World2Plat_Xform * [spot(j).Arm.X(f);
                                        spot(j).Arm.Y(f);
                                        spot(j).Arm.Z(f);
                                                      1];
        W2P_spotPos(j).Arm.X(f) = WrisXform(1);
        W2P_spotPos(j).Arm.Y(f) = WrisXform(2);
        W2P_spotPos(j).Arm.Z(f) = WrisXform(3);



    % Calculate V60 Orientation (Roll/Pitch/Yaw) 
        % Calculate 
        spot_Fx = (W2P_spotPos(j).FR.X(f) + W2P_spotPos(j).FL.X(f))/2;
        spot_Fy = (W2P_spotPos(j).FR.Y(f) + W2P_spotPos(j).FL.Y(f))/2;
        spot_Fz = (W2P_spotPos(j).FR.Z(f) + W2P_spotPos(j).FL.Z(f))/2;

        spot_Ax = (W2P_spotPos(j).AR.X(f) + W2P_spotPos(j).AL.X(f))/2;
        spot_Ay = (W2P_spotPos(j).AR.Y(f) + W2P_spotPos(j).AL.Y(f))/2;
        spot_Az = (W2P_spotPos(j).AR.Z(f) + W2P_spotPos(j).AL.Z(f))/2;

        spot_Rz = (W2P_spotPos(j).FR.Z(f) + W2P_spotPos(j).AR.Z(f))/2;
        spot_Rx = (W2P_spotPos(j).FR.X(f) + W2P_spotPos(j).AR.X(f))/2;

        spot_Lz = (W2P_spotPos(j).FL.Z(f) + W2P_spotPos(j).AL.Z(f))/2;
        spot_Lx = (W2P_spotPos(j).FL.X(f) + W2P_spotPos(j).AL.X(f))/2;


        % Calculate Roll (Flat is 0, Right side down is positive)
        Roll_C2L = atan((spot_Lz - W2P_spotPos(j).C.Z(f))/ ...
                        (spot_Lx - W2P_spotPos(j).C.X(f)));
        Roll_R2C = atan((W2P_spotPos(j).C.Z(f) - spot_Rz)/ ...
                        (W2P_spotPos(j).C.X(f) - spot_Rx));
        Roll_R2L = atan((spot_Lz - spot_Rz)/ ...
                        (spot_Lx - spot_Rx));
        W2P_spotPos(j).Roll(f) = (Roll_R2C + Roll_C2L + Roll_R2L)/3;


        % Calculate Pitch (Flat is 0, Front up is positive)
        Pitch_C2F = atan((spot_Fz - W2P_spotPos(j).C.Z(f))/ ...
                         (spot_Fy - W2P_spotPos(j).C.Y(f)));
        Pitch_A2C = atan((W2P_spotPos(j).C.Z(f) - spot_Az)/ ...
                         (W2P_spotPos(j).C.Y(f) - spot_Ay));
        Pitch_A2F = atan((spot_Fz - spot_Az)/ ...
                         (spot_Fy - spot_Ay));
        W2P_spotPos(j).Pitch(f) = (Pitch_A2C + Pitch_C2F + Pitch_A2F)/3;
        

        % Calculate Yaw (facing Y-axis is 0 degrees, left is pos, right is neg)
        Yaw_C2F = atan((W2P_spotPos(j).C.X(f) - spot_Fx)/ ...
                       (W2P_spotPos(j).C.Y(f) - spot_Fy));
        Yaw_A2C = atan((spot_Ax - W2P_spotPos(j).C.X(f))/ ...
                       (spot_Ay - W2P_spotPos(j).C.Y(f)));
        Yaw_A2F = atan((spot_Ax - spot_Fx)/ ...
                       (spot_Ay - spot_Fy));
        W2P_spotPos(j).Yaw(f) = (Yaw_A2C + Yaw_C2F + Yaw_A2F)/3;
    end

%     figure
%     plot(W2P_PlatPos(j).C.X, W2P_PlatPos(j).C.Z)
%     xlabel('x')
%     ylabel('z')
%     figure
%     plot(W2P_PlatPos(j).C.Y, W2P_PlatPos(j).C.Z)
%     xlabel('y')
%     ylabel('z')
%     figure
%     plot(W2P_PlatPos(j).C.X, W2P_PlatPos(j).C.Y)
%     xlabel('x')
%     ylabel('y')

    % finds max and min X, Y, and Z values within treadmill frame
    maxXD = max(W2P_spotPos(j).C.X);
    maxYD = max(W2P_spotPos(j).C.Y);
    maxZD = max(W2P_spotPos(j).C.Z);
    minXD = min(W2P_spotPos(j).C.X);
    minYD = min(W2P_spotPos(j).C.Y);
    minZD = min(W2P_spotPos(j).C.Z);

    if maxXD > maxX
        maxX = maxXD;
    end
    if maxYD > maxY
        maxY = maxYD;
    end
    if maxZD > maxZ
        maxZ = maxZD;
    end
    if minXD < minX
        minX = minXD;
    end
    if minYD < minY
        minY = minYD;
    end
    if minZD < minZ
        minZ = minZD;
    end
end
minMax.minX = minX;
minMax.maxX = maxX;
minMax.minY = minY;
minMax.maxY = maxY;
minMax.minZ = minZ;
minMax.maxZ = maxZ;

%% Displacement
% Plots center of spot XYZ position displacement from starting point in the
% treadmill frame. Plots XZ over time and total displacement from
% starting point and total displacement from center of platform. Also plots
% wrist position wrt post
for j = 1:size(plat,2)
% for j = 1
    % Calculate Distance between Post and Arm
    armDistX = abs(W2P_PlatPos(j).Po.X - W2P_spotPos(j).Arm.X);
    armDistY = abs(W2P_PlatPos(j).Po.Y - W2P_spotPos(j).Arm.Y);
    armDistZ = abs(W2P_PlatPos(j).Po.Z - W2P_spotPos(j).Arm.Z);
    % Initialize
    W2P_spotPos(j).armDistEucl = zeros(1, size(armDistX, 1));
    
    for i = 1:size(plat(j).Po.X, 1)
        W2P_spotPos(j).armDistEucl(i) = sqrt(armDistX(i)^2 + armDistY(i)^2 + armDistZ(i)^2);
    end
    
    % Function to plot spot disp
    W2P_spotPos(j).Disp = plotSpotXYZ_Disp(W2P_spotPos(j), W2P_PlatPos(j), plat(j).test, test(j*2));
    
%     maxArmDist = max([max(armDistX), max(armDistY), max(armDistZ), max(armDistEucl)]);
%     minArmDist = min([min(armDistX), min(armDistY), min(armDistZ), min(armDistEucl)]);
%     
%     figure(j+7)
%     
%     subplot(4, 1, 1)
%     plot(spot(j).time, armDistX)
%     % ylim([minArmDist, maxArmDist])
%     title('X')
%     ylabel('Distance [mm]')
%     xlabel('Time [s]')
%     
%     subplot(4, 1, 2)
%     plot(spot(j).time, armDistY)
%     % ylim([minArmDist, maxArmDist])
%     title('Y')
%     ylabel('Dist [mm]')
%     xlabel('Time [s]')
%     
%     subplot(4, 1, 3)
%     plot(spot(j).time, armDistZ)
%     % ylim([minArmDist, maxArmDist])
%     title('Z')
%     ylabel('Dist [mm]')
%     xlabel('Time [s]')
%     
%     subplot(4, 1, 4)
%     plot(spot(j).time, armDistEucl)
%     % ylim([minArmDist, maxArmDist])
%     title('Euclidean')
%     ylabel('Dist [mm]')
%     xlabel('Time [s]')
%     
%     sgtitle(strcat('Wrist Distance from Tag -Trial:  ', plat(j).test))
% 
%     saveName = strcat(filePath, test(j*3), '_wristDist');
%     saveas(j+7, saveName, 'jpg')
end

%% Support Polygon
% Approximate center of mass location in World frame, not platform frame
% masses in grams
bodyMass = 14*1000;
xHipMass = 1070;
yHipMass = 1027;
legMass  = 1705;
shouldrM = 2050;
baseMass = 4646 - 2050;
foreAMas = 1450;
wristMas = 980;
griprMas = 785;

legLength = 355; % mm
shouldrMidBase2Front = 165; % mm
shouldrBottom2Mid = 115; % mm

totlMass = bodyMass + xHipMass*4 + yHipMass*4 + legMass*4 + shouldrM + ...
    baseMass + foreAMas + wristMas + griprMas;
bodyCombinedMass = bodyMass + xHipMass*4 + yHipMass*4 + baseMass;
armCombinedMass  = shouldrM + foreAMas + wristMas + griprMas;

minCoMDist = 1000;
smallestMinCoMDist = 1000;

largestRangeZ_World = 0;
largestRangeX_World = 0;
largestRangeZ_Robot = 0;
largestRangeX_Robot = 0;

largestStdevZ_World = 0;
largestStdevX_World = 0;
largestStdevZ_Robot = 0;
largestStdevX_Robot = 0;

for j=52 %jB-2-2
%for j=14 %B-2-4
%for j=34 %jA-1-4
%for j = 1:size(plat,2)      % Cycle tests
    % Because the hip motors are equally placed on Spot, body CoM is unknown,
    %    hip masses are combined with the body
    centerMass(j).body.X = spot(j).O.X;
    centerMass(j).body.Y = spot(j).O.Y;
    centerMass(j).body.Z = spot(j).O.Z;

%     for f = 1:size(plat(j).time, 1) % Cycle Frames
        % Leg masses will be individually approximated to be halfway between toe 
        %    and body markers and set halfway of leg link length to the rear
        centerMass(j).leg.FR.X = (spot(j).FR_leg.X + spot(j).FR.X)/2;
        centerMass(j).leg.FR.Y = (spot(j).FR_leg.Y + spot(j).FR.Y)/2;
        centerMass(j).leg.FR.Z = (spot(j).FR_leg.Z + spot(j).FR.Z)/2;

        centerMass(j).leg.FL.X = (spot(j).FL_leg.X + spot(j).FL.X)/2;
        centerMass(j).leg.FL.Y = (spot(j).FL_leg.Y + spot(j).FL.Y)/2;
        centerMass(j).leg.FL.Z = (spot(j).FL_leg.Z + spot(j).FL.Z)/2;

        centerMass(j).leg.AR.X = (spot(j).AR_leg.X + spot(j).AR.X)/2;
        centerMass(j).leg.AR.Y = (spot(j).AR_leg.Y + spot(j).AR.Y)/2;
        centerMass(j).leg.AR.Z = (spot(j).AR_leg.Z + spot(j).AR.Z)/2;

        centerMass(j).leg.AL.X = (spot(j).AL_leg.X + spot(j).AL.X)/2;
        centerMass(j).leg.AL.Y = (spot(j).AL_leg.Y + spot(j).AL.Y)/2;
        centerMass(j).leg.AL.Z = (spot(j).AL_leg.Z + spot(j).AL.Z)/2;

        % Shoulder base mass position measured to be behind and above front
%         centerMass(j).base.X = ;
%         centerMass(j).base.Y = ;
%         centerMass(j).base.Z = ;
        
        % Arm Mass is between front and gripper
        centerMass(j).arm.X = (((spot(j).FL.X + spot(j).FR.X)./2) + spot(j).Arm.X)./2;
        centerMass(j).arm.Y = (((spot(j).FL.Y + spot(j).FR.Y)./2) + spot(j).Arm.Y)./2;
        centerMass(j).arm.Z = (((spot(j).FL.Z + spot(j).FR.Z)./2) + spot(j).Arm.Z)./2;
%     end
        % Using weighted average to calc CoM XYZ
        bodyCoMx = bodyCombinedMass*centerMass(j).body.X;
        armCoMx  =  armCombinedMass*centerMass(j).arm.X;
        FLLCoMx  =  legMass*spot(j).FL_leg.X;
        FRLCoMx  =  legMass*spot(j).FR_leg.X;
        ALLCoMx  =  legMass*spot(j).AL_leg.X;
        ARLCoMx  =  legMass*spot(j).AR_leg.X;

        bodyCoMy = bodyCombinedMass*centerMass(j).body.Y;
        armCoMy  =  armCombinedMass*centerMass(j).arm.Y;
        FLLCoMy  =  legMass*spot(j).FL_leg.Y;
        FRLCoMy  =  legMass*spot(j).FR_leg.Y;
        ALLCoMy  =  legMass*spot(j).AL_leg.Y;
        ARLCoMy  =  legMass*spot(j).AR_leg.Y;

        bodyCoMz = bodyCombinedMass*centerMass(j).body.Z;
        armCoMz  =  armCombinedMass*centerMass(j).arm.Z;
        FLLCoMz  =  legMass*spot(j).FL_leg.Z;
        FRLCoMz  =  legMass*spot(j).FR_leg.Z;
        ALLCoMz  =  legMass*spot(j).AL_leg.Z;
        ARLCoMz  =  legMass*spot(j).AR_leg.Z;

    centerMass(j).CoM.X = ...
        (bodyCoMx + armCoMx + FLLCoMx + FRLCoMx + ALLCoMx + ARLCoMx)/totlMass;
    centerMass(j).CoM.Y = ...
        (bodyCoMy + armCoMy + FLLCoMy + FRLCoMy + ALLCoMy + ARLCoMy)/totlMass;
    centerMass(j).CoM.Z = ...
        (bodyCoMz + armCoMz + FLLCoMz + FRLCoMz + ALLCoMz + ARLCoMz)/totlMass;

    supportPolygon(j) = plotSupportPolygon(spot(j), centerMass(j).CoM,...
                        'Spot', "../pictures/newSupportPolygon/", test(j*2));

    if supportPolygon(j).absMinDist < minCoMDist
        minCoMDist = supportPolygon(j).absMinDist;
        minCoMDist_test = j;
    end
    if supportPolygon(j).aveMinDist < smallestMinCoMDist
        smallestMinCoMDist = supportPolygon(j).aveMinDist;
        smallestMinCoMDist_test = j;
    end
    
    %
    if supportPolygon(j).rangeZ_Robot > largestRangeZ_Robot
        largestRangeZ_Robot = supportPolygon(j).rangeZ_Robot;
        largestRangeZ_Robot_test = j;
    end
    if supportPolygon(j).rangeX_Robot > largestRangeX_Robot
        largestRangeX_Robot = supportPolygon(j).rangeX_Robot;
        largestRangeX_Robot_test = j;
    end
    if supportPolygon(j).rangeZ_world > largestRangeZ_World
        largestRangeZ_World = supportPolygon(j).rangeZ_world;
        largestRangeZ_World_test = j;
    end
    if supportPolygon(j).rangeX_world > largestRangeX_World
        largestRangeX_World = supportPolygon(j).rangeX_world;
        largestRangeX_World_test = j;
    end
    
    %
    if supportPolygon(j).stdevZ_Robot > largestStdevZ_Robot
        largestStdevZ_Robot = supportPolygon(j).stdevZ_Robot;
        largestStdevZ_Robot_test = j;
    end
    if supportPolygon(j).stdevX_Robot > largestStdevX_Robot
        largestStdevX_Robot = supportPolygon(j).stdevX_Robot;
        largestStdevX_Robot_test = j;
    end
    if supportPolygon(j).stdevZ_world > largestStdevZ_World
        largestStdevZ_World = supportPolygon(j).stdevZ_world;
        largestStdevZ_World_test = j;
    end
    if supportPolygon(j).stdevX_world > largestStdevX_World
        largestStdevX_World = supportPolygon(j).stdevX_world;
        largestStdevX_World_test = j;
    end
end
fprintf(strcat("Smallest CoM Dist is: test ",num2str(minCoMDist_test),"(", test(minCoMDist_test*2), ")\n"))
fprintf(strcat("Smallest ave CoM Dist is: test ",num2str(smallestMinCoMDist_test),"(", test(smallestMinCoMDist_test*2), ")\n"))


fprintf(strcat("Largest CoM World Z Range is: test ",num2str(largestRangeZ_World_test),"(", test(largestRangeZ_World_test*2), ")\n"))
fprintf(strcat("Largest CoM World X Range is: test ",num2str(largestRangeX_World_test),"(", test(largestRangeX_World_test*2), ")\n"))

fprintf(strcat("Largest CoM Z Range wrt Robot: test ",num2str(largestRangeZ_Robot_test),"(", test(largestRangeZ_Robot_test*2), ")\n"))
fprintf(strcat("Largest CoM X Range wrt Robot: test ",num2str(largestRangeX_Robot_test),"(", test(largestRangeX_Robot_test*2), ")\n"))


fprintf(strcat("Largest CoM World Z StDev is: test ",num2str(largestStdevZ_World_test),"(", test(largestStdevZ_World_test*2), ")\n"))
fprintf(strcat("Largest CoM World X StDev is: test ",num2str(largestStdevX_World_test),"(", test(largestStdevX_World_test*2), ")\n"))

fprintf(strcat("Largest CoM Z Range wrt StDev: test ",num2str(largestStdevZ_Robot_test),"(", test(largestStdevZ_Robot_test*2), ")\n"))
fprintf(strcat("Largest CoM X Range wrt StDev: test ",num2str(largestStdevX_Robot_test),"(", test(largestStdevX_Robot_test*2), ")\n"))


%% Set Up Box Plots
testNames = ["spot_baseline";
             "BothDRS_Motion1";
             "BothDRS_Motion2";
             "BothDRS_Motion3";
             "JustArm_Motion1";
             "JustArm_Motion2";
             "JustArm_Motion3";
             "JustBody_Motion1";
             "JustBody_Motion2";
             "JustBody_Motion3"];
spotNames = ["spot_baseline"
             "spot_Both_Motion_1";
             "spot_Both_Motion_2";
             "spot_Both_Motion_3";
             "spot_justArm_Motion_1";
             "spot_justArm_Motion_2";
             "spot_justArm_Motion_3";
             "spot_justBody_Motion_1";
             "spot_justBody_Motion_2";
             "spot_justBody_Motion_3"];
abvNames  = ["Base"
             "Both1";
             "Both2";
             "Both3";
             "Arm1";
             "Arm2";
             "Arm3";
             "Legs1";
             "Legs2";
             "Legs3"];

% init Names and disp vectors
for n = 1:size(spotNames,1)
    testDisp(n).name = spotNames(n);
    testDisp(n).dispX  = 0;
    testDisp(n).dispY  = 0;
    testDisp(n).roll  = 0;
    testDisp(n).pitch = 0;
    testDisp(n).yaw   = 0;
    testDisp(n).CoM   = 0;

    testDisp(n).rangeXWorl = 0;
    testDisp(n).rangeZWorl = 0;
    testDisp(n).rangeXRobo = 0;
    testDisp(n).rangeZRobo = 0;

    testDisp(n).stdevXWorl = 0;
    testDisp(n).stdevZWorl = 0;
    testDisp(n).stdevXRobo = 0;
    testDisp(n).stdevZRobo = 0;
end

% Concate values into a single row between trials and place into struct
for j = 1:size(W2P_spotPos,2)   % Cycle through each test
    for n = 1:size(spotNames,1) % Cycle through test Names
        if contains(W2P_spotPos(j).test, spotNames(n)) % Concatate data if test has same test name
            testDisp(n).dispX  = [testDisp(n).dispX,  W2P_spotPos(j).Disp.X];
            testDisp(n).dispY  = [testDisp(n).dispY,  W2P_spotPos(j).Disp.Y];
            testDisp(n).roll  = [testDisp(n).roll,  W2P_spotPos(j).Roll];
            testDisp(n).pitch = [testDisp(n).pitch, W2P_spotPos(j).Pitch];
            testDisp(n).yaw   = [testDisp(n).yaw,   W2P_spotPos(j).Yaw];
            testDisp(n).CoM   = [testDisp(n).CoM,   supportPolygon(j).minCoMDist];

            testDisp(n).rangeXWorl = [testDisp(n).rangeXWorl,   supportPolygon(j).rangeX_world];
            testDisp(n).rangeZWorl = [testDisp(n).rangeZWorl,   supportPolygon(j).rangeZ_world];
            testDisp(n).rangeXRobo = [testDisp(n).rangeXRobo,   supportPolygon(j).rangeX_Robot];
            testDisp(n).rangeZRobo = [testDisp(n).rangeZRobo,   supportPolygon(j).rangeZ_Robot];

            testDisp(n).stdevXWorl = [testDisp(n).stdevXWorl,   supportPolygon(j).stdevX_world];
            testDisp(n).stdevZWorl = [testDisp(n).stdevZWorl,   supportPolygon(j).stdevZ_world];
            testDisp(n).stdevXRobo = [testDisp(n).stdevXRobo,   supportPolygon(j).stdevX_Robot];
            testDisp(n).stdevZRobo = [testDisp(n).stdevZRobo,   supportPolygon(j).stdevZ_Robot];
        end
    end
end

% Remove initial 0 from data otherwise it will mess it up
for n = 1:size(spotNames,1)
    testDisp(n).dispX  = testDisp(n).dispX(2:end);
    testDisp(n).dispY  = testDisp(n).dispY(2:end);
    testDisp(n).roll  = testDisp(n).roll(2:end);
    testDisp(n).pitch = testDisp(n).pitch(2:end);
    testDisp(n).yaw   = testDisp(n).yaw(2:end);
    testDisp(n).CoM   = testDisp(n).CoM(2:end);

    testDisp(n).rangeXWorl = testDisp(n).rangeXWorl(2:end);
    testDisp(n).rangeZWorl = testDisp(n).rangeZWorl(2:end);
    testDisp(n).rangeXRobo = testDisp(n).rangeXRobo(2:end);
    testDisp(n).rangeZRobo = testDisp(n).rangeZRobo(2:end);

    testDisp(n).stdevXWorl = testDisp(n).stdevXWorl(2:end);
    testDisp(n).stdevZWorl = testDisp(n).stdevZWorl(2:end);
    testDisp(n).stdevXRobo = testDisp(n).stdevXRobo(2:end);
    testDisp(n).stdevZRobo = testDisp(n).stdevZRobo(2:end);
end

% Determine max row length
maxLength = 0;
for n = 1:size(spotNames,1)
    if length(testDisp(n).dispX) > maxLength
        maxLength = length(testDisp(n).dispX);
    end
end

% Create Matrix consisting of rows for each test type and motion
spot_DisplacementX = nan(maxLength, size(spotNames,1));
spot_DisplacementY = nan(maxLength, size(spotNames,1));
spot_Roll =  nan(maxLength, size(spotNames,1));
spot_Pitch = nan(maxLength, size(spotNames,1));
spot_Yaw =   nan(maxLength, size(spotNames,1));
spot_CoMDist =   nan(maxLength, size(spotNames,1));

v60_CoMRangeXW =      nan(maxLength, size(testNames,1));
v60_CoMRangeZW =      nan(maxLength, size(testNames,1));
v60_CoMRangeXR =      nan(maxLength, size(testNames,1));
v60_CoMRangeZR =      nan(maxLength, size(testNames,1));

v60_CoMStdevXW =      nan(maxLength, size(testNames,1));
v60_CoMStdevZW =      nan(maxLength, size(testNames,1));
v60_CoMStdevXR =      nan(maxLength, size(testNames,1));
v60_CoMStdevZR =      nan(maxLength, size(testNames,1));
for n = 1:size(spotNames,1)
    spot_DisplacementX(1:length(testDisp(n).dispX), n) = testDisp(n).dispX;
    spot_DisplacementY(1:length(testDisp(n).dispY), n) = testDisp(n).dispY;
    spot_Roll(1:length(testDisp(n).roll), n)   = testDisp(n).roll;
    spot_Pitch(1:length(testDisp(n).pitch), n) = testDisp(n).pitch;
    spot_Yaw(1:length(testDisp(n).yaw), n)     = testDisp(n).yaw;
    spot_CoMDist(1:length(testDisp(n).CoM), n) = testDisp(n).CoM;

    v60_CoMRangeXW(1:length(testDisp(n).rangeXWorl), n) = testDisp(n).rangeXWorl;
    v60_CoMRangeZW(1:length(testDisp(n).rangeZWorl), n) = testDisp(n).rangeZWorl;
    v60_CoMRangeXR(1:length(testDisp(n).rangeXRobo), n) = testDisp(n).rangeXRobo;
    v60_CoMRangeZR(1:length(testDisp(n).rangeZRobo), n) = testDisp(n).rangeZRobo;

    v60_CoMStdevXW(1:length(testDisp(n).stdevXWorl), n) = testDisp(n).stdevXWorl;
    v60_CoMStdevZW(1:length(testDisp(n).stdevZWorl), n) = testDisp(n).stdevZWorl;
    v60_CoMStdevXR(1:length(testDisp(n).stdevXRobo), n) = testDisp(n).stdevXRobo;
    v60_CoMStdevZR(1:length(testDisp(n).stdevZRobo), n) = testDisp(n).stdevZRobo;
end

%% Box Plotting
fig = figure(WindowState="maximized");
tiledlayout(2,1, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(spot_DisplacementX, testNames, "Whisker",15)
title('Spot Concatenated X-Displacements by Experiment Type and Motion')
ylabel('X-Displacement [mm]')

nexttile
boxplot(spot_DisplacementY, testNames, "Whisker",15)
title('Spot Concatenated Y-Displacements by Experiment Type and Motion')
ylabel('Y-Displacement [mm]')

saveName = "../pictures/spotConcatenatedDisplacements";
saveas(fig, saveName, 'jpg')
% close

maxStDevX = 0;
for b = 1:size(plat,2)
    if W2P_spotPos(b).Disp.std.X > maxStDevX
        maxStDevX = W2P_spotPos(b).Disp.std.X;
        maxStDevTestX = W2P_spotPos(b).test;
    end
end
fprintf(strcat(maxStDevTestX," has largest X Displacement StDev \n"))

maxStDevY = 0;
for b = 1:size(plat,2)
    if W2P_spotPos(b).Disp.std.Y > maxStDevY
        maxStDevY = W2P_spotPos(b).Disp.std.Y;
        maxStDevTestY = W2P_spotPos(b).test;
    end
end
fprintf(strcat(maxStDevTestY," has largest Y Displacement StDev \n"))

%======================================================================

fig2 = figure(WindowState="maximized");
tiledlayout(3,1, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(spot_Roll, abvNames, "Whisker",15)
ylabel('Angle [rads]')
%ylim([-pi/2, pi/2])
title('Roll')
nexttile
boxplot(spot_Pitch, abvNames, "Whisker",15)
ylabel('Angle [rads]')
%ylim([-pi/2, pi/2])
title('Pitch')
nexttile
boxplot(spot_Yaw, abvNames, "Whisker",15)
ylabel('Angle [rads]')
%ylim([-pi/2, pi/2])
title('Yaw')

sgtitle('Spot Concatenated Orientations by Experiment Type and Motion')
saveName = "../pictures/spotConcatOrientations";
saveas(fig2, saveName, 'jpg')

% =========================================================================

fig3 = figure(WindowState="maximized");
boxplot(spot_CoMDist, testNames, "Whisker",15)
title('Spot Concatenated CoM Distance from Support Polygon by Experiment Type and Motion')
ylabel('Distance [mm]')

saveName = "../pictures/spotConcatenatedSupportPolygonCoMDistance";
saveas(fig3, saveName, 'jpg')

% =======================================================================

fig4 = figure(WindowState="maximized");
tiledlayout(2,1, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(v60_CoMRangeXW, abvNames, "Whisker",15)
ylabel('Range [mm]')
%ylim([-pi/2, pi/2])
title('CoM X Range')
nexttile
boxplot(v60_CoMRangeZW, abvNames, "Whisker",15)
ylabel('Range [mm]')
%ylim([-pi/2, pi/2])
title('CoM Z Range')

sgtitleName = 'Spot Concatenated CoM Range wrt World by Experiment Type and Motion';
subName = strcat("Largest X Range: ", num2str(largestRangeX_World), "  |  Largest Z Range: ", num2str(largestRangeZ_World));
sgtitle({['{\bf\fontsize{14}' sgtitleName '}'],subName});
saveName = "../pictures/spotCoMRangeWorl";
saveas(fig4, saveName, 'jpg')

% =====================================================================

fig5 = figure(WindowState="maximized");
tiledlayout(2,1, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(v60_CoMRangeXR, abvNames, "Whisker",15)
ylabel('Range [mm]')
%ylim([-pi/2, pi/2])
title('CoM X Range')
nexttile
boxplot(v60_CoMRangeZR, abvNames, "Whisker",15)
ylabel('Range [mm]')
%ylim([-pi/2, pi/2])
title('CoM Z Range')

sgtitleName = 'Spot Concatenated CoM Range wrt Robot by Experiment Type and Motion';
subName = strcat("Largest X Range: ", num2str(largestRangeX_Robot), "  |  Largest Z Range: ", num2str(largestRangeZ_Robot));
sgtitle({['{\bf\fontsize{14}' sgtitleName '}'],subName});
saveName = "../pictures/spotCoMRangeRobo";
saveas(fig5, saveName, 'jpg')

% =======================================================================

fig6 = figure(WindowState="maximized");
tiledlayout(2,1, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(v60_CoMStdevXW, abvNames, "Whisker",15)
ylabel('StDev [mm]')
%ylim([-pi/2, pi/2])
title('CoM X StDev')
nexttile
boxplot(v60_CoMStdevZW, abvNames, "Whisker",15)
ylabel('StDev [mm]')
%ylim([-pi/2, pi/2])
title('CoM Z StDev')

sgtitleName = 'Spot Concatenated CoM Standard Deviation wrt World by Experiment Type and Motion';
subName = strcat("Largest X StDev: ", num2str(largestStdevX_World), "  |  Largest Z StDev: ", num2str(largestStdevZ_World));
sgtitle({['{\bf\fontsize{14}' sgtitleName '}'],subName});
saveName = "../pictures/spotCoMStdevWorl";
saveas(fig6, saveName, 'jpg')

% =====================================================================

fig7 = figure(WindowState="maximized");
tiledlayout(2,1, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(v60_CoMStdevXR, abvNames, "Whisker",15)
ylabel('StDev [mm]')
%ylim([-pi/2, pi/2])
title('CoM X StDev')
nexttile
boxplot(v60_CoMStdevZR, abvNames, "Whisker",15)
ylabel('StDev [mm]')
%ylim([-pi/2, pi/2])
title('CoM Z StDev')

sgtitleName = 'Spot Concatenated CoM Standard Deviation wrt Robot by Experiment Type and Motion';
subName = strcat("Largest X StDev: ", num2str(largestStdevX_Robot), "  |  Largest Z StDev: ", num2str(largestStdevZ_Robot));
sgtitle({['{\bf\fontsize{14}' sgtitleName '}'],subName});
saveName = "../pictures/spotCoMStdevRobo";
saveas(fig7, saveName, 'jpg')






