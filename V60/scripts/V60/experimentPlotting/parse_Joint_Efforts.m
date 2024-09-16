function jointEffort = parse_Joint_Efforts(expTable, setName, moName, expName)
%{
    Takes imported csv data with trial name and seperates the data into
    important information such as toe contact, time, and efforts. However,
    it only uses the efforts of a leg during the time the leg's toe is
    contacting the surface.

    It then uses 'getGaitingAverages.m' to calculate a running average of
    the efforts to make it easier to look at. V60 data was recorded at
    approx 37 frames/per stepping cycle. The gait average is a running
    average of the 18 frames before and after each timestep.

    The Root Mean Square (RMS) of the data is also taken at the gaited
    interval using 'getGaitingRMS.m' similarly to the averages but uses the
    rms func intead of the mean.

    This data is then plotted with 'plotJoint_Efforts_Contact.m', 
    'plotGaitingAverages.m', and 'plotGaitingRMS.m'
%}

    % titleName = strcat("All Joint Efforts,  Trial: ", setName, " Active, ", moName, "-", expName);
    jointEffort.set = setName;
    jointEffort.motion = moName;
    jointEffort.exp = expName;
    
    toe0c = expTable.x_mcu_state_toe_array_toes_0_contact;
    toe1c = expTable.x_mcu_state_toe_array_toes_1_contact;
    toe2c = expTable.x_mcu_state_toe_array_toes_2_contact;
    toe3c = expTable.x_mcu_state_toe_array_toes_3_contact;

    toeFL_contact = [];
    toeRL_contact = [];
    toeFR_contact = [];
    toeRR_contact = [];
    
    %% Filter Toe Contacts
    j0 = 0;
    j1 = 0;
    j2 = 0;
    j3 = 0;

    for i = 1:size(expTable.x__time, 1)
        % Determine when each foot is contacting the ground
        % if for i, when contact = 1, 1, when =0, 0, when =nan, do nothing
        if toe0c(i) == 1
            toeFL_contact = 1;
        elseif toe0c(i) == 0
            toeFL_contact = 0;
        end
        if toe1c(i) == 1
            toeRL_contact = 1;
        elseif toe1c(i) == 0
            toeRL_contact = 0;
        end
        if toe2c(i) == 1
            toeFR_contact = 1;
        elseif toe2c(i) == 0
            toeFR_contact = 0;
        end
        if toe3c(i) == 1
            toeRR_contact = 1;
        elseif toe3c(i) == 0
            toeRR_contact = 0;
        end
        
        % Saves the efforts for only when the toe is contacting the ground.
        %   All other efforts for when the feet are touching is unimportant
        if ~isnan(expTable.x_mcu_state_jointURDF_0_effort(i))
            if toeFL_contact
                j0 = j0 + 1;
                timeFL(j0, 1) = expTable.x__time(i);
                hip_E_FL(j0, 1) = expTable.x_mcu_state_jointURDF_0_effort(i);
                kne_E_FL(j0, 1) = expTable.x_mcu_state_jointURDF_1_effort(i);
                abd_E_FL(j0, 1) = expTable.x_mcu_state_jointURDF_8_effort(i); 
            end

            if toeRL_contact
                j1 = j1 + 1;
                timeRL(j1, 1) = expTable.x__time(i);
                hip_E_RL(j1, 1) = expTable.x_mcu_state_jointURDF_2_effort(i);
                kne_E_RL(j1, 1) = expTable.x_mcu_state_jointURDF_3_effort(i);
                abd_E_RL(j1, 1) = expTable.x_mcu_state_jointURDF_9_effort(i);
            end

            if toeFR_contact
                j2 = j2 + 1;
                timeFR(j2, 1) = expTable.x__time(i);
                hip_E_FR(j2, 1) = expTable.x_mcu_state_jointURDF_4_effort(i);
                kne_E_FR(j2, 1) = expTable.x_mcu_state_jointURDF_5_effort(i);
                abd_E_FR(j2, 1) = expTable.x_mcu_state_jointURDF_10_effort(i);
            end

            if toeRR_contact
                j3 = j3 + 1;
                timeRR(j3, 1) = expTable.x__time(i);
                hip_E_RR(j3, 1) = expTable.x_mcu_state_jointURDF_6_effort(i);
                kne_E_RR(j3, 1) = expTable.x_mcu_state_jointURDF_7_effort(i);
                abd_E_RR(j3, 1) = expTable.x_mcu_state_jointURDF_11_effort(i);
            end
        end
    end
    
    %% Structure
    % Creates a structure of the data for passing to functions

    % Time
    jointEffort.FL.time = timeFL;
    jointEffort.RL.time = timeRL;
    jointEffort.FR.time = timeFR;
    jointEffort.RR.time = timeRR;

    % Hip
    jointEffort.FL.Effort.hip = abs(hip_E_FL);
    jointEffort.RL.Effort.hip = abs(hip_E_RL);
    jointEffort.FR.Effort.hip = abs(hip_E_FR);
    jointEffort.RR.Effort.hip = abs(hip_E_RR);

    % Knee
    jointEffort.FL.Effort.kne = abs(kne_E_FL);
    jointEffort.RL.Effort.kne = abs(kne_E_RL);
    jointEffort.FR.Effort.kne = abs(kne_E_FR);
    jointEffort.RR.Effort.kne = abs(kne_E_RR);

    % Abductor
    jointEffort.FL.Effort.abd = abs(abd_E_FL);
    jointEffort.RL.Effort.abd = abs(abd_E_RL);
    jointEffort.FR.Effort.abd = abs(abd_E_FR);
    jointEffort.RR.Effort.abd = abs(abd_E_RR);

    %% Gaiting Averages
    jointEffort.FL.gaitedAve.hip = getGaitingAverages(jointEffort.FL.Effort.hip);
    jointEffort.RL.gaitedAve.hip = getGaitingAverages(jointEffort.RL.Effort.hip);
    jointEffort.FR.gaitedAve.hip = getGaitingAverages(jointEffort.FR.Effort.hip);
    jointEffort.RR.gaitedAve.hip = getGaitingAverages(jointEffort.RR.Effort.hip);

    jointEffort.FL.gaitedAve.kne = getGaitingAverages(jointEffort.FL.Effort.kne);
    jointEffort.RL.gaitedAve.kne = getGaitingAverages(jointEffort.RL.Effort.kne);
    jointEffort.FR.gaitedAve.kne = getGaitingAverages(jointEffort.FR.Effort.kne);
    jointEffort.RR.gaitedAve.kne = getGaitingAverages(jointEffort.RR.Effort.kne);

    jointEffort.FL.gaitedAve.abd = getGaitingAverages(jointEffort.FL.Effort.abd);
    jointEffort.RL.gaitedAve.abd = getGaitingAverages(jointEffort.RL.Effort.abd);
    jointEffort.FR.gaitedAve.abd = getGaitingAverages(jointEffort.FR.Effort.abd);
    jointEffort.RR.gaitedAve.abd = getGaitingAverages(jointEffort.RR.Effort.abd);



    %% Gaiting RMS
    jointEffort.FL.gaitedRMS.hip = getGaitingRMS(jointEffort.FL.Effort.hip);
    jointEffort.RL.gaitedRMS.hip = getGaitingRMS(jointEffort.RL.Effort.hip);
    jointEffort.FR.gaitedRMS.hip = getGaitingRMS(jointEffort.FR.Effort.hip);
    jointEffort.RR.gaitedRMS.hip = getGaitingRMS(jointEffort.RR.Effort.hip);

    jointEffort.FL.gaitedRMS.kne = getGaitingRMS(jointEffort.FL.Effort.kne);
    jointEffort.RL.gaitedRMS.kne = getGaitingRMS(jointEffort.RL.Effort.kne);
    jointEffort.FR.gaitedRMS.kne = getGaitingRMS(jointEffort.FR.Effort.kne);
    jointEffort.RR.gaitedRMS.kne = getGaitingRMS(jointEffort.RR.Effort.kne);

    jointEffort.FL.gaitedRMS.abd = getGaitingRMS(jointEffort.FL.Effort.abd);
    jointEffort.RL.gaitedRMS.abd = getGaitingRMS(jointEffort.RL.Effort.abd);
    jointEffort.FR.gaitedRMS.abd = getGaitingRMS(jointEffort.FR.Effort.abd);
    jointEffort.RR.gaitedRMS.abd = getGaitingRMS(jointEffort.RR.Effort.abd);
    
    %% Gaiting Time
    jointEffort.FL.gaitedTime = jointEffort.FL.time(1+18:end-18);
    jointEffort.RL.gaitedTime = jointEffort.RL.time(1+18:end-18);
    jointEffort.FR.gaitedTime = jointEffort.FR.time(1+18:end-18);
    jointEffort.RR.gaitedTime = jointEffort.RR.time(1+18:end-18);
    


end





