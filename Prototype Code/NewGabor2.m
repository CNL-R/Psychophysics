gaborSize = 500;                                               % This is the diameter/length of any side of the gabor pixel matrix. 
sigma = 50;                                                    % Standard deviation of gaussian window in pixels
lambda = 20;                                                   % Wavelength of sine wave grating in pixels per cycle
orientation = 0;                                               % Orientation of gabor from 0 -> 2pi
phase = pi;                                                    % Phase of spatial sine wave from 0 -> 2pi
amplitude = 1;                                                 % Amplitude is a variable that changes peak values of the spatial sine wave. Change to 0.5
                                                               %  to make spatial sine wave take values from -.5 to .5   

gaborMatrix = CreateGabor3(gaborSize, sigma, lambda, orientation, phase, amplitude);

[x y numNoises] = size(noiseMatrix);
refreshRate = 1/ifi; %calculating monitor refresh rate
previous = 0;

[randindx, previous] = RNRInt(1, numNoises, previous);
    noise = noiseMatrix(:,:,randindx);
    [randindx, previous] = RNRInt(1, numNoises, previous); %
    noise2 = noiseMatrix(:,:,randindx);                    %
    noise3 = (noise + noise2)/2;
    
    stimulusMatrix = ((coherence*gaborMatrix) + noise);
    %stimulusMatrix(isnan(stimulusMatrix)) = noise3(isnan(stimulusMatrix));
    stimulusMatrix(isnan(stimulusMatrix)) = noise(isnan(stimulusMatrix));
    stimulusMatrix = stimulusMatrix./round(max([max(max(stimulusMatrix)) abs(min(min(stimulusMatrix)))]));
    stimulusMatrix = stimulusMatrix + round(abs(min(min(stimulusMatrix))));
    stimulusMatrix = stimulusMatrix ./ max((stimulusMatrix));