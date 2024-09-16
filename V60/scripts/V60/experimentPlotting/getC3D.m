clc; clearvars; close all;

%{
    This code gathers the .txt files from the .trc files which were
    generated from the Motion Capture Program. The '-platform' and '-v60'
    specific files are put into a table using readtable() and are then sent
    to 'getPlatMoCap.m' and 'getV60MoCap.m', respectively, which arranges
    the table data into a struct for ease of use.

    Plots of V60 displacement and wrist distance from post are then
    generated.

    This code requires 'trc2txt.m' to be run first.
%}

filePath = '../../../run_Data/v60_data/All_TRC_Files/';
txtFiles = dir(strcat(filePath, '*.txt'));

test(size(txtFiles,1),1) = string();   % init
for i = 1:size(txtFiles,1)
    test(i, 1) = string(extractBetween(txtFiles(i).name, '', '-'));
end

nTests = size(txtFiles,1);

%% Get trc data
for k = 1:2:nTests
    platPath = strcat(filePath, test(k), '-platform.txt');
    v60Path  = strcat(filePath, test(k), '-v60.txt');

    platform = readtable(platPath);
    vision60 = readtable(v60Path);
    
    % Puts table data into struct format
    plat((k+1)/2) = getPlatMoCap(platform);
    v60((k+1)/2)  = getV60MoCap(vision60);
end

%% Find platform and base center and base angle
for j = 1:size(plat,2)
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
    vRX = (v60(j).FR.X + v60(j).AR.X)/2;
    vLX = (v60(j).FL.X + v60(j).AL.X)/2;
    v60(j).O.X = (vRX + vLX)/2;

    vRY = (v60(j).FR.Y + v60(j).AR.Y)/2;
    vLY = (v60(j).FL.Y + v60(j).AL.Y)/2;
    v60(j).O.Y = (vRY + vLY)/2;

    vRZ = (v60(j).FR.Z + v60(j).AR.Z)/2;
    vLZ = (v60(j).FL.Z + v60(j).AL.Z)/2;
    v60(j).O.Z = (vRZ + vLZ)/2;

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



%% Calculate Transforms
maxX = 0;
minX = 0;
maxY = 0;
minY = 0;
maxZ = 0;
minZ = 0;
W2P_PlatPos(nTests/2) = struct();
W2P_V60Pos(nTests/2)  = struct();

for j = 1:size(plat,2)      % Cycle tests
% for j = 1
    W2P_V60Pos(j).test = test(j*2);

    for f = 1:size(plat(j).time, 1) % Cycle Frames
        % Copy Times
        W2P_PlatPos(j).time = plat(j).time;
        W2P_V60Pos(j).time  =  v60(j).time;

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
        V60FRXform = World2Plat_Xform * [v60(j).FR.X(f);
                                         v60(j).FR.Y(f);
                                         v60(j).FR.Z(f);
                                                      1];
        W2P_V60Pos(j).FR.X(f) = V60FRXform(1);
        W2P_V60Pos(j).FR.Y(f) = V60FRXform(2);
        W2P_V60Pos(j).FR.Z(f) = V60FRXform(3);
        % Front Left:
        V60FLXform = World2Plat_Xform * [v60(j).FL.X(f);
                                         v60(j).FL.Y(f);
                                         v60(j).FL.Z(f);
                                                      1];
        W2P_V60Pos(j).FL.X(f) = V60FLXform(1);
        W2P_V60Pos(j).FL.Y(f) = V60FLXform(2);
        W2P_V60Pos(j).FL.Z(f) = V60FLXform(3);
        % Aft Right:
        V60ARXform = World2Plat_Xform * [v60(j).AR.X(f);
                                         v60(j).AR.Y(f);
                                         v60(j).AR.Z(f);
                                                      1];
        W2P_V60Pos(j).AR.X(f) = V60ARXform(1);
        W2P_V60Pos(j).AR.Y(f) = V60ARXform(2);
        W2P_V60Pos(j).AR.Z(f) = V60ARXform(3);
        % Aft Left:
        V60ALXform = World2Plat_Xform * [v60(j).AL.X(f);
                                         v60(j).AL.Y(f);
                                         v60(j).AL.Z(f);
                                                      1];
        W2P_V60Pos(j).AL.X(f) = V60ALXform(1);
        W2P_V60Pos(j).AL.Y(f) = V60ALXform(2);
        W2P_V60Pos(j).AL.Z(f) = V60ALXform(3);
        % Center:
        V60CXform = World2Plat_Xform * [v60(j).O.X(f);
                                        v60(j).O.Y(f);
                                        v60(j).O.Z(f);
                                                    1];
        W2P_V60Pos(j).C.X(f) = V60CXform(1);
        W2P_V60Pos(j).C.Y(f) = V60CXform(2);
        W2P_V60Pos(j).C.Z(f) = V60CXform(3);
        % Wrist:
        WrisXform = World2Plat_Xform * [v60(j).Arm.X(f);
                                        v60(j).Arm.Y(f);
                                        v60(j).Arm.Z(f);
                                                      1];
        W2P_V60Pos(j).Arm.X(f) = WrisXform(1);
        W2P_V60Pos(j).Arm.Y(f) = WrisXform(2);
        W2P_V60Pos(j).Arm.Z(f) = WrisXform(3);

    % Calculate V60 Orientation (Roll/Pitch/Yaw) 
        % Calculate 
        V60_Fx = (W2P_V60Pos(j).FR.X(f) + W2P_V60Pos(j).FL.X(f))/2;
        V60_Fy = (W2P_V60Pos(j).FR.Y(f) + W2P_V60Pos(j).FL.Y(f))/2;
        V60_Fz = (W2P_V60Pos(j).FR.Z(f) + W2P_V60Pos(j).FL.Z(f))/2;
        V60_Ax = (W2P_V60Pos(j).AR.X(f) + W2P_V60Pos(j).AL.X(f))/2;
        V60_Ay = (W2P_V60Pos(j).AR.Y(f) + W2P_V60Pos(j).AL.Y(f))/2;
        V60_Az = (W2P_V60Pos(j).AR.Z(f) + W2P_V60Pos(j).AL.Z(f))/2;
        V60_Rz = (W2P_V60Pos(j).FR.Z(f) + W2P_V60Pos(j).AR.Z(f))/2;
        V60_Rx = (W2P_V60Pos(j).FR.X(f) + W2P_V60Pos(j).AR.X(f))/2;
        V60_Lz = (W2P_V60Pos(j).FL.Z(f) + W2P_V60Pos(j).AL.Z(f))/2;
        V60_Lx = (W2P_V60Pos(j).FL.X(f) + W2P_V60Pos(j).AL.X(f))/2;

        % Calculate Roll (Flat is 0, Right side down is positive)
        Roll_C2L = atan((V60_Lz - W2P_V60Pos(j).C.Z(f))/ ...
                        (V60_Lx - W2P_V60Pos(j).C.X(f)));
        Roll_R2C = atan((W2P_V60Pos(j).C.Z(f) - V60_Rz)/ ...
                        (W2P_V60Pos(j).C.X(f) - V60_Rx));
        Roll_R2L = atan((V60_Lz - V60_Rz)/ ...
                        (V60_Lx - V60_Rx));
        W2P_V60Pos(j).Roll(f) = (Roll_R2C + Roll_C2L + Roll_R2L)/3;

        % Calculate Pitch (Flat is 0, Front up is positive)
        Pitch_C2F = atan((V60_Fz - W2P_V60Pos(j).C.Z(f))/ ...
                         (V60_Fy - W2P_V60Pos(j).C.Y(f)));
        Pitch_A2C = atan((W2P_V60Pos(j).C.Z(f) - V60_Az)/ ...
                         (W2P_V60Pos(j).C.Y(f) - V60_Ay));
        Pitch_A2F = atan((V60_Fz - V60_Az)/ ...
                         (V60_Fy - V60_Ay));
        W2P_V60Pos(j).Pitch(f) = (Pitch_A2C + Pitch_C2F + Pitch_A2F)/3;
        
        % Calculate Yaw (facing Y-axis is 0 degrees, left is pos, right is neg)
        Yaw_C2F = atan((W2P_V60Pos(j).C.X(f) - V60_Fx)/ ...
                       (W2P_V60Pos(j).C.Y(f) - V60_Fy));
        Yaw_A2C = atan((V60_Ax - W2P_V60Pos(j).C.X(f))/ ...
                       (V60_Ay - W2P_V60Pos(j).C.Y(f)));
        Yaw_A2F = atan((V60_Ax - V60_Fx)/ ...
                       (V60_Ay - V60_Fy));
        W2P_V60Pos(j).Yaw(f) = (Yaw_A2C + Yaw_C2F + Yaw_A2F)/3;
    end

    % finds max and min X, Y, and Z values within treadmill frame
    maxXD = max(W2P_V60Pos(j).C.X);
    maxYD = max(W2P_V60Pos(j).C.Y);
    maxZD = max(W2P_V60Pos(j).C.Z);
    minXD = min(W2P_V60Pos(j).C.X);
    minYD = min(W2P_V60Pos(j).C.Y);
    minZD = min(W2P_V60Pos(j).C.Z);

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
% Plots center of V60 XYZ position displacement from starting point in the
% treadmill frame. Plots XZ over time and total displacement from
% starting point and total displacement from center of platform. Also plots
% wrist position wrt post
for j = 1:size(plat,2)
% for j = 1
    % Calculate Distance between Post and Arm
    armDistX = abs(W2P_PlatPos(j).Po.X - W2P_V60Pos(j).Arm.X);
    armDistY = abs(W2P_PlatPos(j).Po.Y - W2P_V60Pos(j).Arm.Y);
    armDistZ = abs(W2P_PlatPos(j).Po.Z - W2P_V60Pos(j).Arm.Z);
    % Initialize
    W2P_V60Pos(j).armDistEucl = zeros(1, size(armDistX, 1));
    
    for i = 1:size(plat(j).Po.X, 1)
        W2P_V60Pos(j).armDistEucl(i) = sqrt(armDistX(i)^2 + armDistY(i)^2 + armDistZ(i)^2);
    end
    
    % Function to plot V60 disp
    W2P_V60Pos(j).Disp = plotV60XYZ_Disp(W2P_V60Pos(j), W2P_PlatPos(j), plat(j).test, test(j*2));
    
end

%% Support Polygon
% Approximate center of mass location in World frame, not platform frame
% masses in grams
bodyMass = 13.6*1000;
xHipMass = 3.1*1000;
yHipMass = 0.65*1000;
legMass  = 2.75*1000;
baseMass = 0.84924*1000 + 0.46784*1000;
link1n2n3 = (0.7477 + 0.8447 + 0.8447)*1000;
link4n5n6 = (0.6763 + 0.463  + 0.463)*1000;
wristMas = 0.99*1000;
griprMas = (0.01*6)*1000;



totlMass = bodyMass + xHipMass*4 + yHipMass*4 + legMass*4 + link1n2n3 + ...
    baseMass + link4n5n6 + wristMas + griprMas;
bodyCombinedMass = bodyMass + xHipMass*4 + yHipMass*4 + baseMass;
armCombinedMass  = link1n2n3 + link4n5n6 + wristMas + griprMas;

minCoMDist = 1000;
smallestMinCoMDist = 1000;

largestrangeZ_World = 0;
largestrangeX_World = 0;
largestrangeZ_Robot = 0;
largestrangeX_Robot = 0;

largestStdevZ_World = 0;
largestStdevX_World = 0;
largestStdevZ_Robot = 0;
largestStdevX_Robot = 0;

for j=13 %B-2-2
    % Because the hip motors are equally placed on Spot, body CoM is unknown,
    %    hip masses are combined with the body
    centerMass(j).body.X = v60(j).O.X;
    centerMass(j).body.Y = v60(j).O.Y;
    centerMass(j).body.Z = v60(j).O.Z;

        % Leg masses will be individually approximated to be halfway between toe 
        %    and body markers and set halfway of leg link length to the rear
        centerMass(j).leg.FR.X = (v60(j).FR_leg.X + v60(j).FR.X)/2;
        centerMass(j).leg.FR.Y = (v60(j).FR_leg.Y + v60(j).FR.Y)/2;
        centerMass(j).leg.FR.Z = (v60(j).FR_leg.Z + v60(j).FR.Z)/2;

        centerMass(j).leg.FL.X = (v60(j).FL_leg.X + v60(j).FL.X)/2;
        centerMass(j).leg.FL.Y = (v60(j).FL_leg.Y + v60(j).FL.Y)/2;
        centerMass(j).leg.FL.Z = (v60(j).FL_leg.Z + v60(j).FL.Z)/2;

        centerMass(j).leg.AR.X = (v60(j).AR_leg.X + v60(j).AR.X)/2;
        centerMass(j).leg.AR.Y = (v60(j).AR_leg.Y + v60(j).AR.Y)/2;
        centerMass(j).leg.AR.Z = (v60(j).AR_leg.Z + v60(j).AR.Z)/2;

        centerMass(j).leg.AL.X = (v60(j).AL_leg.X + v60(j).AL.X)/2;
        centerMass(j).leg.AL.Y = (v60(j).AL_leg.Y + v60(j).AL.Y)/2;
        centerMass(j).leg.AL.Z = (v60(j).AL_leg.Z + v60(j).AL.Z)/2;

        
        % Arm Mass is between front and gripper
        centerMass(j).arm.X = (((v60(j).FL.X + v60(j).FR.X)./2) + v60(j).Arm.X)./2;
        centerMass(j).arm.Y = (((v60(j).FL.Y + v60(j).FR.Y)./2) + v60(j).Arm.Y)./2;
        centerMass(j).arm.Z = (((v60(j).FL.Z + v60(j).FR.Z)./2) + v60(j).Arm.Z)./2;
%     end
        % Using weighted average to calc CoM XYZ
        bodyCoMx = bodyCombinedMass*centerMass(j).body.X;
        armCoMx  =  armCombinedMass*centerMass(j).arm.X;
        FLLCoMx  =  legMass*v60(j).FL_leg.X;
        FRLCoMx  =  legMass*v60(j).FR_leg.X;
        ALLCoMx  =  legMass*v60(j).AL_leg.X;
        ARLCoMx  =  legMass*v60(j).AR_leg.X;

        bodyCoMy = bodyCombinedMass*centerMass(j).body.Y;
        armCoMy  =  armCombinedMass*centerMass(j).arm.Y;
        FLLCoMy  =  legMass*v60(j).FL_leg.Y;
        FRLCoMy  =  legMass*v60(j).FR_leg.Y;
        ALLCoMy  =  legMass*v60(j).AL_leg.Y;
        ARLCoMy  =  legMass*v60(j).AR_leg.Y;

        bodyCoMz = bodyCombinedMass*centerMass(j).body.Z;
        armCoMz  =  armCombinedMass*centerMass(j).arm.Z;
        FLLCoMz  =  legMass*v60(j).FL_leg.Z;
        FRLCoMz  =  legMass*v60(j).FR_leg.Z;
        ALLCoMz  =  legMass*v60(j).AL_leg.Z;
        ARLCoMz  =  legMass*v60(j).AR_leg.Z;

    centerMass(j).CoM.X = ...
        (bodyCoMx + armCoMx + FLLCoMx + FRLCoMx + ALLCoMx + ARLCoMx)/totlMass;
    centerMass(j).CoM.Y = ...
        (bodyCoMy + armCoMy + FLLCoMy + FRLCoMy + ALLCoMy + ARLCoMy)/totlMass;
    centerMass(j).CoM.Z = ...
        (bodyCoMz + armCoMz + FLLCoMz + FRLCoMz + ALLCoMz + ARLCoMz)/totlMass;

    supportPolygon(j) = plotSupportPolygon(v60(j), centerMass(j).CoM,...
          'V60', "../../../pictures/2023_tests/newSupportPolygon/", test(j*2));

    % Max/Min Dist
    if supportPolygon(j).absMinDist < minCoMDist
        minCoMDist = supportPolygon(j).absMinDist;
        minCoMDist_test = j;
    end
    if supportPolygon(j).aveMinDist < smallestMinCoMDist
        smallestMinCoMDist = supportPolygon(j).aveMinDist;
        smallestMinCoMDist_test = j;
    end

    % Max/Min Range
    if supportPolygon(j).rangeZ_Robot > largestrangeZ_Robot
        largestrangeZ_Robot = supportPolygon(j).rangeZ_Robot;
        largestrangeZ_Robot_test = j;
    end
    if supportPolygon(j).rangeX_Robot > largestrangeX_Robot
        largestrangeX_Robot = supportPolygon(j).rangeX_Robot;
        largestrangeX_Robot_test = j;
    end
    if supportPolygon(j).rangeZ_world > largestrangeZ_World
        largestrangeZ_World = supportPolygon(j).rangeZ_world;
        largestrangeZ_World_test = j;
    end
    if supportPolygon(j).rangeX_world > largestrangeX_World
        largestrangeX_World = supportPolygon(j).rangeX_world;
        largestrangeX_World_test = j;
    end

    % Max/Min stdev
    if supportPolygon(j).stdevZ_Robot > largestStdevZ_Robot
        largestStdevZ_Robot = supportPolygon(j).stdevZ_Robot;
        largestStdevZ_Robot_test = j;
    end
    if supportPolygon(j).stdevX_Robot > largestStdevX_Robot
        largestStdevX_Robot = supportPolygon(j).stdevX_Robot;
        largestStdevX_Robot_test = j;
    end
    if supportPolygon(j).stdevZ_World > largestStdevZ_World
        largestStdevZ_World = supportPolygon(j).stdevZ_World;
        largestStdevZ_World_test = j;
    end
    if supportPolygon(j).stdevX_World > largestStdevX_World
        largestStdevX_World = supportPolygon(j).stdevX_World;
        largestStdevX_World_test = j;
    end
end
fprintf(strcat("Smallest CoM Dist is: test ",num2str(minCoMDist_test),"(", test(minCoMDist_test*2), ")\n"))
fprintf(strcat("Smallest ave CoM Dist is: test ",num2str(smallestMinCoMDist_test),"(", test(smallestMinCoMDist_test*2), ")\n"))


fprintf(strcat("Largest CoM World Z range is: test ",num2str(largestrangeZ_World_test),"(", test(largestrangeZ_World_test*2), ")\n"))
fprintf(strcat("Largest CoM World X range is: test ",num2str(largestrangeX_World_test),"(", test(largestrangeX_World_test*2), ")\n"))

fprintf(strcat("Largest CoM Z range wrt Robot: test ",num2str(largestrangeZ_Robot_test),"(", test(largestrangeZ_Robot_test*2), ")\n"))
fprintf(strcat("Largest CoM X range wrt Robot: test ",num2str(largestrangeX_Robot_test),"(", test(largestrangeX_Robot_test*2), ")\n"))


fprintf(strcat("Largest CoM World Z StDev is: test ",num2str(largestStdevZ_World_test),"(", test(largestStdevZ_World_test*2), ")\n"))
fprintf(strcat("Largest CoM World X StDev is: test ",num2str(largestStdevX_World_test),"(", test(largestStdevX_World_test*2), ")\n"))

fprintf(strcat("Largest CoM Z StDev wrt Robot: test ",num2str(largestStdevZ_Robot_test),"(", test(largestStdevZ_Robot_test*2), ")\n"))
fprintf(strcat("Largest CoM X StDev wrt Robot: test ",num2str(largestStdevX_Robot_test),"(", test(largestStdevX_Robot_test*2), ")\n"))



%% Set Up Box Plots
testNames = ["v60_baseline";
             "BothDRS_Motion1";
             "BothDRS_Motion2";
             "BothDRS_Motion3";
             "JustArmDRS_Motion1";
             "JustArmDRS_Motion2";
             "JustArmDRS_Motion3";
             "JustBodyDRS_Motion1";
             "JustBodyDRS_Motion2";
             "JustBodyDRS_Motion3"];
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

% init
for n = 1:size(testNames,1)
    testDisp(n).name = testNames(n);
    testDisp(n).dispX = 0;
    testDisp(n).dispY = 0;
    testDisp(n).roll  = 0;
    testDisp(n).pitch = 0;
    testDisp(n).yaw   = 0;
    testDisp(n).CoM   = 0;
    testDisp(n).RangeXWorl = 0;
    testDisp(n).RangeZWorl = 0;
    testDisp(n).RangeXRobo = 0;
    testDisp(n).RangeZRobo = 0;
    testDisp(n).stdevXWorl = 0;
    testDisp(n).stdevZWorl = 0;
    testDisp(n).stdevXRobo = 0;
    testDisp(n).stdevZRobo = 0;
end

for j = 1:size(W2P_V60Pos,2)
%for j = 1
    for n = 1:size(testNames,1)
        if contains(W2P_V60Pos(j).test, testNames(n))
            testDisp(n).dispX  = [testDisp(n).dispX,  W2P_V60Pos(j).Disp.X];
            testDisp(n).dispY  = [testDisp(n).dispY,  W2P_V60Pos(j).Disp.Y];
            testDisp(n).roll  = [testDisp(n).roll,  W2P_V60Pos(j).Roll];
            testDisp(n).pitch = [testDisp(n).pitch, W2P_V60Pos(j).Pitch];
            testDisp(n).yaw   = [testDisp(n).yaw,   W2P_V60Pos(j).Yaw];
            testDisp(n).CoM   = [testDisp(n).CoM,   supportPolygon(j).minCoMDist];

            testDisp(n).RangeXWorl = [testDisp(n).RangeXWorl,   supportPolygon(j).rangeX_world];
            testDisp(n).RangeZWorl = [testDisp(n).RangeZWorl,   supportPolygon(j).rangeZ_world];
            testDisp(n).RangeXRobo = [testDisp(n).RangeXRobo,   supportPolygon(j).rangeX_Robot];
            testDisp(n).RangeZRobo = [testDisp(n).RangeZRobo,   supportPolygon(j).rangeZ_Robot];
            testDisp(n).stdevXWorl = [testDisp(n).stdevXWorl,   supportPolygon(j).stdevX_World];
            testDisp(n).stdevZWorl = [testDisp(n).stdevZWorl,   supportPolygon(j).stdevZ_World];
            testDisp(n).stdevXRobo = [testDisp(n).stdevXRobo,   supportPolygon(j).stdevX_Robot];
            testDisp(n).stdevZRobo = [testDisp(n).stdevZRobo,   supportPolygon(j).stdevZ_Robot];
        end
    end
end

% Remove initial 0 from data otherwise it will mess it up
for n = 1:size(testNames,1)
    testDisp(n).dispX  = testDisp(n).dispX(2:end);
    testDisp(n).dispY  = testDisp(n).dispY(2:end);
    testDisp(n).roll  = testDisp(n).roll(2:end);
    testDisp(n).pitch = testDisp(n).pitch(2:end);
    testDisp(n).yaw   = testDisp(n).yaw(2:end);
    testDisp(n).CoM   = testDisp(n).CoM(2:end);

    testDisp(n).RangeXWorl = testDisp(n).RangeXWorl(2:end);
    testDisp(n).RangeZWorl = testDisp(n).RangeZWorl(2:end);
    testDisp(n).RangeXRobo = testDisp(n).RangeXRobo(2:end);
    testDisp(n).RangeZRobo = testDisp(n).RangeZRobo(2:end);

    testDisp(n).stdevXWorl = testDisp(n).stdevXWorl(2:end);
    testDisp(n).stdevZWorl = testDisp(n).stdevZWorl(2:end);
    testDisp(n).stdevXRobo = testDisp(n).stdevXRobo(2:end);
    testDisp(n).stdevZRobo = testDisp(n).stdevZRobo(2:end);
end

maxLength = 0;
for n = 1:size(testNames,1)
    if length(testDisp(n).dispX) > maxLength
        maxLength = length(testDisp(n).dispX);
    end
end

v60_DisplacementX = nan(maxLength, size(testNames,1));
v60_DisplacementY = nan(maxLength, size(testNames,1));
v60_Roll =          nan(maxLength, size(testNames,1));
v60_Pitch =         nan(maxLength, size(testNames,1));
v60_Yaw =           nan(maxLength, size(testNames,1));
v60_CoMDist =       nan(maxLength, size(testNames,1));

v60_CoMRangXW =      nan(maxLength, size(testNames,1));
v60_CoMRangZW =      nan(maxLength, size(testNames,1));
v60_CoMRangXR =      nan(maxLength, size(testNames,1));
v60_CoMRangZR =      nan(maxLength, size(testNames,1));

v60_CoMStdevXW =      nan(maxLength, size(testNames,1));
v60_CoMStdevZW =      nan(maxLength, size(testNames,1));
v60_CoMStdevXR =      nan(maxLength, size(testNames,1));
v60_CoMStdevZR =      nan(maxLength, size(testNames,1));

for n = 1:size(testNames,1)
    v60_DisplacementX(1:length(testDisp(n).dispX), n) = testDisp(n).dispX;
    v60_DisplacementY(1:length(testDisp(n).dispY), n) = testDisp(n).dispY;
    v60_Roll(1:length(testDisp(n).roll), n)         = testDisp(n).roll;
    v60_Pitch(1:length(testDisp(n).pitch), n)       = testDisp(n).pitch;
    v60_Yaw(1:length(testDisp(n).yaw), n)           = testDisp(n).yaw;
    v60_CoMDist(1:length(testDisp(n).CoM), n)       = testDisp(n).CoM;

    v60_CoMRangXW(1:length(testDisp(n).RangeXWorl), n) = testDisp(n).RangeXWorl;
    v60_CoMRangZW(1:length(testDisp(n).RangeZWorl), n) = testDisp(n).RangeZWorl;
    v60_CoMRangXR(1:length(testDisp(n).RangeXRobo), n) = testDisp(n).RangeXRobo;
    v60_CoMRangZR(1:length(testDisp(n).RangeZRobo), n) = testDisp(n).RangeZRobo;

    v60_CoMStdevXW(1:length(testDisp(n).stdevXWorl), n) = testDisp(n).stdevXWorl;
    v60_CoMStdevZW(1:length(testDisp(n).stdevZWorl), n) = testDisp(n).stdevZWorl;
    v60_CoMStdevXR(1:length(testDisp(n).stdevXRobo), n) = testDisp(n).stdevXRobo;
    v60_CoMStdevZR(1:length(testDisp(n).stdevZRobo), n) = testDisp(n).stdevZRobo;
end
close all

%% Box Plotting
fig = figure(WindowState="maximized");
tiledlayout(2,1, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(v60_DisplacementX, testNames, "Whisker",15)
title('Vision 60 Concatenated X-Displacements by Experiment Type and Motion')
ylabel('Displacement [mm]')

nexttile
boxplot(v60_DisplacementY, testNames, "Whisker",15)
title('Vision 60 Concatenated Y-Displacements by Experiment Type and Motion')
ylabel('Displacement [mm]')

saveName = "../../../pictures/2023_tests/v60ConcatenatedDisplacements";
saveas(fig, saveName, 'jpg')

maxStDevX = 0;
maxStDevY = 0;
for b = 1:size(plat,2)
    if W2P_V60Pos(b).Disp.std.X > maxStDevX
        maxStDevX = W2P_V60Pos(b).Disp.std.X;
        maxStDevTestX = W2P_V60Pos(b).test;
    end
    if W2P_V60Pos(b).Disp.std.Y > maxStDevY
        maxStDevY = W2P_V60Pos(b).Disp.std.Y;
        maxStDevTestY = W2P_V60Pos(b).test;
    end
end
fprintf(strcat(maxStDevTestX," has largest Dist X StDev \n"))
fprintf(strcat(maxStDevTestY," has largest Dist Y StDev \n"))

% =====================================================================

fig2 = figure(WindowState="maximized");
tiledlayout(3,1, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(v60_Roll, abvNames, "Whisker",15)
ylabel('Angle [rads]')
title('Roll')
nexttile
boxplot(v60_Pitch, abvNames, "Whisker",15)
ylabel('Angle [rads]')
title('Pitch')
nexttile
boxplot(v60_Yaw, abvNames, "Whisker",15)
ylabel('Angle [rads]')
title('Yaw')

sgtitle('V60 Concatenated Orientations by Experiment Type and Motion')
saveName = "../../../pictures/2023_tests/v60ConcatOrientation";
saveas(fig2, saveName, 'jpg')

% =======================================================================

fig3 = figure(WindowState="maximized");
boxplot(v60_CoMDist, testNames, "Whisker",15)
title('Vision 60 Concatenated CoM Distance from Support Polygon by Experiment Type and Motion')
ylabel('Distance [mm]')

saveName = "../../../pictures/2023_tests/v60ConcatenatedSupportPolygonCoMDistance";
saveas(fig3, saveName, 'jpg')

%% =======================================================================

fig4 = figure(WindowState="maximized");
tiledlayout(2,1, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(v60_CoMRangXW, abvNames, "Whisker",15)
ylabel('Range [mm]')
ylim([5, 45])
title('CoM X Range')
nexttile
boxplot(v60_CoMRangZW, abvNames, "Whisker",15)
ylabel('Range [mm]')
title('CoM Z Range')

sgtitleName = 'V60 Concatenated CoM Range wrt World by Experiment Type and Motion';
subName = strcat("Largest X Range: ", num2str(largestrangeX_World), "  |  Largest Z Range: ", num2str(largestrangeZ_World));
sgtitle({['{\bf\fontsize{14}' sgtitleName '}'],subName});
saveName = "../../../pictures/2023_tests/v60CoMRangeWorl";
saveas(fig4, saveName, 'jpg')

% =====================================================================

fig5 = figure(WindowState="maximized");
tiledlayout(2,1, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(v60_CoMRangXR, abvNames, "Whisker",15)
ylabel('Range [mm]')
ylim([0, 45])
title('CoM X Range')
nexttile
boxplot(v60_CoMRangZR, abvNames, "Whisker",15)
ylabel('Range [mm]')
title('CoM Z Range')

sgtitleName = 'V60 Concatenated CoM Range wrt Robot by Experiment Type and Motion';
subName = strcat("Largest X Range: ", num2str(largestrangeX_Robot), "  |  Largest Z Range: ", num2str(largestrangeZ_Robot));
sgtitle({['{\bf\fontsize{14}' sgtitleName '}'],subName});
saveName = "../../../pictures/2023_tests/v60CoMRangeRobo";
saveas(fig5, saveName, 'jpg')

% =======================================================================

fig6 = figure(WindowState="maximized");
tiledlayout(2,1, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(v60_CoMStdevXW, abvNames, "Whisker",15)
ylabel('Standard Deviation [mm]')
title('CoM X Standard Deviation')
nexttile
boxplot(v60_CoMStdevZW, abvNames, "Whisker",15)
ylabel('Standard Deviation [mm]')
title('CoM Z Standard Deviation')

sgtitleName = 'V60 Concatenated CoM StDev wrt World by Experiment Type and Motion';
subName = strcat("Largest X StDev: ", num2str(largestStdevX_World), "  |  Largest Z StDev: ", num2str(largestStdevZ_World));
sgtitle({['{\bf\fontsize{14}' sgtitleName '}'],subName});
saveName = "../../../pictures/2023_tests/v60CoMStdevWorl";
saveas(fig6, saveName, 'jpg')

% =====================================================================

fig7 = figure(WindowState="maximized");
tiledlayout(2,1, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(v60_CoMStdevXR, abvNames, "Whisker",15)
ylabel('Standard Deviation [mm]')
title('CoM X Standard Deviation')
nexttile
boxplot(v60_CoMStdevZR, abvNames, "Whisker",15)
ylabel('Standard Deviation [mm]')
title('CoM Z Standard Deviation')

sgtitleName = 'V60 Concatenated CoM StDev wrt Robot by Experiment Type and Motion';
subName = strcat("Largest X StDev: ", num2str(largestStdevX_Robot), "  |  Largest Z StDev: ", num2str(largestStdevZ_Robot));
sgtitle({['{\bf\fontsize{14}' sgtitleName '}'],subName});
saveName = "../../../pictures/2023_tests/v60CoMStdevRobo";
saveas(fig7, saveName, 'jpg')




