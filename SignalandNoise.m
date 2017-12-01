%% SignalandNoise: to analyze responses to repeated white noise stimuli
%
% *This program takes the power spectrum of a the average responses to a repeated fluctuating stimulus and the residual between each individual response and the average*
%
% Each row of the matrix is a response epoch to the same stimulus. 
%
% The program performs the following main operations:
%
% # Ask the user to enter in the sampling interval (per second)
% # Ask the user to enter in the number of points preceding the stimulus
% # Ask the user to load the matrix containing the responses in rows
%
% <<PowerSpectra.tif>>
%
% *Input:*
%
% * Mat file: mat file containing the data in row vectors
% * Reference points: What are the reference points?
%  
% *Output:*
%
% * "Spectra.mat" Column vectors of the following:
%   1) Frequencies (Hz)
%   2) Signal power 
%   3) Noise power
%   4) Noise standard deviation
%   5) Signal to noise ratio
%
% *Dependencies:*
%
% * PowerSpectrumFinder.m (power spectra that converts points to time)
%

CellInfo.SampleRate = input('Sample rate per second ')% 
CellInfo.PrePoints = input('Number of prepoints');

% load data in: matrix called data
[FileNamePoints, PathNamePoints] = uigetfile('*.mat');
load([PathNamePoints FileNamePoints]);

data_mean = mean(data); % how to make this generalizable?
data_mean = data_mean - mean(data_mean(1:CellInfo.PrePoints)); % subtract off baseline

figure
plot(data_mean)

[n, m] = size(FileNamePoints);

for count = 1:n
    datasubtract(count, :) = data(count, :) - mean(data(count, 1:CellInfo.PrePoints));
    residual(count, :) = data_mean - datasubtract(count, :);
    [Power_x(count, :), Power(count, :)] = PowerSpectrumFinder(residual(count, :), CellInfo.SampleRate); 
end

[Power_signal_x, Power_signal_y] = PowerSpectrumFinder(data_mean, CellInfo.SampleRate);

figure
loglog(Power_signal_x, Power_signal_y, 'o')

Power_noise_y = mean(Power);
Power_noise_sd = std(Power);

hold on
loglog(Power_x(1, :), Power_noise_y, 'ro')

SNR = Power_signal_y./Power_noise_y;
loglog(Power_x(1, :), SNR, 'co')

Spectra = cat(2, Power_signal_x', Power_signal_y', Power_noise_y', Power_noise_sd', SNR');


%%
save Spectra Spectra -ascii -tabs % how to direct this to a directory?

%% Changelog
%
% _*Version 1.0*             created on 2017-09-28 by Felice Dunn_