function plotJointEfforts(JS, Odo, path)
    
    maxTime = max([max(Odo.time), max(JS.time)]);
    scriptLoc = fileparts(matlab.desktop.editor.getActiveFilename);
    test = string(extractBetween(path, 'bag_files\', '\'));
    
    name = string(extractBetween(path, '\_', '-joint'));
    fprintf(strcat('Plotting "', test, ': "', name, '"\n')

%% Joint Efforts
    maxHX = max([max(JS.FL_hipX), max(JS.FR_hipX), max(JS.RL_hipX), max(JS.RR_hipX)]);
    maxHY = max([max(JS.FL_hipY), max(JS.FR_hipY), max(JS.RL_hipY), max(JS.RR_hipY)]);
    maxKn = max([max(JS.FL_knee), max(JS.FR_knee), max(JS.RL_knee), max(JS.RR_knee)]);

    minHX = min([min(JS.FL_hipX), min(JS.FR_hipX), min(JS.RL_hipX), min(JS.RR_hipX)]);
    minHY = min([min(JS.FL_hipY), min(JS.FR_hipY), min(JS.RL_hipY), min(JS.RR_hipY)]);
    minKn = min([min(JS.FL_knee), min(JS.FR_knee), min(JS.RL_knee), min(JS.RR_knee)]);

    maxJS  = max([maxHX, maxHY, maxKn]);
    minJS  = min([minHX, minHY, minKn]);

    JSFig = 1;
    figure(JSFig)

    subplot(2,2,1);
    plot(JS.time, JS.FL_hipX, JS.time, JS.FL_hipY, JS.time, JS.FL_knee);
    title('Front Left Leg');
%     legend('HipX', 'HipY', 'Knee')
    xlim([0, maxTime])
    ylim([minJS, maxJS])
    
    subplot(2,2,2);
    plot(JS.time, JS.FR_hipX, JS.time, JS.FR_hipY, JS.time, JS.FR_knee);
    title('Front Right Leg');
%     legend('HipX', 'HipY', 'Knee')
    xlim([0, maxTime])
    ylim([minJS, maxJS])
    
    subplot(2,2,3);
    plot(JS.time, JS.RL_hipX, JS.time, JS.RL_hipY, JS.time, JS.RL_knee);
    title('Rear Left Leg');
%     legend('HipX', 'HipY', 'Knee')
    xlim([0, maxTime])
    ylim([minJS, maxJS])
    ylabel('Joint Efforts')
    xlabel('Time [s]')
    
    subplot(2,2,4);
    plot(JS.time, JS.RR_hipX, JS.time, JS.RR_hipY, JS.time, JS.RR_knee);
    title('Rear Right Leg');
%     legend('HipX', 'HipY', 'Knee')
    xlim([0, maxTime])
    ylim([minJS, maxJS])

    Lgnd = legend('HipX', 'HipY', 'Knee');
    Lgnd.Position(1) = 0.01;
    Lgnd.Position(2) = 0.435;
    
    sgtitle('Joint Efforts')
    set(JSFig, 'Position',  [10, 30, 1100, 650])

    JSName = strcat(scriptLoc,'\stiletto_bag_files\',test,'\_',name,'-JointEffort');
    saveas(JSFig, JSName, 'jpg')


%% Odometry
    maxOdo = max([max(Odo.linX), max(Odo.linY), max(Odo.linZ), ...
                  max(Odo.angX), max(Odo.angX), max(Odo.angX)]);
    minOdo = min([min(Odo.linX), min(Odo.linY), min(Odo.linZ), ...
                  min(Odo.angX), min(Odo.angX), min(Odo.angX)]);
    
    OdoFig = 2;
    figure(OdoFig)

    subplot(3,2,1);
    plot(Odo.time, Odo.linX);
    title('Linear X (Forward-Backwards)');
    xlim([0, maxTime])
    ylim([minOdo, maxOdo])
    
    subplot(3,2,3);
    plot(Odo.time, Odo.linY);
    title('Linear Y (Left-Right)');
    xlim([0, maxTime])
    ylim([minOdo, maxOdo])
    
    subplot(3,2,5);
    plot(Odo.time, Odo.linZ);
    title('Linear Z (Height)');
    xlim([0, maxTime])
    ylim([minOdo, maxOdo])
    ylabel('Joystick Input')
    xlabel('Time [s]')
    
    subplot(3,2,2);
    plot(Odo.time, Odo.angX);
    title('Angular X (Roll)');
    xlim([0, maxTime])
    ylim([minOdo, maxOdo])
    
    subplot(3,2,4);
    plot(Odo.time, Odo.angY);
    title('Angular Y (Pitch)');
    xlim([0, maxTime])
    ylim([minOdo, maxOdo])
    
    subplot(3,2,6);
    plot(Odo.time, Odo.angZ);
    title('Angular Z (Yaw)');
    xlim([0, maxTime])
    ylim([minOdo, maxOdo])
    
    sgtitle('Odometry Twist - Joystick Input Over Time')
    set(OdoFig, 'Position',  [10, 30, 1100, 650])
    
    OdoName = strcat(scriptLoc,'\stiletto_bag_files\',test,'\_',name,'-OdomTwist');
    saveas(OdoFig, OdoName, 'jpg')


end



