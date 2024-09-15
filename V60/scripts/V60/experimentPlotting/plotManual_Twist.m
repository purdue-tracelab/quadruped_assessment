function plotManual_Twist(titleName, expName, angZ, linX, linY, time)
% Plots V60 manual_twist ros2 topic
% Only non-zero data should be angular z aand linear x and y
    
    
    f = figure('Visible','off');
    tiledlayout('flow', 'TileSpacing','Compact','Padding','Compact')

    plot(time, linX, time, linY, time, angZ)
    xlabel('Time [s]')
    ylabel('Jostick Push from Center')
    ylim([-0.5,0.5])
    title(titleName)
    legend('Linear X', 'Linear Y', 'Angular Z')
    
    set(gcf, 'Position',  [5, 50, 1120, 620])
    
    plotName = strcat('../../../pictures/2023_tests/ManualTwist-',expName);
    saveas(f,plotName,'jpg')

end

