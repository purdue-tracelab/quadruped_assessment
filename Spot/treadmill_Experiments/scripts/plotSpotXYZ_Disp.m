function spotDisp = plotSpotXYZ_Disp(spotPos, PlatPos, testTitle, testName)

    % Path to saved plots folder:
    filePath = "../pictures/disp_over_time/";
    
    time = spotPos.time;
%     minX = minMax.minX;
%     maxX = minMax.maxX;
%     minY = minMax.minY;
%     maxY = minMax.maxY;
%     minZ = minMax.minZ;
%     maxZ = minMax.maxZ;
    
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

%     figure
%     plot(time, PlatPos.FR.X, time, PlatPos.FR.Y, time, PlatPos.FR.Z)
%     figure
%     plot(time, PlatPos.AR.X, time, PlatPos.AR.Y, time, PlatPos.AR.Z)
%     figure
%     plot(time, PlatPos.FL.X, time, PlatPos.FL.Y, time, PlatPos.FL.Z)
%     figure
%     plot(time, PlatPos.AL.X, time, PlatPos.AL.Y, time, PlatPos.AL.Z)
%     figure
%     plot(time, PlatPos.Po.X, time, PlatPos.Po.Y, time, PlatPos.Po.Z)
%     legend

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

%     figure
%     plot(PlatPos.FR.X, PlatPos.FR.Y, PlatPos.FL.X, PlatPos.FL.Y, PlatPos.AR.X, PlatPos.AR.Y, PlatPos.AL.X, PlatPos.AL.Y)

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

    % Indiv X,Y,Z disps
%     figure
%     subplot (3, 1, 1)
%     plot(time, V60Pos.C.X)
%     title('X wrt Treadmill frame')
%     ylabel('Displacement [mm]')
%     xlabel('Time [s]')
%     ylim([minX, maxX])
% 
%     subplot (3, 1, 2)
%     plot(time, V60Pos.C.Y)
%     title('Y wrt Treadmill frame')
%     ylabel('Displacement [mm]')
%     xlabel('Time [s]')
%     ylim([minY, maxY])
% 
%     subplot (3, 1, 3)
%     plot(time, V60Pos.C.Z)
%     title('Z wrt Treadmill frame')
%     ylabel('Displacement [mm]')
%     xlabel('Time [s]')
%     ylim([minZ, maxZ])
%     
%     titlePlot = strcat("Vision60 Test: ", testTitle);
%     sgtitle(titlePlot)

%     saveName = strcat(filePath, testName, '_v60DispWRTTreadmill');
%     saveas(j, saveName, 'jpg')

end


