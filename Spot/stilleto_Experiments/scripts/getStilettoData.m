clc; clearvars; close all;

cd(fileparts(matlab.desktop.editor.getActiveFilename)); % Changes folder to current file location
stilPath = '../stiletto_csv_new/';
addpath(genpath(stilPath))    % Adds all functions to PATH for ease of use

%% Cycle folders 
% Cycles through folders of data and through folder types to get test info
stilDirectories  = dir(stilPath);
numCSVs = 0;

for f = 3:size(dir(stilPath),1)    % skips "." and ".." from dir()
    folderInfo = stilDirectories(f);
    testFolderPath = strcat(folderInfo.folder, '\',folderInfo.name,'\');
    experimentFiles = dir(strcat(testFolderPath,'*.csv'));

    for i = 1:size(experimentFiles,1)
        numCSVs = numCSVs + 1;   
        stilExp(numCSVs).testType  = folderInfo.name;
        stilExp(numCSVs).testTime  = extractBefore(experimentFiles(i).name, ".csv");
        stilExp(numCSVs).waveState = char();
        stilExp(numCSVs).stabilityMode = [];
        stilExp(numCSVs).filepath  = strcat(experimentFiles(i).folder,'\',experimentFiles(i).name);
    end
end

%% Manually Set experiment wave type and if stability mode was used
waveType = ["Sea State";... % Grab
            "At Pier";... % Kneeknocker
            "At Pier";
            "Underway";
            "At Pier";... % Sit
            "Underway";
            "At Pier";... % Stand
            "At Pier";
            "Underway";
            "Underway";
            "Sea State";
            "S-Curves";
            "At Pier";... % stand_arm
            "Underway";
            "Sea State";
            "S-Curves";
            "Underway";... % Strafe
            "Sea State";
            "S-Curves";
            "At Pier";... % Walking
            "At Pier";
            "Underway";
            "Underway";
            "Sea State";
            "S-Curves";
            "At Pier";... % Walking W Arm
            "At Pier";
            "Underway";
            "At Pier";... % Walking in Place
            "At Pier";
            "Underway";
            "Underway";
            "Sea State";
            "S-Curves";
            "At Pier";... % Walking in place w arm
            "At Pier";
            "Possibly Mislabeled S-C";
            "Underway";
            "Underway";... % Port Starboard
            "Underway";
            "Sea State";
            "S-Curves"];

% [20-28]
waveType_walking = ["At Pier";... % Walking
                    "At Pier";
                    "Underway";
                    "Underway";
                    "Sea State";
                    "S-Curves";
                    "At Pier";... % Walking W Arm
                    "At Pier";
                    "Underway"];
% [29-38]
waveType_W_in_P = ["At Pier";... % Walking in Place
                    "At Pier";
                    "Underway";
                    "Underway";
                    "Sea State";
                    "S-Curves";
                    "At Pier";... % Walking in place w arm
                    "At Pier";
                    "S-Curves";
                    "Underway"];
% [17-19] & [39-42]
waveType_SnSP = ["Underway";... % Strafe
                "Sea State";
                "S-Curves";
                "Underway";... % Port Starboard
                "Underway";
                "Sea State";
                "S-Curves"];
% [7-16]
waveType_Standing = ["At Pier";... % Stand
                    "At Pier";
                    "Underway";
                    "Underway";
                    "Sea State";
                    "S-Curves";
                    "At Pier";... % stand_arm
                    "Underway";
                    "Sea State";
                    "S-Curves"];
% [1-6]
waveType_Misc = ["Sea State";... % Grab
                "At Pier";... % Kneeknocker
                "At Pier";
                "Underway";
                "At Pier";... % Sit
                "Underway"];

% 1 = Stability Mode On, 0 = Stability Mode Off
stabOn   = [1;... % Grab
            0;... % Kneeknocker
            1;
            1;
            0;... % Sit
            1;
            0;... % Stand
            1;
            1;
            0;
            1;
            1;
            0;... % Stand-arm
            1;
            1;
            1;
            1;... % Strafe
            1;
            1;
            0;... % walking
            1;
            1;
            0;
            1;
            1;
            0;... % Walking w Arm
            1;
            1;
            0;... % Walking in place
            1;
            1;
            0;
            1;
            1;
            0;... % Walking in Place W Arm
            1;
            1;
            1;
            1;... % Port Starboard
            0;
            1;
            1];

stabOn_walking = [0;... % walking
                1;
                1;
                0;
                1;
                1;
                0;... % Walking w Arm
                1;
                1];

stabOn_W_in_P = [0;... % Walking w Arm
                1;
                1;
                0;... % Walking in place
                1;
                1;
                0;
                1;
                1];

stabOn_SnSP = [1;... % Strafe
                1;
                1;
                1;... % Port Starboard
                0;
                1;
                1];

stabOn_Standing = [0;... % Stand
                    1;
                    1;
                    0;
                    1;
                    1;
                    0;... % Stand-arm
                    1;
                    1;
                    1];

stabOn_Misc  = [1;... % Grab
                0;... % Kneeknocker
                1;
                1;
                0;... % Sit
                1];

for e = 1:size(stilExp, 2)
    stilExp(e).waveState = waveType(e);
    stilExp(e).stabilityMode = stabOn(e);
end

%% Parse csv data
% Cycle experiments and parse efforts, twists, contact, and contactEfforts
for e = 1:size(stilExp, 2)
    if ~strcmp(stilExp(e).testType, 'sit')   % Skip Sitting Exp
        stilExp(e).data = parseStilettoData(stilExp(e).filepath);
    end
end

%% Set up box plots
% Set up test names
for exp = 7:size(stilExp, 2)    % Skip Grab, kneeknockers, and sit experiments
    % Wave Type
    if strcmp(stilExp(exp).waveState, "At Pier")
        wave = "^1";
    elseif strcmp(stilExp(exp).waveState, "Underway")
        wave = "^2";
    elseif strcmp(stilExp(exp).waveState, "Sea State")
        wave = "^3";
    elseif strcmp(stilExp(exp).waveState, "S-Curves")
        wave = "^4";
    else
        wave = "ERROR";
    end

    % Stab Mode
    if stilExp(exp).stabilityMode == 1
        stabM = "*";
    else
        stabM = " ";
    end

    testNames(exp-6, 1) = strcat(stilExp(exp).testType, wave, stabM);
end

% Set up abv names
for exp = 7:size(stilExp, 2)    % Skip Grab, kneeknockers, and sit experiments
    % Wave Type
    if strcmp(stilExp(exp).waveState, "At Pier")
        wave = "^1";
    elseif strcmp(stilExp(exp).waveState, "Underway")
        wave = "^2";
    elseif strcmp(stilExp(exp).waveState, "Sea State")
        wave = "^3";
    elseif strcmp(stilExp(exp).waveState, "S-Curves")
        wave = "^4";
    else
        wave = "ERROR";
    end

    % Stab Mode
    if stilExp(exp).stabilityMode == 1
        stabM = "*";
    else
        stabM = " ";
    end

    % Test Type abreviated
    if strcmp(stilExp(exp).testType, "stand")
        testType = "S";
    elseif strcmp(stilExp(exp).testType, "stand_arm")
        testType = "SA";
    elseif strcmp(stilExp(exp).testType, "strafe")
        testType = "Sf";
    elseif strcmp(stilExp(exp).testType, "walking")
        testType = "W";
    elseif strcmp(stilExp(exp).testType, "walking_arm")
        testType = "WA";
    elseif strcmp(stilExp(exp).testType, "walking_in_place")
        testType = "WP";
    elseif strcmp(stilExp(exp).testType, "walking_in_place_arm")
        testType = "WPA";
    elseif strcmp(stilExp(exp).testType, "walking_starboard")
        testType = "WS";
    else
        testType = "ERROR";
    end

    abvNames(exp-6, 1) = strcat(testType, wave, stabM);
end

% Initialize Box Vars
maxLength = 0;
for exp = 7:size(stilExp,2)
    if size(stilExp(exp).data.effort.time,2) > maxLength
        maxLength = size(stilExp(exp).data.effort.time,2);
    end
end

% Box Twists
manualTwistLinX = nan(maxLength, size(testNames,1));
manualTwistLinY = nan(maxLength, size(testNames,1));
manualTwistLinZ = nan(maxLength, size(testNames,1));
manualTwistAngX = nan(maxLength, size(testNames,1));
manualTwistAngY = nan(maxLength, size(testNames,1));
manualTwistAngZ = nan(maxLength, size(testNames,1));

FLHipContEfforts = nan(maxLength, size(testNames,1));
FLKneContEfforts = nan(maxLength, size(testNames,1));
FLAbdContEfforts = nan(maxLength, size(testNames,1));
RLHipContEfforts = nan(maxLength, size(testNames,1));
RLKneContEfforts = nan(maxLength, size(testNames,1));
RLAbdContEfforts = nan(maxLength, size(testNames,1));
FRHipContEfforts = nan(maxLength, size(testNames,1));
FRKneContEfforts = nan(maxLength, size(testNames,1));
FRAbdContEfforts = nan(maxLength, size(testNames,1));
RRHipContEfforts = nan(maxLength, size(testNames,1));
RRKneContEfforts = nan(maxLength, size(testNames,1));
RRAbdContEfforts = nan(maxLength, size(testNames,1));

FLHipGaitAve = nan(maxLength, size(testNames,1));
FLKneGaitAve = nan(maxLength, size(testNames,1));
FLAbdGaitAve = nan(maxLength, size(testNames,1));
RLHipGaitAve = nan(maxLength, size(testNames,1));
RLKneGaitAve = nan(maxLength, size(testNames,1));
RLAbdGaitAve = nan(maxLength, size(testNames,1));
FRHipGaitAve = nan(maxLength, size(testNames,1));
FRKneGaitAve = nan(maxLength, size(testNames,1));
FRAbdGaitAve = nan(maxLength, size(testNames,1));
RRHipGaitAve = nan(maxLength, size(testNames,1));
RRKneGaitAve = nan(maxLength, size(testNames,1));
RRAbdGaitAve = nan(maxLength, size(testNames,1));

FLHipAllEfforts = nan(maxLength, size(testNames,1));
FLKneAllEfforts = nan(maxLength, size(testNames,1));
FLAbdAllEfforts = nan(maxLength, size(testNames,1));
RLHipAllEfforts = nan(maxLength, size(testNames,1));
RLKneAllEfforts = nan(maxLength, size(testNames,1));
RLAbdAllEfforts = nan(maxLength, size(testNames,1));
FRHipAllEfforts = nan(maxLength, size(testNames,1));
FRKneAllEfforts = nan(maxLength, size(testNames,1));
FRAbdAllEfforts = nan(maxLength, size(testNames,1));
RRHipAllEfforts = nan(maxLength, size(testNames,1));
RRKneAllEfforts = nan(maxLength, size(testNames,1));
RRAbdAllEfforts = nan(maxLength, size(testNames,1));

FLHipAngles = nan(maxLength, size(testNames,1));
FLKneAngles = nan(maxLength, size(testNames,1));
FLAbdAngles = nan(maxLength, size(testNames,1));
RLHipAngles = nan(maxLength, size(testNames,1));
RLKneAngles = nan(maxLength, size(testNames,1));
RLAbdAngles = nan(maxLength, size(testNames,1));
FRHipAngles = nan(maxLength, size(testNames,1));
FRKneAngles = nan(maxLength, size(testNames,1));
FRAbdAngles = nan(maxLength, size(testNames,1));
RRHipAngles = nan(maxLength, size(testNames,1));
RRKneAngles = nan(maxLength, size(testNames,1));
RRAbdAngles = nan(maxLength, size(testNames,1));

% Put Data Vector into empty array
for exp = 7:size(stilExp,2)
    manualTwistLinX(1:length(stilExp(exp).data.twist.lin.x), exp-6) = stilExp(exp).data.twist.lin.x;
    manualTwistLinY(1:length(stilExp(exp).data.twist.lin.y), exp-6) = stilExp(exp).data.twist.lin.y;
    manualTwistLinZ(1:length(stilExp(exp).data.twist.lin.z), exp-6) = stilExp(exp).data.twist.lin.z;
    manualTwistAngX(1:length(stilExp(exp).data.twist.ang.x), exp-6) = stilExp(exp).data.twist.ang.x;
    manualTwistAngY(1:length(stilExp(exp).data.twist.ang.y), exp-6) = stilExp(exp).data.twist.ang.y;
    manualTwistAngZ(1:length(stilExp(exp).data.twist.ang.z), exp-6) = stilExp(exp).data.twist.ang.z;

    FLHipContEfforts(1:length(stilExp(exp).data.contactEffort.FL.hip), exp-6) = stilExp(exp).data.contactEffort.FL.hip;
    FLKneContEfforts(1:length(stilExp(exp).data.contactEffort.FL.kne), exp-6) = stilExp(exp).data.contactEffort.FL.kne;
    FLAbdContEfforts(1:length(stilExp(exp).data.contactEffort.FL.abd), exp-6) = stilExp(exp).data.contactEffort.FL.abd;
    RLHipContEfforts(1:length(stilExp(exp).data.contactEffort.AL.hip), exp-6) = stilExp(exp).data.contactEffort.AL.hip;
    RLKneContEfforts(1:length(stilExp(exp).data.contactEffort.AL.kne), exp-6) = stilExp(exp).data.contactEffort.AL.kne;
    RLAbdContEfforts(1:length(stilExp(exp).data.contactEffort.AL.abd), exp-6) = stilExp(exp).data.contactEffort.AL.abd;
    FRHipContEfforts(1:length(stilExp(exp).data.contactEffort.FR.hip), exp-6) = stilExp(exp).data.contactEffort.FR.hip;
    FRKneContEfforts(1:length(stilExp(exp).data.contactEffort.FR.kne), exp-6) = stilExp(exp).data.contactEffort.FR.kne;
    FRAbdContEfforts(1:length(stilExp(exp).data.contactEffort.FR.abd), exp-6) = stilExp(exp).data.contactEffort.FR.abd;
    RRHipContEfforts(1:length(stilExp(exp).data.contactEffort.AR.hip), exp-6) = stilExp(exp).data.contactEffort.AR.hip;
    RRKneContEfforts(1:length(stilExp(exp).data.contactEffort.AR.kne), exp-6) = stilExp(exp).data.contactEffort.AR.kne;
    RRAbdContEfforts(1:length(stilExp(exp).data.contactEffort.AR.abd), exp-6) = stilExp(exp).data.contactEffort.AR.abd;
    
    FLHipGaitAve(1:length(stilExp(exp).data.gaitAveEffort.FL.hip), exp-6) = stilExp(exp).data.gaitAveEffort.FL.hip;
    FLKneGaitAve(1:length(stilExp(exp).data.gaitAveEffort.FL.kne), exp-6) = stilExp(exp).data.gaitAveEffort.FL.kne;
    FLAbdGaitAve(1:length(stilExp(exp).data.gaitAveEffort.FL.abd), exp-6) = stilExp(exp).data.gaitAveEffort.FL.abd;
    RLHipGaitAve(1:length(stilExp(exp).data.gaitAveEffort.AL.hip), exp-6) = stilExp(exp).data.gaitAveEffort.AL.hip;
    RLKneGaitAve(1:length(stilExp(exp).data.gaitAveEffort.AL.kne), exp-6) = stilExp(exp).data.gaitAveEffort.AL.kne;
    RLAbdGaitAve(1:length(stilExp(exp).data.gaitAveEffort.AL.abd), exp-6) = stilExp(exp).data.gaitAveEffort.AL.abd;
    FRHipGaitAve(1:length(stilExp(exp).data.gaitAveEffort.FR.hip), exp-6) = stilExp(exp).data.gaitAveEffort.FR.hip;
    FRKneGaitAve(1:length(stilExp(exp).data.gaitAveEffort.FR.kne), exp-6) = stilExp(exp).data.gaitAveEffort.FR.kne;
    FRAbdGaitAve(1:length(stilExp(exp).data.gaitAveEffort.FR.abd), exp-6) = stilExp(exp).data.gaitAveEffort.FR.abd;
    RRHipGaitAve(1:length(stilExp(exp).data.gaitAveEffort.AR.hip), exp-6) = stilExp(exp).data.gaitAveEffort.AR.hip;
    RRKneGaitAve(1:length(stilExp(exp).data.gaitAveEffort.AR.kne), exp-6) = stilExp(exp).data.gaitAveEffort.AR.kne;
    RRAbdGaitAve(1:length(stilExp(exp).data.gaitAveEffort.AR.abd), exp-6) = stilExp(exp).data.gaitAveEffort.AR.abd;
    
    FLHipAllEfforts(1:length(stilExp(exp).data.effort.FL.hip), exp-6) = stilExp(exp).data.effort.FL.hip;
    FLKneAllEfforts(1:length(stilExp(exp).data.effort.FL.kne), exp-6) = stilExp(exp).data.effort.FL.kne;
    FLAbdAllEfforts(1:length(stilExp(exp).data.effort.FL.abd), exp-6) = stilExp(exp).data.effort.FL.abd;
    RLHipAllEfforts(1:length(stilExp(exp).data.effort.AL.hip), exp-6) = stilExp(exp).data.effort.AL.hip;
    RLKneAllEfforts(1:length(stilExp(exp).data.effort.AL.kne), exp-6) = stilExp(exp).data.effort.AL.kne;
    RLAbdAllEfforts(1:length(stilExp(exp).data.effort.AL.abd), exp-6) = stilExp(exp).data.effort.AL.abd;
    FRHipAllEfforts(1:length(stilExp(exp).data.effort.FR.hip), exp-6) = stilExp(exp).data.effort.FR.hip;
    FRKneAllEfforts(1:length(stilExp(exp).data.effort.FR.kne), exp-6) = stilExp(exp).data.effort.FR.kne;
    FRAbdAllEfforts(1:length(stilExp(exp).data.effort.FR.abd), exp-6) = stilExp(exp).data.effort.FR.abd;
    RRHipAllEfforts(1:length(stilExp(exp).data.effort.AR.hip), exp-6) = stilExp(exp).data.effort.AR.hip;
    RRKneAllEfforts(1:length(stilExp(exp).data.effort.AR.kne), exp-6) = stilExp(exp).data.effort.AR.kne;
    RRAbdAllEfforts(1:length(stilExp(exp).data.effort.AR.abd), exp-6) = stilExp(exp).data.effort.AR.abd;
    
    FLHipAngles(1:length(stilExp(exp).data.angle.FL.hip), exp-6) = stilExp(exp).data.angle.FL.hip;
    FLKneAngles(1:length(stilExp(exp).data.angle.FL.kne), exp-6) = stilExp(exp).data.angle.FL.kne;
    FLAbdAngles(1:length(stilExp(exp).data.angle.FL.abd), exp-6) = stilExp(exp).data.angle.FL.abd;
    RLHipAngles(1:length(stilExp(exp).data.angle.AL.hip), exp-6) = stilExp(exp).data.angle.AL.hip;
    RLKneAngles(1:length(stilExp(exp).data.angle.AL.kne), exp-6) = stilExp(exp).data.angle.AL.kne;
    RLAbdAngles(1:length(stilExp(exp).data.angle.AL.abd), exp-6) = stilExp(exp).data.angle.AL.abd;
    FRHipAngles(1:length(stilExp(exp).data.angle.FR.hip), exp-6) = stilExp(exp).data.angle.FR.hip;
    FRKneAngles(1:length(stilExp(exp).data.angle.FR.kne), exp-6) = stilExp(exp).data.angle.FR.kne;
    FRAbdAngles(1:length(stilExp(exp).data.angle.FR.abd), exp-6) = stilExp(exp).data.angle.FR.abd;
    RRHipAngles(1:length(stilExp(exp).data.angle.AR.hip), exp-6) = stilExp(exp).data.angle.AR.hip;
    RRKneAngles(1:length(stilExp(exp).data.angle.AR.kne), exp-6) = stilExp(exp).data.angle.AR.kne;
    RRAbdAngles(1:length(stilExp(exp).data.angle.AR.abd), exp-6) = stilExp(exp).data.angle.AR.abd;
end

% Grab plot limits
maxTwists         = max([max(max(manualTwistLinX)), max(max(manualTwistLinY)), max(max(manualTwistLinZ)),...
                         max(max(manualTwistAngX)), max(max(manualTwistAngY)), max(max(manualTwistAngZ))]);
maxContactEffort  = max([max(max(FLHipContEfforts)), max(max(FLKneContEfforts)), max(max(FLAbdContEfforts)),...
                         max(max(RLHipContEfforts)), max(max(RLKneContEfforts)), max(max(RLAbdContEfforts)),...
                         max(max(FRHipContEfforts)), max(max(FRKneContEfforts)), max(max(FRAbdContEfforts)),...
                         max(max(RRHipContEfforts)), max(max(RRKneContEfforts)), max(max(RRAbdContEfforts))]);
maxGaitAveEff     = max([max(max(FLHipGaitAve)), max(max(FLKneGaitAve)), max(max(FLAbdGaitAve)),...
                         max(max(RLHipGaitAve)), max(max(RLKneGaitAve)), max(max(RLAbdGaitAve)),...
                         max(max(FRHipGaitAve)), max(max(FRKneGaitAve)), max(max(FRAbdGaitAve)),...
                         max(max(RRHipGaitAve)), max(max(RRKneGaitAve)), max(max(RRAbdGaitAve))]);
maxAllEffort      = max([max(max(FLHipAllEfforts)), max(max(FLKneAllEfforts)), max(max(FLAbdAllEfforts)),...
                         max(max(RLHipAllEfforts)), max(max(RLKneAllEfforts)), max(max(RLAbdAllEfforts)),...
                         max(max(FRHipAllEfforts)), max(max(FRKneAllEfforts)), max(max(FRAbdAllEfforts)),...
                         max(max(RRHipAllEfforts)), max(max(RRKneAllEfforts)), max(max(RRAbdAllEfforts))]);
maxAngles         = max([max(max(FLHipAngles)), max(max(FLKneAngles)), max(max(FLAbdAngles)),...
                         max(max(RLHipAngles)), max(max(RLKneAngles)), max(max(RLAbdAngles)),...
                         max(max(FRHipAngles)), max(max(FRKneAngles)), max(max(FRAbdAngles)),...
                         max(max(RRHipAngles)), max(max(RRKneAngles)), max(max(RRAbdAngles))]);
minAngles         = min([min(min(FLHipAngles)), min(min(FLKneAngles)), min(min(FLAbdAngles)),...
                         min(min(RLHipAngles)), min(min(RLKneAngles)), min(min(RLAbdAngles)),...
                         min(min(FRHipAngles)), min(min(FRKneAngles)), min(min(FRAbdAngles)),...
                         min(min(RRHipAngles)), min(min(RRKneAngles)), min(min(RRAbdAngles))]);

minTwists = -maxTwists;
maxContactEffort = ceil(maxContactEffort/10)*10;
minContactEffort = -maxContactEffort * 0.03;
maxGaitAveEff = ceil(maxGaitAveEff/10)*10;
minGaitAveEff = -maxGaitAveEff * 0.03;
maxAllEffort = ceil(maxAllEffort/10)*10;
minAllEffort = -maxAllEffort * 0.03;




%% Box Plotting
%{
    Each plot will have a seperate box for each experiment. Each experiment 
    will have a notation to indicate what the wave state is and if 
    stability mode is on or off.
    Each Figure will have 12 Box Plots, 1 box plot
    per joint. There will be no 'Sit' plots for the contact Effort plots.
    Actually, all grab, kneeknocker, and sit are excluded.

    ^[1] = At Pier, ^[2] = Underway, ^[3] = SeaState, ^[4] = S-Curves

    A * will indicate that Stability Mode is on
%}

testNames = abvNames;
for o = 1:size(abvNames)
    abvNames(o) = num2str(o);
end

%%
%{%
% Contacting Torques 
fig1 = figure(WindowState="maximized");     %'Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipContEfforts, abvNames, "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Hip')
% yline(hipLim, '--', 'Limit')
nexttile
boxplot(FLKneContEfforts, abvNames, "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Knee')
% yline(kneLim, '--', 'Limit')
nexttile
boxplot(FLAbdContEfforts, abvNames, "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Abductor')
% yline(abdLim, '--', 'Limit')
% FR Leg
nexttile
boxplot(FRHipContEfforts, abvNames, "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneContEfforts, abvNames, "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdContEfforts, abvNames, "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipContEfforts, abvNames, "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneContEfforts, abvNames, "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdContEfforts, abvNames, "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipContEfforts, testNames, "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneContEfforts, testNames, "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdContEfforts, testNames, "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Absolute Joint Contacting Torques by Experiment Type')
saveName = "../pictures/stilettoContactJointTorques";
saveas(fig1, saveName, 'jpg')
% close



% Gaited Ave Torques
fig2 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipGaitAve, abvNames, "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Hip')
nexttile
boxplot(FLKneGaitAve, abvNames, "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Knee')
nexttile
boxplot(FLAbdGaitAve, abvNames, "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipGaitAve, abvNames, "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneGaitAve, abvNames, "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdGaitAve, abvNames, "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipGaitAve, abvNames, "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneGaitAve, abvNames, "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdGaitAve, abvNames, "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipGaitAve, testNames, "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneGaitAve, testNames, "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdGaitAve, testNames, "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Gaited Average of Absolute Joint Torques by Experiment Type')
saveName = "../pictures/stilettoGaitedAveTorques";
saveas(fig2, saveName, 'jpg')
% close



% All Joint Efforts
fig3 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipAllEfforts, abvNames, "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Hip')
nexttile
boxplot(FLKneAllEfforts, abvNames, "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Knee')
nexttile
boxplot(FLAbdAllEfforts, abvNames, "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipAllEfforts, abvNames, "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneAllEfforts, abvNames, "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdAllEfforts, abvNames, "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipAllEfforts, abvNames, "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneAllEfforts, abvNames, "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdAllEfforts, abvNames, "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipAllEfforts, testNames, "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneAllEfforts, testNames, "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdAllEfforts, testNames, "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Joint Torques by Experiment Type')
saveName = "../pictures/stilettoAllTorques";
saveas(fig3, saveName, 'jpg')
% close



% Joint Angles
fig4 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipAngles, abvNames, "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Hip')
nexttile
boxplot(FLKneAngles, abvNames, "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Knee')
nexttile
boxplot(FLAbdAngles, abvNames, "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipAngles, abvNames, "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Hip')
nexttile
boxplot(FRKneAngles, abvNames, "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Knee')
nexttile
boxplot(FRAbdAngles, abvNames, "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipAngles, abvNames, "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Hip')
nexttile
boxplot(RLKneAngles, abvNames, "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Knee')
nexttile
boxplot(RLAbdAngles, abvNames, "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipAngles, testNames, "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Hip')
nexttile
boxplot(RRKneAngles, testNames, "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Knee')
nexttile
boxplot(RRAbdAngles, testNames, "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Abductor')

sgtitle('Spot on Stiletto Joint Angles by Experiment Type')
saveName = "../pictures/stilettoAngles";
saveas(fig4, saveName, 'jpg')
% close



fig5 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(3,2, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(manualTwistLinX, testNames, "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear X (Forwards-backwards Translation)')

nexttile
boxplot(manualTwistAngX, testNames, "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular X (Roll)')

nexttile
boxplot(manualTwistLinY, testNames, "Whisker",15000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear Y (Left-Right Translation)')

nexttile
boxplot(manualTwistAngY, testNames, "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular Y (Pitch)')

nexttile
boxplot(manualTwistLinZ, testNames, "Whisker",15000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear Z (Up-Down Translation)')

nexttile
boxplot(manualTwistAngZ, testNames, "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular Z (Yaw)')

sgtitle('Spot Concatenated Joystick Inputs by Experiment Type and Motion')
saveName = "../pictures/spotManualTwists";
saveas(fig5, saveName, 'jpg')
close all
%}%


%% Walking Experiments [20-28]   (14:22)

% Contacting Torques 
fig1 = figure(WindowState="fullscreen");     %'Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipContEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Hip')
% yline(hipLim, '--', 'Limit')
nexttile
boxplot(FLKneContEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Knee')
% yline(kneLim, '--', 'Limit')
nexttile
boxplot(FLAbdContEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Abductor')
% yline(abdLim, '--', 'Limit')
% FR Leg
nexttile
boxplot(FRHipContEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneContEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdContEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipContEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneContEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdContEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipContEfforts(1:end,14:22), testNames(14:22), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneContEfforts(1:end,14:22), testNames(14:22), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdContEfforts(1:end,14:22), testNames(14:22), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Absolute Joint Contacting Torques by Experiment Type: Walking')
saveName = "../pictures/stilettoContactJointTorques_walking";
saveas(fig1, saveName, 'jpg')
% close



% Gaited Ave Torques
fig2 = figure(WindowState="fullscreen");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipGaitAve(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Hip')
nexttile
boxplot(FLKneGaitAve(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Knee')
nexttile
boxplot(FLAbdGaitAve(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipGaitAve(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneGaitAve(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdGaitAve(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipGaitAve(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneGaitAve(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdGaitAve(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipGaitAve(1:end,14:22), testNames(14:22), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneGaitAve(1:end,14:22), testNames(14:22), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdGaitAve(1:end,14:22), testNames(14:22), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Gaited Average of Absolute Joint Torques by Experiment Type: Walking')
saveName = "../pictures/stilettoGaitedAveTorques_walking";
saveas(fig2, saveName, 'jpg')
% close



% All Joint Efforts
fig3 = figure(WindowState="fullscreen");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipAllEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Hip')
nexttile
boxplot(FLKneAllEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Knee')
nexttile
boxplot(FLAbdAllEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipAllEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneAllEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdAllEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipAllEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneAllEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdAllEfforts(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipAllEfforts(1:end,14:22), testNames(14:22), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneAllEfforts(1:end,14:22), testNames(14:22), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdAllEfforts(1:end,14:22), testNames(14:22), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Joint Torques by Experiment Type: Walking')
saveName = "../pictures/stilettoAllTorques_walking";
saveas(fig3, saveName, 'jpg')
% close



% Joint Angles
fig4 = figure(WindowState="fullscreen");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipAngles(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Hip')
nexttile
boxplot(FLKneAngles(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Knee')
nexttile
boxplot(FLAbdAngles(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipAngles(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Hip')
nexttile
boxplot(FRKneAngles(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Knee')
nexttile
boxplot(FRAbdAngles(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipAngles(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Hip')
nexttile
boxplot(RLKneAngles(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Knee')
nexttile
boxplot(RLAbdAngles(1:end,14:22), abvNames(14:22), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipAngles(1:end,14:22), testNames(14:22), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Hip')
nexttile
boxplot(RRKneAngles(1:end,14:22), testNames(14:22), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Knee')
nexttile
boxplot(RRAbdAngles(1:end,14:22), testNames(14:22), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Abductor')

sgtitle('Spot on Stiletto Joint Angles by Experiment Type: Walking')
saveName = "../pictures/stilettoAngles_walking";
saveas(fig4, saveName, 'jpg')
% close



fig5 = figure(WindowState="fullscreen");     %('Visible','off');
tiledlayout(3,2, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(manualTwistLinX(1:end,14:22), testNames(14:22), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear X (Forwards-backwards Translation)')

nexttile
boxplot(manualTwistAngX(1:end,14:22), testNames(14:22), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular X (Roll)')

nexttile
boxplot(manualTwistLinY(1:end,14:22), testNames(14:22), "Whisker",15000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear Y (Left-Right Translation)')

nexttile
boxplot(manualTwistAngY(1:end,14:22), testNames(14:22), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular Y (Pitch)')

nexttile
boxplot(manualTwistLinZ(1:end,14:22), testNames(14:22), "Whisker",15000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear Z (Up-Down Translation)')

nexttile
boxplot(manualTwistAngZ(1:end,14:22), testNames(14:22), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular Z (Yaw)')

sgtitle('Spot Concatenated Joystick Inputs by Experiment Type and Motion: Walking')
saveName = "../pictures/spotManualTwists_walking";
saveas(fig5, saveName, 'jpg')

close all

%% Walking in Place [29-38]  (23:32)
% Contacting Torques 
fig1 = figure(WindowState="maximized");     %'Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipContEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Hip')
% yline(hipLim, '--', 'Limit')
nexttile
boxplot(FLKneContEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Knee')
% yline(kneLim, '--', 'Limit')
nexttile
boxplot(FLAbdContEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Abductor')
% yline(abdLim, '--', 'Limit')
% FR Leg
nexttile
boxplot(FRHipContEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneContEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdContEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipContEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneContEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdContEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipContEfforts(1:end,23:32), testNames(23:32), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneContEfforts(1:end,23:32), testNames(23:32), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdContEfforts(1:end,23:32), testNames(23:32), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Absolute Joint Contacting Torques by Experiment Type: Walking in Place')
saveName = "../pictures/stilettoContactJointTorques_W_in_P";
saveas(fig1, saveName, 'jpg')
% close



% Gaited Ave Torques
fig2 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipGaitAve(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Hip')
nexttile
boxplot(FLKneGaitAve(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Knee')
nexttile
boxplot(FLAbdGaitAve(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipGaitAve(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneGaitAve(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdGaitAve(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipGaitAve(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneGaitAve(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdGaitAve(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipGaitAve(1:end,23:32), testNames(23:32), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneGaitAve(1:end,23:32), testNames(23:32), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdGaitAve(1:end,23:32), testNames(23:32), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Gaited Average of Absolute Joint Torques by Experiment Type: Walking in Place')
saveName = "../pictures/stilettoGaitedAveTorques_W_in_P";
saveas(fig2, saveName, 'jpg')
% close



% All Joint Efforts
fig3 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipAllEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Hip')
nexttile
boxplot(FLKneAllEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Knee')
nexttile
boxplot(FLAbdAllEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipAllEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneAllEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdAllEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipAllEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneAllEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdAllEfforts(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipAllEfforts(1:end,23:32), testNames(23:32), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneAllEfforts(1:end,23:32), testNames(23:32), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdAllEfforts(1:end,23:32), testNames(23:32), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Joint Torques by Experiment Type: Walking in Place')
saveName = "../pictures/stilettoAllTorques_W_in_P";
saveas(fig3, saveName, 'jpg')
% close



% Joint Angles
fig4 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipAngles(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Hip')
nexttile
boxplot(FLKneAngles(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Knee')
nexttile
boxplot(FLAbdAngles(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipAngles(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Hip')
nexttile
boxplot(FRKneAngles(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Knee')
nexttile
boxplot(FRAbdAngles(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipAngles(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Hip')
nexttile
boxplot(RLKneAngles(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Knee')
nexttile
boxplot(RLAbdAngles(1:end,23:32), abvNames(23:32), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipAngles(1:end,23:32), testNames(23:32), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Hip')
nexttile
boxplot(RRKneAngles(1:end,23:32), testNames(23:32), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Knee')
nexttile
boxplot(RRAbdAngles(1:end,23:32), testNames(23:32), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Abductor')

sgtitle('Spot on Stiletto Joint Angles by Experiment Type: Walking in Place')
saveName = "../pictures/stilettoAngles_W_in_P";
saveas(fig4, saveName, 'jpg')
% close



fig5 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(3,2, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(manualTwistLinX(1:end,23:32), testNames(23:32), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear X (Forwards-backwards Translation)')

nexttile
boxplot(manualTwistAngX(1:end,23:32), testNames(23:32), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular X (Roll)')

nexttile
boxplot(manualTwistLinY(1:end,23:32), testNames(23:32), "Whisker",15000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear Y (Left-Right Translation)')

nexttile
boxplot(manualTwistAngY(1:end,23:32), testNames(23:32), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular Y (Pitch)')

nexttile
boxplot(manualTwistLinZ(1:end,23:32), testNames(23:32), "Whisker",15000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear Z (Up-Down Translation)')

nexttile
boxplot(manualTwistAngZ(1:end,23:32), testNames(23:32), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular Z (Yaw)')

sgtitle('Spot Concatenated Joystick Inputs by Experiment Type and Motion: Walking in Place')
saveName = "../pictures/spotManualTwists_W_in_P";
saveas(fig5, saveName, 'jpg')

close all



%% Strafe & PortStarboard [17-19] & [39-42]  (11:13) & (33:36)
% Contacting Torques 
fig1 = figure(WindowState="maximized");     %'Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipContEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Hip')
% yline(hipLim, '--', 'Limit')
nexttile
boxplot(FLKneContEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Knee')
% yline(kneLim, '--', 'Limit')
nexttile
boxplot(FLAbdContEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Abductor')
% yline(abdLim, '--', 'Limit')
% FR Leg
nexttile
boxplot(FRHipContEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneContEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdContEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipContEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneContEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdContEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipContEfforts(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneContEfforts(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdContEfforts(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Absolute Joint Contacting Torques by Experiment Type: Strafe & Port-Starboard')
saveName = "../pictures/stilettoContactJointTorques_SnPS";
saveas(fig1, saveName, 'jpg')
% close



% Gaited Ave Torques
fig2 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipGaitAve(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Hip')
nexttile
boxplot(FLKneGaitAve(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Knee')
nexttile
boxplot(FLAbdGaitAve(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipGaitAve(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneGaitAve(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdGaitAve(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipGaitAve(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneGaitAve(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdGaitAve(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipGaitAve(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneGaitAve(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdGaitAve(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Gaited Average of Absolute Joint Torques by Experiment Type: Strafe & Port-Starboard')
saveName = "../pictures/stilettoGaitedAveTorques_SnPS";
saveas(fig2, saveName, 'jpg')
% close



% All Joint Efforts
fig3 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipAllEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Hip')
nexttile
boxplot(FLKneAllEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Knee')
nexttile
boxplot(FLAbdAllEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipAllEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneAllEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdAllEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipAllEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneAllEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdAllEfforts(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipAllEfforts(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneAllEfforts(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdAllEfforts(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Joint Torques by Experiment Type: Strafe & Port-Starboard')
saveName = "../pictures/stilettoAllTorques_SnPS";
saveas(fig3, saveName, 'jpg')
% close



% Joint Angles
fig4 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipAngles(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Hip')
nexttile
boxplot(FLKneAngles(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Knee')
nexttile
boxplot(FLAbdAngles(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipAngles(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Hip')
nexttile
boxplot(FRKneAngles(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Knee')
nexttile
boxplot(FRAbdAngles(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipAngles(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Hip')
nexttile
boxplot(RLKneAngles(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Knee')
nexttile
boxplot(RLAbdAngles(1:end,[11:13,33:36]), abvNames([11:13,33:36]), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipAngles(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Hip')
nexttile
boxplot(RRKneAngles(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Knee')
nexttile
boxplot(RRAbdAngles(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Joint Angles by Experiment Type: Strafe & Port-Starboard')
saveName = "../pictures/stilettoAngles_SnPS";
saveas(fig4, saveName, 'jpg')
% close



fig5 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(3,2, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(manualTwistLinX(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear X (Forwards-backwards Translation)')

nexttile
boxplot(manualTwistAngX(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular X (Roll)')

nexttile
boxplot(manualTwistLinY(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear Y (Left-Right Translation)')

nexttile
boxplot(manualTwistAngY(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular Y (Pitch)')

nexttile
boxplot(manualTwistLinZ(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",15000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear Z (Up-Down Translation)')

nexttile
boxplot(manualTwistAngZ(1:end,[11:13,33:36]), testNames([11:13,33:36]), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular Z (Yaw)')

sgtitle('Spot Concatenated Joystick Inputs by Experiment Type and Motion: Strafe & Port-Starboard')
saveName = "../pictures/spotManualTwists_SnPS";
saveas(fig5, saveName, 'jpg')
close all



%% Standing [7-16]   (1:10)
% Contacting Torques 
fig1 = figure(WindowState="maximized");     %'Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipContEfforts(1:end,1:10), abvNames(11:20), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Hip')
% yline(hipLim, '--', 'Limit')
nexttile
boxplot(FLKneContEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Knee')
% yline(kneLim, '--', 'Limit')
nexttile
boxplot(FLAbdContEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FL Abductor')
% yline(abdLim, '--', 'Limit')
% FR Leg
nexttile
boxplot(FRHipContEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneContEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdContEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipContEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneContEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdContEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipContEfforts(1:end,1:10), testNames(1:10), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneContEfforts(1:end,1:10), testNames(1:10), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdContEfforts(1:end,1:10), testNames(1:10), "Whisker",15)
%ylim([minContactEffort, maxContactEffort])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Absolute Joint Contacting Torques by Experiment Type: Standing')
saveName = "../pictures/stilettoContactJointTorques_standing";
saveas(fig1, saveName, 'jpg')
% close



% Gaited Ave Torques
fig2 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipGaitAve(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Hip')
nexttile
boxplot(FLKneGaitAve(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Knee')
nexttile
boxplot(FLAbdGaitAve(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipGaitAve(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneGaitAve(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdGaitAve(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipGaitAve(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneGaitAve(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdGaitAve(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipGaitAve(1:end,1:10), testNames(1:10), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneGaitAve(1:end,1:10), testNames(1:10), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdGaitAve(1:end,1:10), testNames(1:10), "Whisker",15)
%ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Gaited Average of Absolute Joint Torques by Experiment Type: Standing')
saveName = "../pictures/stilettoGaitedAveTorques_standing";
saveas(fig2, saveName, 'jpg')
% close



% All Joint Efforts
fig3 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipAllEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Hip')
nexttile
boxplot(FLKneAllEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Knee')
nexttile
boxplot(FLAbdAllEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipAllEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneAllEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdAllEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipAllEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneAllEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdAllEfforts(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipAllEfforts(1:end,1:10), testNames(1:10), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneAllEfforts(1:end,1:10), testNames(1:10), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdAllEfforts(1:end,1:10), testNames(1:10), "Whisker",15)
%ylim([minAllEffort,maxAllEffort])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot on Stiletto Joint Torques by Experiment Type: Standing')
saveName = "../pictures/stilettoAllTorques_standing";
saveas(fig3, saveName, 'jpg')
% close



% Joint Angles
fig4 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipAngles(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Hip')
nexttile
boxplot(FLKneAngles(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Knee')
nexttile
boxplot(FLAbdAngles(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipAngles(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Hip')
nexttile
boxplot(FRKneAngles(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Knee')
nexttile
boxplot(FRAbdAngles(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipAngles(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Hip')
nexttile
boxplot(RLKneAngles(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Knee')
nexttile
boxplot(RLAbdAngles(1:end,1:10), abvNames(1:10), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipAngles(1:end,1:10), testNames(1:10), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Hip')
nexttile
boxplot(RRKneAngles(1:end,1:10), testNames(1:10), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Knee')
nexttile
boxplot(RRAbdAngles(1:end,1:10), testNames(1:10), "Whisker",15)
%ylim([minAngles,maxAngles])
ylabel('Angle [rads]')
title('AR Abductor')

sgtitle('Spot on Stiletto Joint Angles by Experiment Type: Standing')
saveName = "../pictures/stilettoAngles_standing";
saveas(fig4, saveName, 'jpg')
% close



fig5 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(3,2, 'TileSpacing','tight','Padding','tight')

nexttile
boxplot(manualTwistLinX(1:end,1:10), testNames(1:10), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear X (Forwards-backwards Translation)')

nexttile
boxplot(manualTwistAngX(1:end,1:10), testNames(1:10), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular X (Roll)')

nexttile
boxplot(manualTwistLinY(1:end,1:10), testNames(1:10), "Whisker",15000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear Y (Left-Right Translation)')

nexttile
boxplot(manualTwistAngY(1:end,1:10), testNames(1:10), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular Y (Pitch)')

nexttile
boxplot(manualTwistLinZ(1:end,1:10), testNames(1:10), "Whisker",15000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Linear Z (Up-Down Translation)')

nexttile
boxplot(manualTwistAngZ(1:end,1:10), testNames(1:10), "Whisker",150000000000000000000)
%%ylim([minAllTwists, maxAllTwists])
ylabel('Input')
title('Angular Z (Yaw)')

sgtitle('Spot Concatenated Joystick Inputs by Experiment Type and Motion: Standing')
saveName = "../pictures/spotManualTwists_standing";
saveas(fig5, saveName, 'jpg')
close all



