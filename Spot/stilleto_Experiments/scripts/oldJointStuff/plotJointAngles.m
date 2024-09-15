function plotJointAngles(Pos, path)
    
    maxTime = max([max(Pos.time)]);
    scriptLoc = fileparts(matlab.desktop.editor.getActiveFilename);
    test = string(extractBetween(path, 'bag_files\', '\'));
    name = string(extractBetween(path, '\_', '-joint'));

%% Joint Position
%     maxHX = max([max(Pos.FL_hipX), max(Pos.FR_hipX), max(Pos.RL_hipX), max(Pos.RR_hipX)]);
%     maxHY = max([max(Pos.FL_hipY), max(Pos.FR_hipY), max(Pos.RL_hipY), max(Pos.RR_hipY)]);
    maxKn = max([max(Pos.FL_knee), max(Pos.FR_knee), max(Pos.RL_knee), max(Pos.RR_knee)]);

%     minHX = min([min(Pos.FL_hipX), min(Pos.FR_hipX), min(Pos.RL_hipX), min(Pos.RR_hipX)]);
%     minHY = min([min(Pos.FL_hipY), min(Pos.FR_hipY), min(Pos.RL_hipY), min(Pos.RR_hipY)]);
    minKn = min([min(Pos.FL_knee), min(Pos.FR_knee), min(Pos.RL_knee), min(Pos.RR_knee)]);

%     maxJS  = max([maxHX, maxHY, maxKn]);
%     minJS  = min([minHX, minHY, minKn]);
    maxJS  = maxKn;
    minJS  = minKn;

    PosFig = 3;
    figure(PosFig);

    subplot(2,2,1);
%     plot(Pos.time, Pos.FL_hipX, Pos.time, Pos.FL_hipY, Pos.time, Pos.FL_knee);
    plot(Pos.time, Pos.FL_knee);
    title('Front Left Leg');
%     legend('HipX', 'HipY', 'Knee')
    xlim([0, maxTime])
    ylim([minJS, maxJS])
    
    subplot(2,2,2);
%     plot(Pos.time, Pos.FR_hipX, Pos.time, Pos.FR_hipY, Pos.time, Pos.FR_knee);
    plot(Pos.time, Pos.FR_knee);
    title('Front Right Leg');
%     legend('HipX', 'HipY', 'Knee')
    xlim([0, maxTime])
    ylim([minJS, maxJS])
    
    subplot(2,2,3);
%     plot(Pos.time, Pos.RL_hipX, Pos.time, Pos.RL_hipY, Pos.time, Pos.RL_knee);
    plot(Pos.time, Pos.RL_knee);
    title('Rear Left Leg');
    ylabel('Knee Angle [rads]')
    xlabel('Time [s]')
    xlim([0, maxTime])
    ylim([minJS, maxJS])
    
    subplot(2,2,4);
%     plot(Pos.time, Pos.RR_hipX, Pos.time, Pos.RR_hipY, Pos.time, Pos.RR_knee);
    plot(Pos.time, Pos.RR_knee);
    title('Rear Right Leg');
%     legend('HipX', 'HipY', 'Knee')
    xlim([0, maxTime])
    ylim([minJS, maxJS])

%     Lgnd = legend('HipX', 'HipY', 'Knee');
%     Lgnd.Position(1) = 0.01;
%     Lgnd.Position(2) = 0.435;
    
    sgtitle('Knee Angles - Radians Over Time')
    set(PosFig, 'Position',  [10, 30, 1100, 650])

    PosName = strcat(scriptLoc,'\stiletto_bag_files\',test,'\_',name,'-KneeAngles');
    saveas(PosFig, PosName, 'jpg')

end



