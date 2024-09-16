function plotBadLeg(JS, Odo, Pos, path)
    
    maxTime = max([max(Odo.time), max(JS.time), max(Pos.time)]);
    scriptLoc = fileparts(matlab.desktop.editor.getActiveFilename);
    test = string(extractBetween(path, 'bag_files\', '\'));
    name = string(extractBetween(path, '\_', '-joint'));

%% Joint Efforts
    maxHX = max([max(JS.FL_hipX), max(JS.FR_hipX), max(JS.RL_hipX), max(JS.RR_hipX)]);
    maxHY = max([max(JS.FL_hipY), max(JS.FR_hipY), max(JS.RL_hipY), max(JS.RR_hipY)]);
    maxKn = max([max(JS.FL_knee), max(JS.FR_knee), max(JS.RL_knee), max(JS.RR_knee)]);

    minHX = min([min(JS.FL_hipX), min(JS.FR_hipX), min(JS.RL_hipX), min(JS.RR_hipX)]);
    minHY = min([min(JS.FL_hipY), min(JS.FR_hipY), min(JS.RL_hipY), min(JS.RR_hipY)]);
    minKn = min([min(JS.FL_knee), min(JS.FR_knee), min(JS.RL_knee), min(JS.RR_knee)]);

    maxJS  = max([maxHX, maxHY, maxKn]);
    minJS  = min([minHX, minHY, minKn]);

    JSFig = 4;
    figure(JSFig)

    subplot(3,1,1);
    plot(JS.time, JS.RL_hipX, JS.time(1), JS.RL_hipX(1), JS.time(1), JS.RL_hipX(1));
    title('Rear Left hipX');
    xlim([0, maxTime])
    ylim([minJS, maxJS])
    
    subplot(3,1,2);
    plot(JS.time(1), JS.RL_hipY(1), JS.time, JS.RL_hipY, JS.time(1), JS.RL_hipY(1));
    title('Rear Left hipY');
    xlim([0, maxTime])
    ylim([minJS, maxJS])
    
    subplot(3,1,3);
    plot(JS.time(1), JS.RL_knee(1), JS.time(1), JS.RL_knee(1), JS.time, JS.RL_knee);
    title('Rear Left knee');
    xlim([0, maxTime])
    ylim([minJS, maxJS])
    ylabel('Joint Efforts')
    xlabel('Time [s]')
    sgtitle('Rear Left Leg Joint Efforts');

    set(JSFig, 'Position',  [10, 30, 1100, 650])

    JSName = strcat(scriptLoc,'\stiletto_bag_files\',test,'\_',name,'-RLEfforts');
    saveas(JSFig, JSName, 'jpg')


%% Angle

    PosFig = 5;
    figure(PosFig)

    plot(Pos.time, Pos.RL_knee);
    title('Rear Left Knee angle');
    xlim([0, maxTime])
    ylabel('Joint Angle')
    xlabel('Time [s]')

    set(PosFig, 'Position',  [10, 30, 1100, 650])

    PosName = strcat(scriptLoc,'\stiletto_bag_files\',test,'\_',name,'-RLKneeAngle');
    saveas(PosFig, PosName, 'jpg')


end





