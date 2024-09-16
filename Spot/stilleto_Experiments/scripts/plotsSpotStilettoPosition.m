clc; clearvars; close all;
cd(fileparts(matlab.desktop.editor.getActiveFilename)); % Changes folder to current file location

%% Cycle through vid data
filePath_flc = 'stiletto_vidData/front_left_cabinet/';
txtFiles_flc = dir(strcat(filePath_flc, '*.txt'));
filePath_lc =  'stiletto_vidData/left_ceiling/';
txtFiles_lc =  dir(strcat(filePath_lc, '*.txt'));

nTests_flc = size(txtFiles_flc,1);
nTests_lc  = size(txtFiles_lc,1);

% Cycle files
for k = 1:nTests_flc
    table_flc = readtable(strcat(filePath_flc,txtFiles_flc(k).name));
    if ~isempty(table_flc)
        data(k).time = table2array(table_flc(1:end, 1));
        data(k).X = table2array(table_flc(1:end, 2));
        data(k).Y = table2array(table_flc(1:end, 3));
        data(k).name = txtFiles_flc(k).name(13:end);
        data(k).cam = 'Front Left';
        if data(k).name(1) == '-'
            data(k).name(1) = '';
        end
    end
end
i = 0;
for k = nTests_flc+1:nTests_lc+nTests_flc
    table_lc  = readtable(strcat(filePath_lc, txtFiles_lc(k-nTests_flc).name));
    if ~isempty(table_lc)
        i = i + 1;
        data(k).time = table2array(table_lc(1:end, 1));
        data(k).X = table2array(table_lc(1:end, 2));
        data(k).Y = table2array(table_lc(1:end, 3));
        data(k).name = txtFiles_lc(i).name(13:end);
        data(k).cam = 'Left Ceiling';
        if data(k).name(1) == '-'
            data(k).name(1) = '';
        end
    end
end

%% Average XY data with timestamps that are the same
for n = 1:size(data,2)      % Cycle experiments
% for n = 14
    tempTime = [];     % Make a temporary data set to replace data with
    tempX    = [];
    tempY    = [];
    tt = 1;             % t value for temp data
    t1 = 1;
    count = 0;

    while t1 < length(data(n).time)
        totX = data(n).X(t1);                   % init a total value for each timestamp to average
        totY = data(n).Y(t1); 
        i = 1;
        for t2 = (t1+1):length(data(n).time)    % Cycle every timestamp afterwards to compare to
            if data(n).time(t1) == data(n).time(t2)   % If the times are the same:
                totX = totX + data(n).X(t2);
                totY = totY + data(n).Y(t2);
                i = i + 1;
                count = 1 + count;          % Counting number of same time values per each experiment
            else
                break       % Break if timestamps differ
            end
        end
        tempTime(tt) = data(n).time(tt);
        tempX(tt) = totX/i;
        tempY(tt) = totY/i;
        t1 = t1 + i;    % Skip ahead past same timestamp values
        tt = tt + 1;
    end
    data(n).time = tempTime';
    data(n).X = tempX';
    data(n).Y = tempY';
    fprintf(strcat("Number of alike timevalues: ", num2str(count), "  (Exp ", num2str(n), ")\n"))
end
        

%% Find XY minmax
maxX = -10000;
minX =  10000;
maxY = -10000;
minY =  10000;
for k = 1:size(data,2)
    data(k).max.X = max(data(k).X);
    if max(data(k).X) > maxX
        maxX = max(data(k).X);
    end

    data(k).max.Y = max(data(k).Y);
    if max(data(k).Y) > maxY
        maxY = max(data(k).Y);
    end

    data(k).min.X = min(data(k).X);
    if min(data(k).X) < minX
        minX = min(data(k).X);
    end

    data(k).min.Y = min(data(k).Y);
    if min(data(k).Y) < minY
        minY = min(data(k).Y);
    end
end



for n = 1:size(data,2)
% for n = 13
    screensize = get(0, 'ScreenSize');
fig1 = figure(WindowState="maximized");
    tiledlayout(6,10,'TileSpacing','Compact','Padding','Compact')


    nexttile([3,6])
    plot(data(n).time,data(n).X)
    data(n).stdev.X = std(data(n).X);
    data(n).ave.X   = mean(data(n).X);
    yline(data(n).ave.X,'r--',"\fontsize{5}Ave")
    title(strcat("\fontsize{8}Average: ", num2str(data(n).ave.X),...
                          "  |  stdev: ", num2str(data(n).stdev.X)))
    xlabel('Time [s]')
    ylabel('X-Location [mm]')
    ylim([minX,maxX])


    nexttile([6,4])
    plot(data(n).X, data(n).Y, '-', 'Color', [0.0, 0.0, 0.0, 0.1], 'LineWidth', 1)
    hold on
    plot([minX, minX, maxX, maxX, minX], [minY, maxY, maxY, minY, minY], 'k-.')
    xlim([minX,maxX])
    ylim([minY,maxY])
    xlabel('X-Location [mm]')
    ylabel('Y-Location [mm]')
%     axis equal


    nexttile([3,6])
    plot(data(n).time,data(n).Y)
    data(n).stdev.Y = std(data(n).Y);
    data(n).ave.Y   = mean(data(n).Y);
    yline(data(n).ave.Y,'r--',"\fontsize{5}Ave")
    title(strcat("\fontsize{8}Average: ", num2str(data(n).ave.Y),...
                          "  |  stdev: ", num2str(data(n).stdev.Y)))
    xlabel('Time [s]')
    ylabel('Y-Location [mm]')
    ylim([minY,maxY])


   
    sgtitle(strcat("Test: ", strrep(strrep(data(n).name, '.txt', ''), 'Stable', '*'),...
                   "  |  Camera: ", data(n).cam))
    data(n).testName = strrep(strrep(strcat(data(n).name,data(n).cam), '.txt', '-'), ' ','_');
    try
        saveName = strcat("../pictures/stilSpot_Position-NEW/",strrep(data(n).testName,'_-_Trim',''));
        saveas(fig1, saveName, 'jpg')
    catch
        fprintf(strcat("No valid data for test ", num2str(n), "\n"))
    end

    close all
end


%% Rearange Data
for n = 1:length(data)
    data(n).testName = strrep(data(n).testName, 'Stable', '-S');
    data(n).testName = strrep(data(n).testName, 'InP', 'inP');
    data(n).testName = strrep(data(n).testName, '_-_Trim', '');
end

names_flc = [];
for n = 1:30
    names_flc = [names_flc, convertCharsToStrings(data(n).testName)];
end
names_flc = sort(names_flc);
i = 0;

for n = 1:length(names_flc)
    for d = 1:31
        try
            if ~isempty(data(d).time)
                if convertCharsToStrings(data(d).testName) == names_flc(n)
                    if ~contains(data(d).testName, 'Port')
                        i = i + 1;
                        data_flc(i) = data(d);
                    end
                end
            end
        catch
            % Do nothing
        end
    end
end



names_lc = [];
for n = 32:length(data)
    names_lc = [names_lc, convertCharsToStrings(data(n).testName)];
end
names_lc = sort(names_lc);
i = 0;

for n = 1:length(names_lc)
    for d = 31:length(data)
        try
            if ~isempty(data(d).time)
                if convertCharsToStrings(data(d).testName) == names_lc(n)
                    if ~contains(data(d).testName, 'Port')
                        i = i + 1;
                        data_lc(i) = data(d);
                    end
                end
            end
        catch
            % Do nothing
        end
    end
end

fprintf("Rearranged Data \n")

%% Place data into sets
st = 0;
sr = 0;
wa = 0;
wp = 0;
for d = 1:length(data_flc)
    if contains(data_flc(d).testName, 'Standing')
        st = st + 1;
        standing_flc(st) =  data_flc(d);
    end
    if contains(data_flc(d).testName, 'Strafe')
        sr = sr + 1;
        strafe_flc(sr) =  data_flc(d);
    end
    if contains(data_flc(d).testName, 'Walkingin')
        wp = wp + 1;
        WinP_flc(wp) =  data_flc(d);
    end
    if contains(data_flc(d).testName, 'WalkingW') ||  contains(data_flc(d).testName, 'Walking-')
        wa = wa + 1;
        walking_flc(wa) =  data_flc(d);
    end
end
data_flc = [standing_flc, WinP_flc, walking_flc, strafe_flc];

st = 0;
sr = 0;
wa = 0;
wp = 0;
for d = 1:length(data_lc)
    if contains(data_lc(d).testName, 'Standing')
        st = st + 1;
        standing_lc(st) =  data_lc(d);
    end
    if contains(data_lc(d).testName, 'Strafe')
        sr = sr + 1;
        strafe_lc(sr) =  data_lc(d);
    end
    if contains(data_lc(d).testName, 'Walkingin')
        wp = wp + 1;
        WinP_lc(wp) =  data_lc(d);
    end
    if contains(data_lc(d).testName, 'WalkingW') ||  contains(data_lc(d).testName, 'Walking-')
        wa = wa + 1;
        walking_lc(wa) =  data_lc(d);
    end
end
data_lc = [standing_lc, WinP_lc, walking_lc, strafe_lc];

%% Calculate Error of Recordings
% take the euler difference in position between frames and average them

for e = 1:length(data_flc)
    numFrames = length(data_flc(e).time);
    err = 0;

    for f = 2:numFrames
        f1 = sqrt(data_flc(e).X(f-1)^2 + data_flc(e).Y(f-1)^2);
        f2 = sqrt(data_flc(e).X(f)^2   + data_flc(e).Y(f)^2);
        diff = abs(f2 - f1); 
        err = err + diff;
    end
    err_flc(e) = err/numFrames;

end
fprintf(strcat("Average FL Position difference (Error): ", num2str(mean(err_flc)), "\n"))


for e = 1:length(data_lc)
    numFrames = length(data_lc(e).time);
    err = 0;

    for f = 2:numFrames
        f1 = sqrt(data_lc(e).X(f-1)^2 + data_lc(e).Y(f-1)^2);
        f2 = sqrt(data_lc(e).X(f)^2   + data_lc(e).Y(f)^2);
        diff = abs(f2 - f1);
        err = err + diff;
    end
    err_lc(e) = err/numFrames;

end
fprintf(strcat("Average LC Position difference (Error): ", num2str(mean(err_lc)), "\n"))

%% X tick Names
for d = 1:length(data_flc)
    barTicks_flc(d) = convertCharsToStrings(data_flc(d).testName);
    barTicks_flc(d) = strrep(barTicks_flc(d), '-S-', '*-');
    barTicks_flc(d) = strrep(barTicks_flc(d), 'Standing', 'St');
    barTicks_flc(d) = strrep(barTicks_flc(d), 'WalkinginPlace', 'WiP');
    barTicks_flc(d) = strrep(barTicks_flc(d), 'Walking', 'Wa');
    barTicks_flc(d) = strrep(barTicks_flc(d), 'Strafe', 'Sr');
    barTicks_flc(d) = strrep(barTicks_flc(d), 'WArm', 'wA');
    barTicks_flc(d) = strrep(barTicks_flc(d), 'SCurves', 'SC');
    barTicks_flc(d) = strrep(barTicks_flc(d), 'SeaState', 'SS');
    barTicks_flc(d) = strrep(barTicks_flc(d), 'Pier', 'P');
    barTicks_flc(d) = strrep(barTicks_flc(d), 'Underway', 'U');
    barTicks_flc(d) = strrep(barTicks_flc(d), '-Front_Left', '');
end

for d = 1:length(data_lc)
    barTicks_lc(d) = convertCharsToStrings(data_lc(d).testName);
    barTicks_lc(d) = strrep(barTicks_lc(d), '-S-', '*-');
    barTicks_lc(d) = strrep(barTicks_lc(d), 'Standing', 'St');
    barTicks_lc(d) = strrep(barTicks_lc(d), 'WalkinginPlace', 'WiP');
    barTicks_lc(d) = strrep(barTicks_lc(d), 'Walking', 'Wa');
    barTicks_lc(d) = strrep(barTicks_lc(d), 'Strafe', 'Sr');
    barTicks_lc(d) = strrep(barTicks_lc(d), 'WArm', 'wA');
    barTicks_lc(d) = strrep(barTicks_lc(d), 'SCurves', 'SC');
    barTicks_lc(d) = strrep(barTicks_lc(d), 'SeaState', 'SS');
    barTicks_lc(d) = strrep(barTicks_lc(d), 'Pier', 'P');
    barTicks_lc(d) = strrep(barTicks_lc(d), 'Underway', 'U');
    barTicks_lc(d) = strrep(barTicks_lc(d), '-Left_Ceiling', '');
end

%% "Bar" Plots of FLC
barNames = [];
barY_X = [];
barY_Y = [];
barX   = [];

for b = 1:size(data_flc,2)
    try
        barNames = [barNames, data_flc(b).testName];

        barY_X = [barY_X; data_flc(b).max.X, data_flc(b).ave.X, data_flc(b).min.X, data_flc(b).ave.X+data_flc(b).stdev.X, data_flc(b).ave.X-data_flc(b).stdev.X];
        barY_Y = [barY_Y; data_flc(b).max.Y, data_flc(b).ave.Y, data_flc(b).min.Y, data_flc(b).ave.Y+data_flc(b).stdev.Y, data_flc(b).ave.Y-data_flc(b).stdev.Y];
    
        barX = [barX; b, b, b, b, b];
    catch
        fprintf(strcat("No valid data for test ", num2str(b), "\n"))
    end
end

% fig2 = figure('Visible','off', WindowState="maximized");
fig2 = figure(WindowState="maximized");
tiledlayout(2,1,'TileSpacing','Compact','Padding','Compact') 

nexttile
for b = 1:length(barX)
    plot(barX(b,4:5), barY_X(b,4:5), 'c', 'LineWidth',3)
    hold on
    plot(...barX(b,4:5), barY_X(b,4:5), 'LineWidth',2, ... % stdev range 
         barX(b,1), barY_X(b,1)+60,'rv',...    % Max
         barX(b,2), barY_X(b,2),'r_',...    % Ave
         barX(b,3), barY_X(b,3)-60,'r^',...    % Min
         barX(b,1:3), barY_X(b,1:3), 'k',...
         barX(b,4:5), barY_X(b,4:5), 'b_')
    hold on
end
legend({'StDev','Max', 'Ave', 'Min'})
ylabel('X-Location [mm]')
xticks(barX(1:end, 1))
xticklabels(barTicks_flc)


nexttile
for b = 1:length(barX)
    plot(barX(b,4:5), barY_Y(b,4:5), 'c', 'LineWidth',3)
    hold on
    plot(barX(b,1), barY_Y(b,1)+60,'rv',...    % Max
         barX(b,2), barY_Y(b,2),'r_',...    % Ave
         barX(b,3), barY_Y(b,3)-60,'r^',...    % Min
         barX(b,1:3), barY_Y(b,1:3), 'k',...
         barX(b,4:5), barY_Y(b,4:5), 'b_')
    hold on
end
legend({'StDev', 'Max', 'Ave', 'Min'})
ylabel('Y-Location [mm]')
xticks(0)
xticklabels('')

sgtitle('Spot Stiletto XY Positions - Front Left Camera')

saveName = "../pictures/FLC_stil_positions";
saveas(fig2, saveName, 'jpg')


%% "Bar" Plots of LC
barNames = [];
barY_X = [];
barY_Y = [];
barX   = [];

for b = 1:size(data_lc,2)
    try
        barNames = [barNames, data_lc(b).testName];

        barY_X = [barY_X; data_lc(b).max.X, data_lc(b).ave.X, data_lc(b).min.X, data_lc(b).ave.X+data_lc(b).stdev.X, data_lc(b).ave.X-data_lc(b).stdev.X];
        barY_Y = [barY_Y; data_lc(b).max.Y, data_lc(b).ave.Y, data_lc(b).min.Y, data_lc(b).ave.Y+data_lc(b).stdev.Y, data_lc(b).ave.Y-data_lc(b).stdev.Y];
    
        barX = [barX; b, b, b, b, b];
    catch
        fprintf(strcat("No valid data for test ", num2str(b), "\n"))
    end
end

% fig3 = figure('Visible','off', WindowState="maximized");
fig3 = figure(WindowState="maximized");
tiledlayout(2,1,'TileSpacing','Compact','Padding','Compact') 

nexttile
for b = 1:length(barX)
    plot(barX(b,4:5), barY_X(b,4:5), 'c', 'LineWidth',3)
    hold on
    plot(barX(b,1), barY_X(b,1)+35,'rv',...    % Max
         barX(b,2), barY_X(b,2),'r_',...    % Ave
         barX(b,3), barY_X(b,3)-35,'r^',...    % Min
         barX(b,1:3), barY_X(b,1:3), 'k',...
         barX(b,4:5), barY_X(b,4:5), 'b_')
    hold on
end
legend({'StDev', 'Max', 'Ave', 'Min'})
ylabel('X-Location [mm]')
xticks(barX(1:end, 1))
xticklabels(barTicks_lc)


nexttile
for b = 1:length(barX)
    plot(barX(b,4:5), barY_Y(b,4:5), 'c', 'LineWidth',3)
    hold on
    plot(barX(b,1), barY_Y(b,1)+60,'rv',...    % Max
         barX(b,2), barY_Y(b,2),'r_',...    % Ave
         barX(b,3), barY_Y(b,3)-60,'r^',...    % Min
         barX(b,1:3), barY_Y(b,1:3), 'k',...
         barX(b,4:5), barY_Y(b,4:5), 'b_')
    hold on
end
legend({'StDev','Max', 'Ave', 'Min'})
ylabel('Y-Location [mm]')
xticks(0)
xticklabels('') 

sgtitle('Spot Stiletto XY Positions - Left Ceiling Camera')

saveName = "../pictures/LC_stil_positions";
saveas(fig3, saveName, 'jpg')

% close all




