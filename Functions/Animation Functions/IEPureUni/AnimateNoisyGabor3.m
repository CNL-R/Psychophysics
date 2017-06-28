function [AnimationTextures, responseWindowMatrix, stimulusMatrix]= AnimateNoisyGabor3(AnimationTextures, gaborMatrix, noiseMatrix, responseWindowMatrix, coherence, duration, ifi, window, getResp)
%AnimateNoisyGabor2 takes a 2D gabor pixel matrix and animates it embedded in noise, however, using a different method than in 
%v1 and v2. This function does not normalize the gabor matrix and applies noise by numerically summing gabor matrix with
%noise matrix ranging in values from -1 to 1. 

%Version3  - Dealing with summation method of embedding gabor in noise

%   gaborMatrix - pixel value matrix of the gabor
%   noiseMatrix - 3D matrix containing several noise frames to choose randomly from for moving noise apperature of gabor
%   
if numel(duration) > 1
    duration1 = duration(1);
    duration2 = duration(2);
    duration = rand(1) * (duration2 - duration1) + duration(1);
end

[x y numNoises] = size(noiseMatrix);
refreshRate = 1/ifi; %calculating monitor refresh rate
previous = 0;
for frame = 1:round(refreshRate*duration/1000) %number of frames inside duration of presentation desired
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
    stimulusTexture = Screen('MakeTexture', window, stimulusMatrix);
    AnimationTextures = [AnimationTextures stimulusTexture];
    
end 

responseWindow = AnimationTextures;
if getResp == 1
    responseWindow(:) = 1;
else
    responseWindow(:) = 0;
end

responseWindowMatrix = [responseWindowMatrix responseWindow];

end

