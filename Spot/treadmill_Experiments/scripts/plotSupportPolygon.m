function polygon = plotSupportPolygon(robot, CoM, robotName, savePath, testName)

    %% Calculating Polygon Points
    % Fixing Z orientation (flipping over x-axis)
    CoM.Z = -CoM.Z;
    robot.FL.Z = -robot.FL.Z;
    robot.FR.Z = -robot.FR.Z;
    robot.AL.Z = -robot.AL.Z;
    robot.AR.Z = -robot.AR.Z;

    % Find polygon Center
    F.X = (robot.FL.X + robot.FR.X)/2;
    F.Z = (robot.FL.Z + robot.FR.Z)/2;
    A.X = (robot.AL.X + robot.AR.X)/2;
    A.Z = (robot.AL.Z + robot.AR.Z)/2;
    C.X = (F.X + A.X)/2;
    C.Z = (F.Z + A.Z)/2;

    % Calculate polygon Corners w/ center at (0,0)
    polygon.FL.X = robot.FL.X - C.X;
    polygon.FR.X = robot.FR.X - C.X;
    polygon.AL.X = robot.AL.X - C.X;
    polygon.AR.X = robot.AR.X - C.X;
    polygon.FL.Z = robot.FL.Z - C.Z;
    polygon.FR.Z = robot.FR.Z - C.Z;
    polygon.AL.Z = robot.AL.Z - C.Z;
    polygon.AR.Z = robot.AR.Z - C.Z;

    % Calculate CoM wrt polygon center
    polygon.CoM.X = CoM.X - C.X;
    polygon.CoM.Z = CoM.Z - C.Z;

    %% Calculating Min tangent CoM dist from polygon
    for f = 1:size(CoM.X, 1)
        % FL -> FR line
        m_FLFR = ((polygon.FL.Z(f) - polygon.FR.Z(f))/(polygon.FL.X(f) - polygon.FR.X(f)));
        b_FLFR = polygon.FL.Z(f) - polygon.FL.X(f) * m_FLFR;
        d_FLFR(f) = abs(m_FLFR*polygon.CoM.X(f) - polygon.CoM.Z(f) + b_FLFR)/...
                sqrt(m_FLFR^2 + (-1)^2);
    
        % FR -> AR line
        m_FRAR = ((polygon.FR.Z(f) - polygon.AR.Z(f))/(polygon.FR.X(f) - polygon.AR.X(f)));
        b_FRAR = polygon.FR.Z(f) - polygon.FR.X(f) * m_FRAR;
        d_FRAR(f) = abs(m_FRAR*polygon.CoM.X(f) - polygon.CoM.Z(f) + b_FRAR)/...
                sqrt(m_FRAR^2 + (-1)^2);
    
        % AL -> AR line
        m_ALAR = ((polygon.AL.Z(f) - polygon.AR.Z(f))/(polygon.AL.X(f) - polygon.AR.X(f)));
        b_ALAR = polygon.AL.Z(f) - polygon.AL.X(f) * m_ALAR;
        d_ALAR(f) = abs(m_ALAR*polygon.CoM.X(f) - polygon.CoM.Z(f) + b_ALAR)/...
                sqrt(m_ALAR^2 + (-1)^2);
    
        % FL -> AL line
        m_FLAL = ((polygon.FL.Z(f) - polygon.AL.Z(f))/(polygon.FL.X(f) - polygon.AL.X(f)));
        b_FLAL = polygon.FL.Z(f) - polygon.FL.X(f) * m_FLAL;
        d_FLAL(f) = abs(m_FLAL*polygon.CoM.X(f) - polygon.CoM.Z(f) + b_FLAL)/...
                sqrt(m_FLAL^2 + (-1)^2);
    
        % stdev & minim of Tangental dist
        tangDist = [d_FLFR(f), d_FRAR(f), d_ALAR(f), d_FLAL(f)];
        minDist(f) = min(tangDist);
    end
    absMinDist = min(minDist);
    aveMinDist = mean(minDist,"omitnan");

    polygon.minCoMDist = minDist;
    polygon.absMinDist = absMinDist;
    polygon.aveMinDist = aveMinDist;

    %% Calculating World X & Z range


    maxXPos_world = max(polygon.CoM.X);
    minXPos_world = min(polygon.CoM.X);
    maxZPos_world = max(polygon.CoM.Z);
    minZPos_world = min(polygon.CoM.Z);

    polygon.rangeX_world = maxXPos_world - minXPos_world;
    polygon.rangeZ_world = maxZPos_world - minZPos_world;

    polygon.stdevX_world = std(polygon.CoM.X);
    polygon.stdevZ_world = std(polygon.CoM.Z);

    %{
    maxZPos_RobotF = min(d_FLFR); % distance closest to front supp poly line
    minZPos_RobotF = max(d_FLFR); % distance Furthest from front supp poly line
    maxZPos_RobotA = max(d_ALAR); % distance Furthest from Aft supp poly line
    minZPos_RobotA = min(d_ALAR); % distance closest to Aft supp poly line

    maxXPos_RobotR = min(d_FRAR); % distance closest to right supp poly line
    minXPos_RobotR = max(d_FRAR); % distance Furthest from right supp poly line
    maxXPos_RobotL = max(d_FLAL); % distance Furthest from left supp poly line
    minXPos_RobotL = min(d_FLAL); % distance closest to left supp poly line

    varianceZ_RobotF = minZPos_RobotF - maxZPos_RobotF;
    varianceZ_RobotA = maxZPos_RobotA - minZPos_RobotA;

    varianceX_RobotR = minXPos_RobotR - maxXPos_RobotR;
    varianceX_RobotL = maxXPos_RobotL - minXPos_RobotL;

    polygon.varianceZ_RobotAve = (varianceZ_RobotF + varianceZ_RobotA)/2;
    polygon.varianceX_RobotAve = (varianceX_RobotR + varianceX_RobotL)/2;
    %}
    
    %% Plot
    screensize = get(0, 'ScreenSize');
%{
    fig = figure('Visible','off', WindowState="maximized", ...
          Position=[screensize(4)/3, 1, 3*screensize(4)/4, screensize(3)]);
%     fig = figure(WindowState="maximized", ...
%           Position=[screensize(4)/3, 1, 3*screensize(4)/4, screensize(3)]);  
    for f = 1:size(CoM.X, 1)
        plot([polygon.FL.X(f), polygon.FR.X(f), polygon.AR.X(f), polygon.AL.X(f), polygon.FL.X(f)],...
             [polygon.FL.Z(f), polygon.FR.Z(f), polygon.AR.Z(f), polygon.AL.Z(f), polygon.FL.Z(f)],...
             '-', 'Color', [0.0, 0.0, 0.0, 0.01], 'LineWidth', 1)
        hold on
%         plot(polygon.CoM.X, polygon.CoM.Z, 'r')
%         hold on
    end
    plot(polygon.CoM.X, polygon.CoM.Z, 'r',...
         polygon.CoM.X(1), polygon.CoM.Z(1), 'b.',...
         polygon.CoM.X(end), polygon.CoM.Z(end), 'bx')
%     plot(polygon.FL.X(1), polygon.FL.Z(1), 'cx')

    xlabel('Location (L->R) [mm]')
    ylabel('Location (A->F) [mm]')
    %legend('Support Polygon','CoM','Start','End', Location='west')
    testName = strrep(testName,"_","-");
    title(strcat(robotName," Approx CoM within Support Polygon: ", testName))
    subtitle(strcat("Abs Min Dist of CoM to Polygon: ", num2str(absMinDist, '%.2f'),...
             "   |   Ave Min Dist of CoM to Polygon: ", num2str(aveMinDist, '%.2f')))
    axis equal
    axis tight
    
    % "../pictures/SupportPolygon/"
    saveName = strcat(savePath,testName,"_supportPolygon");
    saveas(fig, saveName, 'jpg')
    %}
%   fprintf('Reminder: Support Polygon plotting lines are commented out to save time \n')

%% Plot Support Polygon wrt Robot
    % Calculate
    FX = (polygon.FL.X + polygon.FR.X)/2;
    FZ = (polygon.FL.Z + polygon.FR.Z)/2;
    AX = (polygon.AL.X + polygon.AR.X)/2;
    AZ = (polygon.AL.Z + polygon.AR.Z)/2;

    dxf = FX - polygon.CoM.X;
    dzf = FZ - polygon.CoM.Z;
    dxa = polygon.CoM.X - AX;
    dza = polygon.CoM.Z - AZ;

    for f = 1:length(polygon.CoM.X)
        angF(f) = atan2(dzf(f),dxf(f));
        angA(f) = atan2(dza(f),dxa(f));
    
        angle(f) = (angF(f) + angA(f))/2 - pi/2;

        roboXForm = [cos(angle(f)),  sin(angle(f)), 0;...
                       -sin(angle(f)),  cos(angle(f)), 0;...
                                    0,              0, 1];
    
        fl = roboXForm *[polygon.FL.X(f);...
                         polygon.FL.Z(f);...
                         1];
        polyRobo.FL.X(f) = fl(1);
        polyRobo.FL.Z(f) = fl(2);
    
        fr = roboXForm *[polygon.FR.X(f);...
                         polygon.FR.Z(f);...
                         1];
        polyRobo.FR.X(f) = fr(1);
        polyRobo.FR.Z(f) = fr(2);
    
        al = roboXForm *[polygon.AL.X(f);...
                         polygon.AL.Z(f);...
                         1];
        polyRobo.AL.X(f) = al(1);
        polyRobo.AL.Z(f) = al(2);
    
        ar = roboXForm *[polygon.AR.X(f);...
                         polygon.AR.Z(f);...
                         1];
        polyRobo.AR.X(f) = ar(1);
        polyRobo.AR.Z(f) = ar(2);

        comR = roboXForm * [polygon.CoM.X(f);...
                             polygon.CoM.Z(f);...
                             1];
        polyRobo.CoM.X(f) = comR(1);
        polyRobo.CoM.Z(f) = comR(2);
    end

    %% Calculating X & Z range wrt robot
    maxXPos_robot = max(polyRobo.CoM.X);
    minXPos_robot = min(polyRobo.CoM.X);
    maxZPos_robot = max(polyRobo.CoM.Z);
    minZPos_robot = min(polyRobo.CoM.Z);

    polygon.rangeX_Robot = maxXPos_robot - minXPos_robot;
    polygon.rangeZ_Robot = maxZPos_robot - minZPos_robot;

    polygon.stdevX_Robot = std(polyRobo.CoM.X);
    polygon.stdevZ_Robot = std(polyRobo.CoM.Z);


    %% Plot Polygons
    %{%
%     fig = figure('Visible','off', WindowState="maximized", ...
%           Position=[screensize(4)/3, 1, 3*screensize(4)/4, screensize(3)]);
     fig = figure;
    tiledlayout(1,2,'TileSpacing','tight','Padding','tight')

    nexttile
    for f = 1:size(CoM.X, 1)
        plot([polyRobo.FL.X(f), polyRobo.FR.X(f), polyRobo.AR.X(f), polyRobo.AL.X(f), polyRobo.FL.X(f)],...
             [polyRobo.FL.Z(f), polyRobo.FR.Z(f), polyRobo.AR.Z(f), polyRobo.AL.Z(f), polyRobo.FL.Z(f)],...
             '-', 'Color', [0.0, 0.0, 0.0, 0.1], 'LineWidth', 1)
        hold on
    end
    plot(polyRobo.CoM.X, polyRobo.CoM.Z, 'r',...
         polyRobo.CoM.X(1), polyRobo.CoM.Z(1), 'b.',...
         polyRobo.CoM.X(end), polyRobo.CoM.Z(end), 'bx')
    xlabel('Location (L->R) [mm]')
    ylabel('Location (A->F) [mm]')
    title("WRT Robot")
    axis equal
    axis tight
    

    nexttile
    for f = 1:size(CoM.X, 1)
        plot([polygon.FL.X(f), polygon.FR.X(f), polygon.AR.X(f), polygon.AL.X(f), polygon.FL.X(f)],...
             [polygon.FL.Z(f), polygon.FR.Z(f), polygon.AR.Z(f), polygon.AL.Z(f), polygon.FL.Z(f)],...
             '-', 'Color', [0.0, 0.0, 0.0, 0.01], 'LineWidth', 1)
        hold on
    end
    plot(polygon.CoM.X, polygon.CoM.Z, 'r',...
         polygon.CoM.X(1), polygon.CoM.Z(1), 'b.',...
         polygon.CoM.X(end), polygon.CoM.Z(end), 'bx')
    xlabel('Location (L->R) [mm]')
    ylabel('Location (A->F) [mm]')
    title("WRT World")
%     axis equal
    axis tight
    

    testName = strrep(testName,"_","-");
    sgtitleName = strcat('{\bf\fontsize{10}',robotName," Approx CoM within Support Polygon wrt Robot: ", testName,"}");
    subName = strcat('{\fontsize{10}',"Abs Min Dist of CoM to Polygon: ", num2str(absMinDist, '%.2f'),...
              "   |   Ave Min Dist of CoM to Polygon: ", num2str(aveMinDist, '%.2f'),"}");
%     sgtitle({['{\bf\fontsize{14}' sgtitleName '}'],subName});
    sgtitle({sgtitleName,subName})
%     sgtitle(strcat(robotName," Approx CoM within Support Polygon wrt Robot: ", testName))
%     subtitle(strcat("Abs Min Dist of CoM to Polygon: ", num2str(absMinDist, '%.2f'),...
%              "   |   Ave Min Dist of CoM to Polygon: ", num2str(aveMinDist, '%.2f')))
    saveName = strcat(savePath,testName,"_supportPolygon");
    %saveas(fig, saveName, 'jpg')
    
    close all
%}

end



