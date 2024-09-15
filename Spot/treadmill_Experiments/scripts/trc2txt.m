clc; clearvars;

filePath = '../trc_files/spot_REDO TRC/';
trcFiles = dir(strcat(filePath, '*.trc'));
% trialName = char.empty(size(trcFiles, 1)-2, 0);

for i = 1:size(trcFiles)
    trialName(i, 1) = extractBetween(trcFiles(i).name, '', '.trc');
    trcTrialPath = strcat(filePath, string(trialName), '.trc');
    txtTrialPath = strcat(filePath, string(trialName), '.txt');
    copyfile(trcTrialPath(i), txtTrialPath(i))
% 
%     test = extractBetween(trcFiles(i).name, '', '-');
%     trialPath(i, 1) = strcat(filePath, string(test));
end



