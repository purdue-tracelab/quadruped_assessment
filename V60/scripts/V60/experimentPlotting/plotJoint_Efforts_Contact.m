function plotJoint_Efforts_Contact(jointEffort)
% Plots Joint Efforts only during Toe Contact

    setName = jointEffort.set;
    moName  = jointEffort.motion;
    expName = jointEffort.exp;

    titleName = strcat("Contact Joint Efforts,  Trial: ", setName, " Active, ", moName, "-", expName);
    plotName  = strcat('../../../pictures/2023_tests/Contact_Efforts_', setName, '_', moName, '-', expName);
    
    %%
    % Time
    timeFL = jointEffort.FL.time;
    timeRL = jointEffort.RL.time;
    timeFR = jointEffort.FR.time;
    timeRR = jointEffort.RR.time;

    % Hip
    hip_E_FL = jointEffort.FL.Effort.hip;
    hip_E_RL = jointEffort.RL.Effort.hip;
    hip_E_FR = jointEffort.FR.Effort.hip;
    hip_E_RR = jointEffort.RR.Effort.hip;

    % Knee
    kne_E_FL = jointEffort.FL.Effort.kne;
    kne_E_RL = jointEffort.RL.Effort.kne;
    kne_E_FR = jointEffort.FR.Effort.kne; 
    kne_E_RR = jointEffort.RR.Effort.kne;

    % Abductor
    abd_E_FL = jointEffort.FL.Effort.abd;
    abd_E_RL = jointEffort.RL.Effort.abd;
    abd_E_FR = jointEffort.FR.Effort.abd;
    abd_E_RR = jointEffort.RR.Effort.abd;

    %%
    f = figure('Visible','off');
    tiledlayout(2,2, 'TileSpacing','Compact','Padding','Compact')

    nexttile
    plot(timeFL, abd_E_FL, timeFL, hip_E_FL, timeFL, kne_E_FL)
    xlabel('Time [s]')
    ylabel('Front Left Leg Effort  [Nm]')
    
    nexttile
    plot(timeFR, abd_E_FR, timeFR, hip_E_FR, timeFR, kne_E_FR)
    xlabel('Time [s]')
    ylabel('Front Right Leg Effort  [Nm]')

    nexttile
    plot(timeRL, abd_E_RL, timeRL, hip_E_RL, timeRL, kne_E_RL)
    xlabel('Time [s]')
    ylabel('Rear Left Leg Effort  [Nm]')

    nexttile
    plot(timeRR, abd_E_RR, timeRR, hip_E_RR, timeRR, kne_E_RR)
    xlabel('Time [s]')
    ylabel('Rear Right Leg Effort  [Nm]')
    
    l = legend('Abductor', 'Hip', 'Knee', 'Orientation', 'Horizontal');
    l.Layout.Tile = 'north';
    sgtitle(titleName)
    set(gcf, 'Position',  [5, 50, 1120, 620])

    saveas(f,plotName,'jpg')
end







