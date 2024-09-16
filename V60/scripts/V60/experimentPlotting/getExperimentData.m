clc; clearvars; %close all;
cd(fileparts(matlab.desktop.editor.getActiveFilename)); % Changes folder to current file location

id = 'MATLAB:table:ModifiedAndSavedVarnames';
warning('off',id)       % Suppresses readtable Var Name change warning caused by topic names starting with a '/'

%{
    This code takes the data from the bag files created during each 
    experiment with the V60 on the treadmill and separates it into each 
    individual trial. It then normalizes the times and parses the data.

    'getGaitFrames.m' calculates the average number of frames a step cycle
    uses in a trial to uses for a gaited average.
    
    'parse_Joint_Efforts.m' separates the leg data for when toes are
    touching and creates a gaited ave and RMS of the data then plots.

    'parse_Manual_Twist.m' separates the user joystick data and the peak
    inputs to make it easier to read, then plots it.
%}

dataFolderPath = '../../../run_Data/v60_data/Jun12-2023/csv_from_bags';
setDir = dir(dataFolderPath);
numSet = size(setDir,1);            % = num of exp + 2 ('.', '..')

hipLim = 72.67;
kneLim = 98.8;
abdLim = 98.8;

%% Parse Data
% init 
maxLength = 0;
r = 0;

% Sort experiment set (BothDRS, JustArm, JustBody, ...)
for set = 3:numSet
    motionDir = dir(strcat(setDir(set).folder, '\', setDir(set).name));
    numMo = size(motionDir,1);      % = num of mo + 2 ('.', '..')

    % Sorts Motion type (none, low, heavy, stilletto)
    for mo = 3:numMo
        expDirPath = strcat(motionDir(mo).folder, '\', motionDir(mo).name, '\');
        expDir = dir(strcat(expDirPath, '*.csv'));      
        numExp = size(expDir,1);
        
        % Init Twists
        expData(set).motion(mo).allTwists.angZ = [];
        expData(set).motion(mo).allTwists.linX = [];
        expData(set).motion(mo).allTwists.linY = [];
        % Init Angles
        expData(set).motion(mo).allAngles.FL.hip = [];
        expData(set).motion(mo).allAngles.FL.kne = [];
        expData(set).motion(mo).allAngles.FL.abd = [];
        expData(set).motion(mo).allAngles.RL.hip = [];
        expData(set).motion(mo).allAngles.RL.kne = [];
        expData(set).motion(mo).allAngles.RL.abd = [];
        expData(set).motion(mo).allAngles.FR.hip = [];
        expData(set).motion(mo).allAngles.FR.kne = [];
        expData(set).motion(mo).allAngles.FR.abd = [];
        expData(set).motion(mo).allAngles.RR.hip = [];
        expData(set).motion(mo).allAngles.RR.kne = [];
        expData(set).motion(mo).allAngles.RR.abd = [];
        % Init efforts
        expData(set).motion(mo).allEfforts.FL.Effort.hip = [];
        expData(set).motion(mo).allEfforts.FL.Effort.kne = [];
        expData(set).motion(mo).allEfforts.FL.Effort.abd = [];
        expData(set).motion(mo).allEfforts.RL.Effort.hip = [];
        expData(set).motion(mo).allEfforts.RL.Effort.kne = [];
        expData(set).motion(mo).allEfforts.RL.Effort.abd = [];
        expData(set).motion(mo).allEfforts.FR.Effort.hip = [];
        expData(set).motion(mo).allEfforts.FR.Effort.kne = [];
        expData(set).motion(mo).allEfforts.FR.Effort.abd = [];
        expData(set).motion(mo).allEfforts.RR.Effort.hip = [];
        expData(set).motion(mo).allEfforts.RR.Effort.kne = [];
        expData(set).motion(mo).allEfforts.RR.Effort.abd = [];
        % Init gaitedAve
        expData(set).motion(mo).allEfforts.FL.gaitedAve.hip = [];
        expData(set).motion(mo).allEfforts.FL.gaitedAve.kne = [];
        expData(set).motion(mo).allEfforts.FL.gaitedAve.abd = [];
        expData(set).motion(mo).allEfforts.RL.gaitedAve.hip = [];
        expData(set).motion(mo).allEfforts.RL.gaitedAve.kne = [];
        expData(set).motion(mo).allEfforts.RL.gaitedAve.abd = [];
        expData(set).motion(mo).allEfforts.FR.gaitedAve.hip = [];
        expData(set).motion(mo).allEfforts.FR.gaitedAve.kne = [];
        expData(set).motion(mo).allEfforts.FR.gaitedAve.abd = [];
        expData(set).motion(mo).allEfforts.RR.gaitedAve.hip = [];
        expData(set).motion(mo).allEfforts.RR.gaitedAve.kne = [];
        expData(set).motion(mo).allEfforts.RR.gaitedAve.abd = [];

        % Sorts indiv experiment number (1-10 or 1-5)
        for exp = 1:numExp
            expDataPath = strcat(expDir(mo).folder, '\exp', string(exp), '.csv');

            expTable = readtable(expDataPath);      % Retreive Data from csv
            expTable.x__time = expTable.x__time - expTable.x__time(1);  % Normalized time
            
            setName = setDir(set).name;
            moName  = motionDir(mo).name;
            expName = strcat('exp', string(exp));

            expData(set).name = setName;
            expData(set).motion(mo).name = moName;
            expData(set).motion(mo).trial(exp).name = expName;
            
            
            expData(set).motion(mo).trial(exp).manTwist = ...
                    parse_Manual_Twist(expTable, setName, moName, expName);
            expData(set).motion(mo).trial(exp).data  = ...
                    parse_Joint_Efforts(expTable, setName, moName, expName);
            expData(set).motion(mo).trial(exp).angles = ...
                    parse_Angles(expTable, setName, moName, expName);

            % Concatate Twists
            expData(set).motion(mo).allTwists.linY = ...
           [expData(set).motion(mo).allTwists.linY; expData(set).motion(mo).trial(exp).manTwist.linY];
            expData(set).motion(mo).allTwists.linX = ...
           [expData(set).motion(mo).allTwists.linX; expData(set).motion(mo).trial(exp).manTwist.linX];
            expData(set).motion(mo).allTwists.angZ = ...
           [expData(set).motion(mo).allTwists.angZ; expData(set).motion(mo).trial(exp).manTwist.angZ];
            % Concatate Angles
            expData(set).motion(mo).allAngles.FL.hip = ...
           [expData(set).motion(mo).allAngles.FL.hip; expData(set).motion(mo).trial(exp).angles.hip_A_FL];
            expData(set).motion(mo).allAngles.FL.kne = ...
           [expData(set).motion(mo).allAngles.FL.kne; expData(set).motion(mo).trial(exp).angles.kne_A_FL];
            expData(set).motion(mo).allAngles.FL.abd = ...
           [expData(set).motion(mo).allAngles.FL.abd; expData(set).motion(mo).trial(exp).angles.abd_A_FL];
            expData(set).motion(mo).allAngles.RL.hip = ...
           [expData(set).motion(mo).allAngles.RL.hip; expData(set).motion(mo).trial(exp).angles.hip_A_RL];
            expData(set).motion(mo).allAngles.RL.kne = ...
           [expData(set).motion(mo).allAngles.RL.kne; expData(set).motion(mo).trial(exp).angles.kne_A_RL];
            expData(set).motion(mo).allAngles.RL.abd = ...
           [expData(set).motion(mo).allAngles.RL.abd; expData(set).motion(mo).trial(exp).angles.abd_A_RL];
            expData(set).motion(mo).allAngles.FR.hip = ...
           [expData(set).motion(mo).allAngles.FR.hip; expData(set).motion(mo).trial(exp).angles.hip_A_FR];
            expData(set).motion(mo).allAngles.FR.kne = ...
           [expData(set).motion(mo).allAngles.FR.kne; expData(set).motion(mo).trial(exp).angles.kne_A_FR];
            expData(set).motion(mo).allAngles.FR.abd = ...
           [expData(set).motion(mo).allAngles.FR.abd; expData(set).motion(mo).trial(exp).angles.abd_A_FR];
            expData(set).motion(mo).allAngles.RR.hip = ...
           [expData(set).motion(mo).allAngles.RR.hip; expData(set).motion(mo).trial(exp).angles.hip_A_RR];
            expData(set).motion(mo).allAngles.RR.kne = ...
           [expData(set).motion(mo).allAngles.RR.kne; expData(set).motion(mo).trial(exp).angles.kne_A_RR];
            expData(set).motion(mo).allAngles.RR.abd = ...
           [expData(set).motion(mo).allAngles.RR.abd; expData(set).motion(mo).trial(exp).angles.abd_A_RR];
            % Concatate Efforts
            expData(set).motion(mo).allEfforts.FL.Effort.hip = ...
           [expData(set).motion(mo).allEfforts.FL.Effort.hip; expData(set).motion(mo).trial(exp).data.FL.Effort.hip];
            expData(set).motion(mo).allEfforts.FL.Effort.kne = ...
           [expData(set).motion(mo).allEfforts.FL.Effort.kne; expData(set).motion(mo).trial(exp).data.FL.Effort.kne];
            expData(set).motion(mo).allEfforts.FL.Effort.abd = ...
           [expData(set).motion(mo).allEfforts.FL.Effort.abd; expData(set).motion(mo).trial(exp).data.FL.Effort.abd];
            expData(set).motion(mo).allEfforts.RL.Effort.hip = ...
           [expData(set).motion(mo).allEfforts.RL.Effort.hip; expData(set).motion(mo).trial(exp).data.RL.Effort.hip];
            expData(set).motion(mo).allEfforts.RL.Effort.kne = ...
           [expData(set).motion(mo).allEfforts.RL.Effort.kne; expData(set).motion(mo).trial(exp).data.RL.Effort.kne];
            expData(set).motion(mo).allEfforts.RL.Effort.abd = ...
           [expData(set).motion(mo).allEfforts.RL.Effort.abd; expData(set).motion(mo).trial(exp).data.RL.Effort.abd];
            expData(set).motion(mo).allEfforts.FR.Effort.hip = ...
           [expData(set).motion(mo).allEfforts.FR.Effort.hip; expData(set).motion(mo).trial(exp).data.FR.Effort.hip];
            expData(set).motion(mo).allEfforts.FR.Effort.kne = ...
           [expData(set).motion(mo).allEfforts.FR.Effort.kne; expData(set).motion(mo).trial(exp).data.FR.Effort.kne];
            expData(set).motion(mo).allEfforts.FR.Effort.abd = ...
           [expData(set).motion(mo).allEfforts.FR.Effort.abd; expData(set).motion(mo).trial(exp).data.FR.Effort.abd];
            expData(set).motion(mo).allEfforts.RR.Effort.hip = ...
           [expData(set).motion(mo).allEfforts.RR.Effort.hip; expData(set).motion(mo).trial(exp).data.RR.Effort.hip];
            expData(set).motion(mo).allEfforts.RR.Effort.kne = ...
           [expData(set).motion(mo).allEfforts.RR.Effort.kne; expData(set).motion(mo).trial(exp).data.RR.Effort.kne];
            expData(set).motion(mo).allEfforts.RR.Effort.abd = ...
           [expData(set).motion(mo).allEfforts.RR.Effort.abd; expData(set).motion(mo).trial(exp).data.RR.Effort.abd];
            % Concatate gaited ave Efforts
            expData(set).motion(mo).allEfforts.FL.gaitedAve.hip = ...
           [expData(set).motion(mo).allEfforts.FL.gaitedAve.hip; expData(set).motion(mo).trial(exp).data.FL.gaitedAve.hip'];
            expData(set).motion(mo).allEfforts.FL.gaitedAve.kne = ...
           [expData(set).motion(mo).allEfforts.FL.gaitedAve.kne; expData(set).motion(mo).trial(exp).data.FL.gaitedAve.kne'];
            expData(set).motion(mo).allEfforts.FL.gaitedAve.abd = ...
           [expData(set).motion(mo).allEfforts.FL.gaitedAve.abd; expData(set).motion(mo).trial(exp).data.FL.gaitedAve.abd'];
            expData(set).motion(mo).allEfforts.RL.gaitedAve.hip = ...
           [expData(set).motion(mo).allEfforts.RL.gaitedAve.hip; expData(set).motion(mo).trial(exp).data.RL.gaitedAve.hip'];
            expData(set).motion(mo).allEfforts.RL.gaitedAve.kne = ...
           [expData(set).motion(mo).allEfforts.RL.gaitedAve.kne; expData(set).motion(mo).trial(exp).data.RL.gaitedAve.kne'];
            expData(set).motion(mo).allEfforts.RL.gaitedAve.abd = ...
           [expData(set).motion(mo).allEfforts.RL.gaitedAve.abd; expData(set).motion(mo).trial(exp).data.RL.gaitedAve.abd'];
            expData(set).motion(mo).allEfforts.FR.gaitedAve.hip = ...
           [expData(set).motion(mo).allEfforts.FR.gaitedAve.hip; expData(set).motion(mo).trial(exp).data.FR.gaitedAve.hip'];
            expData(set).motion(mo).allEfforts.FR.gaitedAve.kne = ...
           [expData(set).motion(mo).allEfforts.FR.gaitedAve.kne; expData(set).motion(mo).trial(exp).data.FR.gaitedAve.kne'];
            expData(set).motion(mo).allEfforts.FR.gaitedAve.abd = ...
           [expData(set).motion(mo).allEfforts.FR.gaitedAve.abd; expData(set).motion(mo).trial(exp).data.FR.gaitedAve.abd'];
            expData(set).motion(mo).allEfforts.RR.gaitedAve.hip = ...
           [expData(set).motion(mo).allEfforts.RR.gaitedAve.hip; expData(set).motion(mo).trial(exp).data.RR.gaitedAve.hip'];
            expData(set).motion(mo).allEfforts.RR.gaitedAve.kne = ...
           [expData(set).motion(mo).allEfforts.RR.gaitedAve.kne; expData(set).motion(mo).trial(exp).data.RR.gaitedAve.kne'];
            expData(set).motion(mo).allEfforts.RR.gaitedAve.abd = ...
           [expData(set).motion(mo).allEfforts.RR.gaitedAve.abd; expData(set).motion(mo).trial(exp).data.RR.gaitedAve.abd'];
        end
        
        % Check length of concatated data for max length
        if maxLength < length(expData(set).motion(mo).allEfforts.FL.Effort.hip)
            maxLength = length(expData(set).motion(mo).allEfforts.FL.Effort.hip);
        end
    end
end


%% Plot Manual Twist Input Density per Each Motion
screensize = get(0, 'ScreenSize');
for set = 3:length(expData)
    for mo = 3:length(expData(set).motion)

        setMo = figure(WindowState="maximized");     %('Visible','off');
        tiledlayout(3,1, 'TileSpacing','Compact','Padding','Compact')
        
        % Plot all linX
        nexttile
        for exp = 1:length(expData(set).motion(mo).trial)
            area(expData(set).motion(mo).trial(exp).manTwist.time, ...
                 expData(set).motion(mo).trial(exp).manTwist.linX, ...
                 0, 'EdgeColor','none','FaceColor','k','FaceAlpha',0.2)
            hold on
        end
        xlabel('Time [s]')
        ylabel('Input')
        title('Linear X (Forwards-backwards Translation)')
        ylim([-1,1])
    
        % Plot all linY
        nexttile
        for exp = 1:length(expData(set).motion(mo).trial)
            area(expData(set).motion(mo).trial(exp).manTwist.time, ...
                 expData(set).motion(mo).trial(exp).manTwist.linY, ...
                 0, 'EdgeColor','none','FaceColor','k','FaceAlpha',0.2)
            hold on
        end
        xlabel('Time [s]')
        ylabel('Input')
        title('Linear Y (Left-Right Translation)')
        ylim([-1,1])

        % Plot all angZ
        nexttile
        for exp = 1:length(expData(set).motion(mo).trial)
            area(expData(set).motion(mo).trial(exp).manTwist.time, ...
                 expData(set).motion(mo).trial(exp).manTwist.angZ, ...
                 0, 'EdgeColor','none','FaceColor','k','FaceAlpha',0.2)
            hold on
        end
        xlabel('Time [s]')
        ylabel('Input')
        title('Angular Z (Left-Right Turning)')
        ylim([-1,1])

        sgtitle(strcat("Vision 60 Joystick Inputs for '", expData(set).name,...
            "' ", strrep(expData(set).motion(mo).name, "mo", "Motion "), " Experiments"))
        saveName = strcat("../../../pictures/2023_tests/manTwistDensity/V60ManTwist_", ...
                          expData(set).name, "_", expData(set).motion(mo).name);
        saveas(setMo, saveName, 'jpg')
    end
end
close all

%% Set Up Box Plots
testNames = ["Baseline";
             "Both_Mo1";
             "Both_Mo2";
             "Both_Mo3";
             "Arm_Mo1";
             "Arm_Mo2";
             "Arm_Mo3";
             "Body_Mo1";
             "Body_Mo2";
             "Body_Mo3"];

abvNames  = ["ba";
             "B1";
             "B2";
             "B3";
             "A1";
             "A2";
             "A3";
             "v1";
             "v2";
             "v3"];

% Box Twists
manualTwistLinX = nan(maxLength, size(testNames,1));
manualTwistLinY = nan(maxLength, size(testNames,1));
manualTwistAngZ = nan(maxLength, size(testNames,1));
% Box Angles
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
% Box Efforts
FLHipEfforts = nan(maxLength, size(testNames,1));
FLKneEfforts = nan(maxLength, size(testNames,1));
FLAbdEfforts = nan(maxLength, size(testNames,1));
RLHipEfforts = nan(maxLength, size(testNames,1));
RLKneEfforts = nan(maxLength, size(testNames,1));
RLAbdEfforts = nan(maxLength, size(testNames,1));
FRHipEfforts = nan(maxLength, size(testNames,1));
FRKneEfforts = nan(maxLength, size(testNames,1));
FRAbdEfforts = nan(maxLength, size(testNames,1));
RRHipEfforts = nan(maxLength, size(testNames,1));
RRKneEfforts = nan(maxLength, size(testNames,1));
RRAbdEfforts = nan(maxLength, size(testNames,1));
% Box Gait Ave Efforts
FLHipGaitAve_Eff = nan(maxLength, size(testNames,1));
FLKneGaitAve_Eff = nan(maxLength, size(testNames,1));
FLAbdGaitAve_Eff = nan(maxLength, size(testNames,1));
RLHipGaitAve_Eff = nan(maxLength, size(testNames,1));
RLKneGaitAve_Eff = nan(maxLength, size(testNames,1));
RLAbdGaitAve_Eff = nan(maxLength, size(testNames,1));
FRHipGaitAve_Eff = nan(maxLength, size(testNames,1));
FRKneGaitAve_Eff = nan(maxLength, size(testNames,1));
FRAbdGaitAve_Eff = nan(maxLength, size(testNames,1));
RRHipGaitAve_Eff = nan(maxLength, size(testNames,1));
RRKneGaitAve_Eff = nan(maxLength, size(testNames,1));
RRAbdGaitAve_Eff = nan(maxLength, size(testNames,1));

n = 0;
for set = 3:numSet
    motionDir = dir(strcat(setDir(set).folder, '\', setDir(set).name));
    numMo = size(motionDir,1);

    for mo = 3:numMo
        n = n + 1;

        manualTwistLinX(1:length(expData(set).motion(mo).allTwists.linX), n) = expData(set).motion(mo).allTwists.linX;
        manualTwistLinY(1:length(expData(set).motion(mo).allTwists.linY), n) = expData(set).motion(mo).allTwists.linY;
        manualTwistAngZ(1:length(expData(set).motion(mo).allTwists.angZ), n) = expData(set).motion(mo).allTwists.angZ;
        
        FLHipAngles(1:length(expData(set).motion(mo).allAngles.FL.hip), n) = expData(set).motion(mo).allAngles.FL.hip;
        FLKneAngles(1:length(expData(set).motion(mo).allAngles.FL.kne), n) = expData(set).motion(mo).allAngles.FL.kne;
        FLAbdAngles(1:length(expData(set).motion(mo).allAngles.FL.abd), n) = expData(set).motion(mo).allAngles.FL.abd;
        RLHipAngles(1:length(expData(set).motion(mo).allAngles.RL.hip), n) = expData(set).motion(mo).allAngles.RL.hip;
        RLKneAngles(1:length(expData(set).motion(mo).allAngles.RL.kne), n) = expData(set).motion(mo).allAngles.RL.kne;
        RLAbdAngles(1:length(expData(set).motion(mo).allAngles.RL.abd), n) = expData(set).motion(mo).allAngles.RL.abd;
        FRHipAngles(1:length(expData(set).motion(mo).allAngles.FR.hip), n) = expData(set).motion(mo).allAngles.FR.hip;
        FRKneAngles(1:length(expData(set).motion(mo).allAngles.FR.kne), n) = expData(set).motion(mo).allAngles.FR.kne;
        FRAbdAngles(1:length(expData(set).motion(mo).allAngles.FR.abd), n) = expData(set).motion(mo).allAngles.FR.abd;
        RRHipAngles(1:length(expData(set).motion(mo).allAngles.RR.hip), n) = expData(set).motion(mo).allAngles.RR.hip;
        RRKneAngles(1:length(expData(set).motion(mo).allAngles.RR.kne), n) = expData(set).motion(mo).allAngles.RR.kne;
        RRAbdAngles(1:length(expData(set).motion(mo).allAngles.RR.abd), n) = expData(set).motion(mo).allAngles.RR.abd;
        
        FLHipEfforts(1:length(expData(set).motion(mo).allEfforts.FL.Effort.hip), n) = expData(set).motion(mo).allEfforts.FL.Effort.hip;
        FLKneEfforts(1:length(expData(set).motion(mo).allEfforts.FL.Effort.kne), n) = expData(set).motion(mo).allEfforts.FL.Effort.kne;
        FLAbdEfforts(1:length(expData(set).motion(mo).allEfforts.FL.Effort.abd), n) = expData(set).motion(mo).allEfforts.FL.Effort.abd;
        RLHipEfforts(1:length(expData(set).motion(mo).allEfforts.RL.Effort.hip), n) = expData(set).motion(mo).allEfforts.RL.Effort.hip;
        RLKneEfforts(1:length(expData(set).motion(mo).allEfforts.RL.Effort.kne), n) = expData(set).motion(mo).allEfforts.RL.Effort.kne;
        RLAbdEfforts(1:length(expData(set).motion(mo).allEfforts.RL.Effort.abd), n) = expData(set).motion(mo).allEfforts.RL.Effort.abd;
        FRHipEfforts(1:length(expData(set).motion(mo).allEfforts.FR.Effort.hip), n) = expData(set).motion(mo).allEfforts.FR.Effort.hip;
        FRKneEfforts(1:length(expData(set).motion(mo).allEfforts.FR.Effort.kne), n) = expData(set).motion(mo).allEfforts.FR.Effort.kne;
        FRAbdEfforts(1:length(expData(set).motion(mo).allEfforts.FR.Effort.abd), n) = expData(set).motion(mo).allEfforts.FR.Effort.abd;
        RRHipEfforts(1:length(expData(set).motion(mo).allEfforts.RR.Effort.hip), n) = expData(set).motion(mo).allEfforts.RR.Effort.hip;
        RRKneEfforts(1:length(expData(set).motion(mo).allEfforts.RR.Effort.kne), n) = expData(set).motion(mo).allEfforts.RR.Effort.kne;
        RRAbdEfforts(1:length(expData(set).motion(mo).allEfforts.RR.Effort.abd), n) = expData(set).motion(mo).allEfforts.RR.Effort.abd;

        FLHipGaitAve_Eff(1:length(expData(set).motion(mo).allEfforts.FL.gaitedAve.hip), n) = expData(set).motion(mo).allEfforts.FL.gaitedAve.hip;
        FLKneGaitAve_Eff(1:length(expData(set).motion(mo).allEfforts.FL.gaitedAve.kne), n) = expData(set).motion(mo).allEfforts.FL.gaitedAve.kne;
        FLAbdGaitAve_Eff(1:length(expData(set).motion(mo).allEfforts.FL.gaitedAve.abd), n) = expData(set).motion(mo).allEfforts.FL.gaitedAve.abd;
        RLHipGaitAve_Eff(1:length(expData(set).motion(mo).allEfforts.RL.gaitedAve.hip), n) = expData(set).motion(mo).allEfforts.RL.gaitedAve.hip;
        RLKneGaitAve_Eff(1:length(expData(set).motion(mo).allEfforts.RL.gaitedAve.kne), n) = expData(set).motion(mo).allEfforts.RL.gaitedAve.kne;
        RLAbdGaitAve_Eff(1:length(expData(set).motion(mo).allEfforts.RL.gaitedAve.abd), n) = expData(set).motion(mo).allEfforts.RL.gaitedAve.abd;
        FRHipGaitAve_Eff(1:length(expData(set).motion(mo).allEfforts.FR.gaitedAve.hip), n) = expData(set).motion(mo).allEfforts.FR.gaitedAve.hip;
        FRKneGaitAve_Eff(1:length(expData(set).motion(mo).allEfforts.FR.gaitedAve.kne), n) = expData(set).motion(mo).allEfforts.FR.gaitedAve.kne;
        FRAbdGaitAve_Eff(1:length(expData(set).motion(mo).allEfforts.FR.gaitedAve.abd), n) = expData(set).motion(mo).allEfforts.FR.gaitedAve.abd;
        RRHipGaitAve_Eff(1:length(expData(set).motion(mo).allEfforts.RR.gaitedAve.hip), n) = expData(set).motion(mo).allEfforts.RR.gaitedAve.hip;
        RRKneGaitAve_Eff(1:length(expData(set).motion(mo).allEfforts.RR.gaitedAve.kne), n) = expData(set).motion(mo).allEfforts.RR.gaitedAve.kne;
        RRAbdGaitAve_Eff(1:length(expData(set).motion(mo).allEfforts.RR.gaitedAve.abd), n) = expData(set).motion(mo).allEfforts.RR.gaitedAve.abd;
    end
end
maxAllTwists  = max([max(max(manualTwistLinX)), max(max(manualTwistLinY)), max(max(manualTwistAngZ))]);
maxAllAngles  = max([max(max(FLHipAngles)), max(max(FLKneAngles)), max(max(FLAbdAngles)),...
                     max(max(RLHipAngles)), max(max(RLKneAngles)), max(max(RLAbdAngles)),...
                     max(max(FRHipAngles)), max(max(FRKneAngles)), max(max(FRAbdAngles)),...
                     max(max(RRHipAngles)), max(max(RRKneAngles)), max(max(RRAbdAngles))]);
minAllAngles  = min([min(min(FLHipAngles)), min(min(FLKneAngles)), min(min(FLAbdAngles)),...
                     min(min(RLHipAngles)), min(min(RLKneAngles)), min(min(RLAbdAngles)),...
                     min(min(FRHipAngles)), min(min(FRKneAngles)), min(min(FRAbdAngles)),...
                     min(min(RRHipAngles)), min(min(RRKneAngles)), min(min(RRAbdAngles))]);
maxAllEffort  = max([max(max(FLHipEfforts)), max(max(FLKneEfforts)), max(max(FLAbdEfforts)),...
                     max(max(RLHipEfforts)), max(max(RLKneEfforts)), max(max(RLAbdEfforts)),...
                     max(max(FRHipEfforts)), max(max(FRKneEfforts)), max(max(FRAbdEfforts)),...
                     max(max(RRHipEfforts)), max(max(RRKneEfforts)), max(max(RRAbdEfforts))]);
maxGaitAveEff = max([max(max(FLHipGaitAve_Eff)), max(max(FLKneGaitAve_Eff)), max(max(FLAbdGaitAve_Eff)),...
                     max(max(RLHipGaitAve_Eff)), max(max(RLKneGaitAve_Eff)), max(max(RLAbdGaitAve_Eff)),...
                     max(max(FRHipGaitAve_Eff)), max(max(FRKneGaitAve_Eff)), max(max(FRAbdGaitAve_Eff)),...
                     max(max(RRHipGaitAve_Eff)), max(max(RRKneGaitAve_Eff)), max(max(RRAbdGaitAve_Eff))]);

minAllTwists  = -maxAllTwists %* 0.03;
maxAllEffort  = ceil(maxAllEffort/10)*10;
minAllEffort  = -maxAllEffort * 0.03;
maxGaitAveEff = ceil(maxGaitAveEff/10)*10;
minGaitAveEff = -maxGaitAveEff * 0.03;

