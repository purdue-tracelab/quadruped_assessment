function CoR = calcPlatCOR(plat)

    %{
        This code is used to calculate the ZY position of the treadmill's
        center of rotation. +Z-axis points towards aft of treadmill,
        +Y-axis points upwards.
    %}
    
    time = plat.time;
    fprintf(strcat("Calculating CoR for: ", plat.test, "\n"))

    % Determines interval difference from waveform cycle period using FR Y 
    % point maxes. Period multiplied by 0.75 to make sure pitch angles 
    % arent the same when doing CoR calculations 
    int = findPitchInterval(plat);

    % Average the FL+FR ZY Coords and AL+AR ZY Coords
    F_z = (plat.FL.Z + plat.FR.Z)./2;
    F_y = (plat.FL.Y + plat.FR.Y)./2;
    A_z = (plat.AL.Z + plat.AR.Z)./2;
    A_y = (plat.AL.Y + plat.AR.Y)./2;
        
    % Preallocating
    Rz = zeros(size(time,1)-1, 1);
    Ry = Rz;

    maxFy = 0;
    minFy = 0;

    for i = 1:size(time,1)-int
        % Set Primary Front and Aft ZY Coords that change per frame
        F1z = F_z(i);
        F1y = F_y(i);
        A1z = A_z(i);
        A1y = A_y(i);

        % Set secondary Front and Aft ZY Coords that change per frame which
        % is set 0.75*wavePeriod ahead of Primary
        F2z = F_z(i + int);
        F2y = F_y(i + int);
        A2z = A_z(i + int);
        A2y = A_y(i + int);
        
        % Midpoint ZY Coords between initial and secondary points
        Fmz = (F1z + F2z)/2;
        Fmy = (F1y + F2y)/2;
        Amz = (A1z + A2z)/2;
        Amy = (A1y + A2y)/2;
        % endpoint line slope
        m_Fm = (F1y - F2y)/(F1z - F2z);
        m_Am = (A1y - A2y)/(A1z - A2z);

        % Bisector line y-intersect
        b_CF = Fmy + Fmz/m_Fm;
        b_CA = Amy + Amz/m_Am;
        
        % Calculate Center of Rotation for every frame
        Rz(i) = (b_CA - b_CF)/(1/m_Am - 1/m_Fm);
        Ry(i) = -Rz(i)/m_Am + b_CA;

        % Find frame with max and min Y values (for plotting)
        if F_y(i) > maxFy
            maxFy = F_y(i);
            maxFyFrameNum = i;
        end
        if F_y(i) < minFy
            minFy = F_y(i);
            minFyFrameNum = i;
        end
    end

    CoR.Z = mean(rmoutliers(Rz), 'omitnan');       % needs to be an average because its inaccurate
    CoR.Y = mean(rmoutliers(Ry), 'omitnan'); 

    % Average front and rear marker x-pos for CoR.X
    F_xtemp = (plat.FL.X + plat.FR.X)/2;
    A_xtemp = (plat.AL.X + plat.AR.X)/2;
    CoR.X = mean((A_xtemp + F_xtemp)/2, 'omitnan');

    %% Fig Calcs
    % Set maxmin of angle ZY points of F and A
    Fmax_z = F_z(maxFyFrameNum);
    Fmax_y = F_y(maxFyFrameNum);
    Fmin_z = F_z(minFyFrameNum);
    Fmin_y = F_y(minFyFrameNum);
    Amax_z = A_z(maxFyFrameNum);    
    Amax_y = A_y(maxFyFrameNum);    % Amax_y should be less than Amin_y
    Amin_z = A_z(minFyFrameNum);
    Amin_y = A_y(minFyFrameNum);
    % Get points of max/min end midpoints perpendicular endpoints (for plotting)
    midFz = (Fmax_z + Fmin_z)/2;
    midFy = (Fmax_y + Fmin_y)/2;
    midAz = (Amax_z + Amin_z)/2;
    midAy = (Amax_y + Amin_y)/2;
    % Slope of interconect
    M_A = (Amax_y - Amin_y)/ ...
          (Amax_z - Amin_z);
    M_F = (Fmax_y - Fmin_y)/ ...
          (Fmax_z - Fmin_z);
    % Slope of Bisectors
    M_CA = -1/M_A;
    M_CF = -1/M_F;
    % Y-int of bisect
    b_A = midAy - midAz*M_CA;
    b_F = midFy - midFz*M_CF;
    % y coordinate of bisector under min F and A
    perpAy = Fmin_z*M_CA + b_A;     % Should be under F
    perpFy = Amax_z*M_CF + b_F;     % Should be under A


end



function int = findPitchInterval(plat)
    numPeak = 0;
    numVal = 0;
    above = 0;      % if above is +1 its above threshold

    minY = min(plat.FR.Y);
    maxY = max(plat.FR.Y);
    thresholdY = (maxY + minY) * 0.75;

    % determine peak locations
    for f = 2:size(plat.time, 1)-1
        if above ~= 1           % If not above threshhold
            if plat.FR.Y(f) > thresholdY
                numVal = numVal + 1;
                upFrame(numVal) = f;
                above = 1;
            end
        end
        if above == 1
            if plat.FR.Y(f) < thresholdY
                numVal = numVal + 1;
                upFrame(numVal) = f;
                above = 0;
                numPeak = numPeak + 1;
            end
        end
        if numPeak == 3
            break
        end
    end

    peakFrameNum(1) = (upFrame(4) + upFrame(3))/2;
    peakFrameNum(2) = (upFrame(6) + upFrame(5))/2; 
    period = peakFrameNum(2) - peakFrameNum(1);
    int = round(period * 0.75);


end





