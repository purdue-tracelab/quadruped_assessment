function plotJointAngles(Pos, path)
    
    maxTime = max([max(Pos.time)]);
    scriptLoc = fileparts(matlab.desktop.editor.getActiveFilename);
    test = string(extractBetween(path, 'bag_files\', '\'));
    name = string(extractBetween(path, '\_', '-joint'));

    maxKn = max([max(Pos.FL_knee), max(Pos.FR_knee), max(Pos.RL_knee), max(Pos.RR_knee)]);


    minKn = min([min(Pos.FL_knee), min(Pos.FR_knee), min(Pos.RL_knee), min(Pos.RR_knee)]);


    maxJS  = maxKn;
    minJS  = minKn;

    PosFig = 3;
    figure(PosFig);

    subplot(2,2,1);
    plot(Pos.time, Pos.FL_knee);
    title('Front Left Leg');
    xlim([0, maxTime])
    ylim([minJS, maxJS])
    
    subplot(2,2,2);
    plot(Pos.time, Pos.FR_knee);
    title('Front Right Leg');
    xlim([0, maxTime])
    ylim([minJS, maxJS])
    
    subplot(2,2,3);
    plot(Pos.time, Pos.RL_knee);
    title('Rear Left Leg');
    ylabel('Knee Angle [rads]')
    xlabel('Time [s]')
    xlim([0, maxTime])
    ylim([minJS, maxJS])
    
    subplot(2,2,4);
    plot(Pos.time, Pos.RR_knee);
    title('Rear Right Leg');
    xlim([0, maxTime])
    ylim([minJS, maxJS])

    
    sgtitle('Knee Angles - Radians Over Time')
    set(PosFig, 'Position',  [10, 30, 1100, 650])

    PosName = strcat(scriptLoc,'\stiletto_bag_files\',test,'\_',name,'-KneeAngles');
    saveas(PosFig, PosName, 'jpg')

end



