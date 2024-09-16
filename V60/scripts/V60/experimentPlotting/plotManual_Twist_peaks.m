function plotManual_Twist_peaks(titleName, expName, timeX, linX_P, timeY, linY_P, timeZ, angZ_P)
% Plots V60 manual_twist ros2 topic
% Only non-zero data should be angular z aand linear x and y

    
    f = figure('Visible','off');
    tiledlayout('flow', 'TileSpacing','Compact','Padding','Compact')

    plot(timeX, linX_P, timeY, linY_P, timeZ, angZ_P)
    xlabel('Time [s]')
    ylabel('Jostick Push from Center')
    ylim([-0.5,0.5])
    title(titleName)
    legend('Linear X', 'Linear Y', 'Angular Z')

    set(gcf, 'Position',  [5, 50, 1120, 620])
    
    plotName = strcat('../../../pictures/2023_tests/ManualTwist-Peaks-',expName);
    saveas(f,plotName,'jpg')

end