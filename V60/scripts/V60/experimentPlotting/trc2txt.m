clc; clearvars;

filePath = '../run_Data/v60_data/All_TRC_Files/';
trcFiles = dir(strcat(filePath, '*.trc'));


for i = 1:size(trcFiles)
    trialName(i, 1) = extractBetween(trcFiles(i).name, '', '.trc');
    trcTrialPath = strcat(filePath, string(trialName), '.trc');
    txtTrialPath = strcat(filePath, string(trialName), '.txt');
    copyfile(trcTrialPath(i), txtTrialPath(i))

end



