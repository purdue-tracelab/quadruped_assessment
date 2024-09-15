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

dataFolderPath = '../experiment_data/2024_tests_REDO/';
setDir = dir(dataFolderPath);
numSet = size(setDir,1);            % = num of exp + 2 ('.', '..')

% hipLim = 72.67;
% kneLim = 98.8;
% abdLim = 98.8;

%% Parse Data
% init stuff
maxLength  = 0;
r = 0;

% Sort experiment set (BothDRS, JustArm, JustBody, ...)
for set = 3:numSet
    %for set = 3
    motionDir = dir(strcat(setDir(set).folder, '\', setDir(set).name));
    numMo = size(motionDir,1);      % = num of mo + 2 ('.', '..')

    % Sorts Motion type (none, low, heavy, stilletto)
    for mo = 3:numMo
        %for mo = 5
        expDirPath = strcat(motionDir(mo).folder, '\', motionDir(mo).name, '\');
        expDir = dir(strcat(expDirPath, '*.txt'));      
        numExp = size(expDir,1);
        
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
            %for exp = 9
            expDataPath = strcat(expDir(mo).folder, '\experiment_', string(exp), '.txt');

            expTable = readtable(expDataPath);      % Retreive Data from csv
            expTable.Time = expTable.Seconds + expTable.nanoS*1e-9;
            expTable.Time = expTable.Time    - expTable.Time(1);  % Normalized time

            setName = setDir(set).name;
            moName  = motionDir(mo).name;
            expName = strcat('exp', string(exp));

            expData(set).name = setName;
            expData(set).motion(mo).name = moName;
            expData(set).motion(mo).trial(exp).name = expName;
            
%             gaitFrame = getGaitFrames(expTable);
%             if gaitFrame > 5
%                 r = r + 1;
%                 aveGaitFrame(r,1) = gaitFrame;
%             end

            expData(set).motion(mo).trial(exp).angles = ...
                    parse_Angles(expTable, setName, moName, expName);
            expData(set).motion(mo).trial(exp).data  = ...
                    parse_Joint_Efforts(expTable, setName, moName, expName);
            
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
% frameNum = round(mean(aveGaitFrame));     % ave frame = 37

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
             "s1";
             "s2";
             "s3"];
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

% Sort through each experiment type and motion and add data to form matrix
n = 0;
for set = 3:numSet
    motionDir = dir(strcat(setDir(set).folder, '\', setDir(set).name));
    numMo = size(motionDir,1);

    for mo = 3:numMo
        n = n + 1;

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

        FLHipGaitAve(1:length(expData(set).motion(mo).allEfforts.FL.gaitedAve.hip), n) = expData(set).motion(mo).allEfforts.FL.gaitedAve.hip;
        FLKneGaitAve(1:length(expData(set).motion(mo).allEfforts.FL.gaitedAve.kne), n) = expData(set).motion(mo).allEfforts.FL.gaitedAve.kne;
        FLAbdGaitAve(1:length(expData(set).motion(mo).allEfforts.FL.gaitedAve.abd), n) = expData(set).motion(mo).allEfforts.FL.gaitedAve.abd;
        RLHipGaitAve(1:length(expData(set).motion(mo).allEfforts.RL.gaitedAve.hip), n) = expData(set).motion(mo).allEfforts.RL.gaitedAve.hip;
        RLKneGaitAve(1:length(expData(set).motion(mo).allEfforts.RL.gaitedAve.kne), n) = expData(set).motion(mo).allEfforts.RL.gaitedAve.kne;
        RLAbdGaitAve(1:length(expData(set).motion(mo).allEfforts.RL.gaitedAve.abd), n) = expData(set).motion(mo).allEfforts.RL.gaitedAve.abd;
        FRHipGaitAve(1:length(expData(set).motion(mo).allEfforts.FR.gaitedAve.hip), n) = expData(set).motion(mo).allEfforts.FR.gaitedAve.hip;
        FRKneGaitAve(1:length(expData(set).motion(mo).allEfforts.FR.gaitedAve.kne), n) = expData(set).motion(mo).allEfforts.FR.gaitedAve.kne;
        FRAbdGaitAve(1:length(expData(set).motion(mo).allEfforts.FR.gaitedAve.abd), n) = expData(set).motion(mo).allEfforts.FR.gaitedAve.abd;
        RRHipGaitAve(1:length(expData(set).motion(mo).allEfforts.RR.gaitedAve.hip), n) = expData(set).motion(mo).allEfforts.RR.gaitedAve.hip;
        RRKneGaitAve(1:length(expData(set).motion(mo).allEfforts.RR.gaitedAve.kne), n) = expData(set).motion(mo).allEfforts.RR.gaitedAve.kne;
        RRAbdGaitAve(1:length(expData(set).motion(mo).allEfforts.RR.gaitedAve.abd), n) = expData(set).motion(mo).allEfforts.RR.gaitedAve.abd;
    end
end

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
maxGaitAveEff = max([max(max(FLHipGaitAve)), max(max(FLKneGaitAve)), max(max(FLAbdGaitAve)),...
                     max(max(RLHipGaitAve)), max(max(RLKneGaitAve)), max(max(RLAbdGaitAve)),...
                     max(max(FRHipGaitAve)), max(max(FRKneGaitAve)), max(max(FRAbdGaitAve)),...
                     max(max(RRHipGaitAve)), max(max(RRKneGaitAve)), max(max(RRAbdGaitAve))]);
maxAllEffort  = ceil(maxAllEffort/10)*10;
minAllEffort  = -maxAllEffort * 0.03;
maxGaitAveEff = ceil(maxGaitAveEff/10)*10;
minGaitAveEff = -maxGaitAveEff * 0.03;

%% Box Plotting
%{
fig1 = figure(WindowState="maximized");     %'Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipEfforts, abvNames, "Whisker",15)
ylim([minAllEffort, maxAllEffort])
ylabel('Torque [Nm]')
title('FL Hip')
% yline(hipLim, '--', 'Limit')
nexttile
boxplot(FLKneEfforts, abvNames, "Whisker",15)
ylim([minAllEffort, maxAllEffort])
ylabel('Torque [Nm]')
title('FL Knee')
% yline(kneLim, '--', 'Limit')
nexttile
boxplot(FLAbdEfforts, abvNames, "Whisker",15)
ylim([minAllEffort, maxAllEffort])
ylabel('Torque [Nm]')
title('FL Abductor')
% yline(abdLim, '--', 'Limit')
% FR Leg
nexttile
boxplot(FRHipEfforts, abvNames, "Whisker",15)
ylim([minAllEffort, maxAllEffort])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneEfforts, abvNames, "Whisker",15)
ylim([minAllEffort, maxAllEffort])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdEfforts, abvNames, "Whisker",15)
ylim([minAllEffort, maxAllEffort])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipEfforts, abvNames, "Whisker",15)
ylim([minAllEffort, maxAllEffort])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneEfforts, abvNames, "Whisker",15)
ylim([minAllEffort, maxAllEffort])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdEfforts, abvNames, "Whisker",15)
ylim([minAllEffort, maxAllEffort])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipEfforts, testNames, "Whisker",15)
ylim([minAllEffort, maxAllEffort])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneEfforts, testNames, "Whisker",15)
ylim([minAllEffort, maxAllEffort])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdEfforts, testNames, "Whisker",15)
ylim([minAllEffort, maxAllEffort])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot Concatenated Absolute Joint Torques by Experiment Type and Motion')
saveName = "../pictures/spotAbsJointTorques";
saveas(fig1, saveName, 'jpg')
% close

% ===================================================================

fig2 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','tight','Padding','tight')
% FL Leg
nexttile
boxplot(FLHipGaitAve, abvNames, "Whisker",15)
ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Hip')
nexttile
boxplot(FLKneGaitAve, abvNames, "Whisker",15)
ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Knee')
nexttile
boxplot(FLAbdGaitAve, abvNames, "Whisker",15)
ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FL Abductor')
% FR Leg
nexttile
boxplot(FRHipGaitAve, abvNames, "Whisker",15)
ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Hip')
nexttile
boxplot(FRKneGaitAve, abvNames, "Whisker",15)
ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Knee')
nexttile
boxplot(FRAbdGaitAve, abvNames, "Whisker",15)
ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipGaitAve, abvNames, "Whisker",15)
ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Hip')
nexttile
boxplot(RLKneGaitAve, abvNames, "Whisker",15)
ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Knee')
nexttile
boxplot(RLAbdGaitAve, abvNames, "Whisker",15)
ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipGaitAve, testNames, "Whisker",15)
ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Hip')
nexttile
boxplot(RRKneGaitAve, testNames, "Whisker",15)
ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Knee')
nexttile
boxplot(RRAbdGaitAve, testNames, "Whisker",15)
ylim([minGaitAveEff,maxGaitAveEff])
ylabel('Torque [Nm]')
title('AR Abductor')

sgtitle('Spot Concatenated Gaited Average of Absolute Joint Torques by Experiment Type and Motion')
saveName = "../pictures/spotGaitedAveTorques";
saveas(fig2, saveName, 'jpg')
% close

% ====================================================================

fig3 = figure(WindowState="maximized");     %('Visible','off');
tiledlayout(4,3, 'TileSpacing','Compact','Padding','Compact')
% FL Leg
nexttile
boxplot(FLHipAngles, abvNames, "Whisker",15)
ylim([minAllAngles, maxAllAngles])
ylabel('Angle [Radians]')
title('FL Hip')
% yline(hipLim, '--', 'Limit')
nexttile
boxplot(FLKneAngles, abvNames, "Whisker",15)
ylim([minAllAngles, maxAllAngles])
ylabel('Angle [Radians]')
title('FL Knee')
% yline(kneLim, '--', 'Limit')
nexttile
boxplot(FLAbdAngles, abvNames, "Whisker",15)
ylim([minAllAngles, maxAllAngles])
ylabel('Angle [Radians]')
title('FL Abductor')
% yline(abdLim, '--', 'Limit')
% FR Leg
nexttile
boxplot(FRHipAngles, abvNames, "Whisker",15)
ylim([minAllAngles, maxAllAngles])
ylabel('Angle [Radians]')
title('FR Hip')
nexttile
boxplot(FRKneAngles, abvNames, "Whisker",15)
ylim([minAllAngles, maxAllAngles])
ylabel('Angle [Radians]')
title('FR Knee')
nexttile
boxplot(FRAbdAngles, abvNames, "Whisker",15)
ylim([minAllAngles, maxAllAngles])
ylabel('Angle [Radians]')
title('FR Abductor')
% AL Leg
nexttile
boxplot(RLHipAngles, abvNames, "Whisker",15)
ylim([minAllAngles, maxAllAngles])
ylabel('Angle [Radians]')
title('AL Hip')
nexttile
boxplot(RLKneAngles, abvNames, "Whisker",15)
ylim([minAllAngles, maxAllAngles])
ylabel('Angle [Radians]')
title('AL Knee')
nexttile
boxplot(RLAbdAngles, abvNames, "Whisker",15)
ylim([minAllAngles, maxAllAngles])
ylabel('Angle [Radians]')
title('AL Abductor')
% AR Leg
nexttile
boxplot(RRHipAngles, testNames, "Whisker",15)
ylim([minAllAngles, maxAllAngles])
ylabel('Angle [Radians]')
title('AR Hip')
nexttile
boxplot(RRKneAngles, testNames, "Whisker",15)
ylim([minAllAngles, maxAllAngles])
ylabel('Angle [Radians]')
title('AR Knee')
nexttile
boxplot(RRAbdAngles, testNames, "Whisker",15)
ylim([minAllAngles, maxAllAngles])
ylabel('Angle [Radians]')
title('AR Abductor')

sgtitle('Spot Concatenated Joint Angles by Experiment Type and Motion')
saveName = "../pictures/spotJointAngles";
saveas(fig3, saveName, 'jpg')

%}







