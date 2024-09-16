clc; clearvars; close all;

cd(fileparts(matlab.desktop.editor.getActiveFilename)); % Changes folder to current file location
stilPath = 'stiletto_bag_files/';
addpath(genpath(stilPath))    % Adds all functions to PATH for ease of use

%% Load csv
readtable('stiletto_bag_files/walking/_2023-03-02-11-12-38-spot-status-feet.csv')



