function spotDisp = plotSpotXYZ_Disp(spotPos, PlatPos, testTitle, testName)

    % Path to saved plots folder:
    filePath = "../pictures/disp_over_time/";
    
    time = spotPos.time;
    
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
        spotDisp.X(i) = spotPos.C.X(i) - spotPos.C.X(1);
        spotDisp.Y(i) = spotPos.C.Y(i) - spotPos.C.Y(1);

        spotDisp.Euc(i) = sqrt(spotDisp.X(i)^2 + spotDisp.Y(i)^2);
    end
    spotDisp.std.E = std(spotDisp.Euc);
    spotDisp.std.X = std(spotDisp.X);
    spotDisp.std.Y = std(spotDisp.Y);

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
    tiledlayout(1,1,'TileSpacing','Compact','Padding','Compact')
    plot(spotPos.C.X, spotPos.C.Y)
    hold on
    plot(spotPos.Arm.X, spotPos.Arm.Y)
    plot(spotPos.C.X(1), spotPos.C.Y(1),'r.', spotPos.C.X(end), spotPos.C.Y(end),'rx')
    plot(avePo_X, avePo_Y, 'bs')
    plot([aveFR_X, aveFL_X, aveAL_X, aveAR_X, aveFR_X],[aveFR_Y, aveFL_Y, aveAL_Y, aveAR_Y, aveFR_Y],"k-o")
    plot(spotPos.Arm.X(1), spotPos.Arm.Y(1),'r.', spotPos.Arm.X(end), spotPos.Arm.Y(end),'rx')

    legend('Spot Pos', 'Wrist Pos', 'Start', 'End', ...
           'Fiducial', 'Treadmill Markers', '', '', 'Location','southoutside', 'Orientation','horizontal')

    title(strcat("Spot Position Over Time ",testTitle))
    subtitle(strcat("X StDev: ", string(spotDisp.std.X), "  |  Y StDev: ", string(spotDisp.std.Y)))

    xlabel('X Position [mm]')
    ylabel('Y Position [mm]')
    xlim([min(aveAL_X, aveFL_X), max(aveAR_X, aveFR_X)])
    ylim([min(aveAL_Y, aveAR_Y), avePo_Y])
    axis equal

    saveName = strcat(filePath, testName, '_spotDisp');
    saveas(j, saveName, 'jpg')
    close


end


