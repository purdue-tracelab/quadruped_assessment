function V60Disp = plotV60XYZ_Disp(V60Pos, PlatPos, testTitle, testName)

    % Path to saved plots folder:
    filePath = "../../../pictures/2023_tests/disp_over_time/";
    
    time = V60Pos.time;

    
    % Average Platform Marker Positions wrt Treadmill Frame
    PlatPos.FR.aveX = mean(PlatPos.FR.X, 'omitnan');
    PlatPos.FR.aveY = mean(PlatPos.FR.Y, 'omitnan');
    PlatPos.FR.aveZ = mean(PlatPos.FR.Z, 'omitnan');
    
    PlatPos.FL.aveX = mean(PlatPos.FL.X, 'omitnan');
    PlatPos.FL.aveY = mean(PlatPos.FL.Y, 'omitnan');
    PlatPos.FL.aveZ = mean(PlatPos.FL.Z, 'omitnan');

    PlatPos.AL.aveX = mean(PlatPos.AL.X, 'omitnan');
    PlatPos.AL.aveY = mean(PlatPos.AL.Y, 'omitnan');
    PlatPos.AL.aveZ = mean(PlatPos.AL.Z, 'omitnan');

    PlatPos.AR.aveX = mean(PlatPos.AR.X, 'omitnan');
    PlatPos.AR.aveY = mean(PlatPos.AR.Y, 'omitnan');
    PlatPos.AR.aveZ = mean(PlatPos.AR.Z, 'omitnan');



    % V60 XYZ Displacemant from Starting Position
    for i = 1:size(time,1)
        V60Disp.X(i) = V60Pos.C.X(i) - V60Pos.C.X(1);
        V60Disp.Y(i) = V60Pos.C.Y(i) - V60Pos.C.Y(1);

        V60Disp.Euc(i) = sqrt(V60Disp.X(i)^2 + V60Disp.Y(i)^2);
    end
    V60Disp.std.E = std(V60Disp.Euc);
    V60Disp.std.X = std(V60Disp.X);
    V60Disp.std.Y = std(V60Disp.Y);

    % Plotting
    aveFR_X = mean(PlatPos.FR.X, 'omitnan');
    aveFR_Y = mean(PlatPos.FR.Y, 'omitnan');
    aveFL_X = mean(PlatPos.FL.X, 'omitnan');
    aveFL_Y = mean(PlatPos.FL.Y, 'omitnan');
    aveAR_X = mean(PlatPos.AR.X, 'omitnan');
    aveAR_Y = mean(PlatPos.AR.Y, 'omitnan');
    aveAL_X = mean(PlatPos.AL.X, 'omitnan');
    aveAL_Y = mean(PlatPos.AL.Y, 'omitnan');
    avePo_X = mean(PlatPos.Po.X, 'omitnan');
    avePo_Y = mean(PlatPos.Po.Y, 'omitnan');



    % XY pos over time
    j = figure('Visible','off');
    %figure
    tiledlayout(1,1,'TileSpacing','Compact','Padding','Compact')
    plot(V60Pos.C.X, V60Pos.C.Y)
    hold on
    plot(V60Pos.Arm.X, V60Pos.Arm.Y)
    plot(V60Pos.C.X(1), V60Pos.C.Y(1),'r.', V60Pos.C.X(end), V60Pos.C.Y(end),'rx')
    plot(avePo_X, avePo_Y, 'bs')
    plot([aveFR_X, aveFL_X, aveAL_X, aveAR_X, aveFR_X],[aveFR_Y, aveFL_Y, aveAL_Y, aveAR_Y, aveFR_Y],"k-o")
    plot(V60Pos.Arm.X(1), V60Pos.Arm.Y(1),'r.', V60Pos.Arm.X(end), V60Pos.Arm.Y(end),'rx')

    legend('V60 Pos', 'Wrist Pos', 'Start', 'End', ...
           'Fiducial', 'Treadmill Markers', '', '', 'Location','southoutside', 'Orientation','horizontal')

    title(strcat("V60 Position Over Time ",testTitle))
    subtitle(strcat("X StDev: ", string(V60Disp.std.X), "  |  Y StDev: ", string(V60Disp.std.Y)))
    
    xlabel('X Position [mm]')
    ylabel('Y Position [mm]')
    xlim([min(aveAL_X, aveFL_X), max(aveAR_X, aveFR_X)])
    ylim([min(aveAL_Y, aveAR_Y), avePo_Y+30])
    axis equal

    saveName = strcat(filePath, testName, '_v60Disp');
    saveas(j, saveName, 'jpg')



end


