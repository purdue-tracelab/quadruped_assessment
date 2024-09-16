function twist = parse_Manual_Twist(expTable, setName, moName, expName)
% Plots V60 manual_twist ros2 topic
% Only non-zero data should be angular z aand linear x and y

    %% Parsing
    titleName = strcat("Joystick Contol Push,  Trial: ", setName, " Active, ", moName, "-", expName);
    expName = strcat(setName, "_", moName, "-", expName);
    
    angZ = 0;
    linX = 0;
    linY = 0;
    time = 0;
    j = 0;
    try
        for i = 1:size(expTable.x__time, 1)
            if ~isnan(expTable.x_mcu_command_manual_twist_angular_z(i))
                j = j+1;
                angZ(j, 1) = expTable.x_mcu_command_manual_twist_angular_z(i);
                linX(j, 1) = expTable.x_mcu_command_manual_twist_linear_x(i);
                linY(j, 1) = expTable.x_mcu_command_manual_twist_linear_y(i);
                time(j, 1) = expTable.x__time(i);
            end
        end
    catch
        warning(strcat(setName, " ",moName, " ", expName, ": Twist error encountered."));
    end
    
    x = 0;
    y = 0;
    z = 0;
    linX_P = 0;
    linY_P = 0;
    angZ_P = 0;
    timeX = 0;
    timeY = 0;
    timeZ = 0;

    for i = 2:size(time, 1)-1
        if (abs(linX(i-1)) < abs(linX(i))) && (abs(linX(i)) > abs(linX(i+1)))
            x = x+1;
            linX_P(x) = linX(i);
            timeX(x) = time(i);
        end
        if (abs(linY(i-1)) < abs(linY(i))) && (abs(linY(i)) > abs(linY(i+1)))
            y = y+1;
            linY_P(y) = linY(i);
            timeY(y) = time(i);
        end
        if (abs(angZ(i-1)) < abs(angZ(i))) && (abs(angZ(i)) > abs(angZ(i+1)))
            z = z+1;
            angZ_P(z) = angZ(i);
            timeZ(z) = time(i);
        end
    end
    twist.time = time;
    twist.angZ = angZ;
    twist.linX = linX;
    twist.linY = linY;

    %% Eval?
    meanT.linX_mean = mean(linX);
    meanT.linX_P_mean = mean(linX_P);
    meanT.linY_mean = mean(linY);
    meanT.linY_P_mean = mean(linY_P);
    meanT.angZ_mean = mean(angZ);
    meanT.angZ_P_mean = mean(angZ_P);
    twist.meanT = meanT;
    
    peaks.linX = linX;
    peaks.timeX = timeX;
    peaks.linY = linY;
    peaks.timeY = timeY;
    peaks.angZ = angZ;
    peaks.timeZ = timeZ;
    twist.peaks = peaks;

    


end



