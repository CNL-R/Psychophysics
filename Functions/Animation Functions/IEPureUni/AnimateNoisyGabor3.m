function [AnimationTextures, responseWindowMatrix, stimulusMatrix]= AnimateNoisyGabor3(AnimationTextures, gaborMatrix, noiseMatrices, responseWindowMatrix, coherence, duration, ifi, window, getResp)
%AnimateNoisyGabor2 takes a 2D gabor pixel matrix and animates it embedded in noise, however, using a different method than in 
%v1 and v2. This function does not normalize the gabor matrix and applies noise by numerically summing gabor matrix with
%noise matrix ranging in values from -1 to 1. 

%   gaborMatrix - pixel value matrix of the gabor
%   noiseMatrices - 3D matrix containing several noise frames to choose randomly from for moving noise apperature of gabor
%   
if numel(duration) > 1
    duration1 = duration(1);
    duration2 = duration(2);
    duration = rand(1) * (duration2 - duration1) + duration(1);
end

[x y numNoises] = size(noiseMatrices);
refreshRate = 1/ifi; %calculating monitor refresh rate
for frame = 1:round(refreshRate*duration/1000) %number of frames inside duration of presentation desired
    stimulusMatrix = ((coherence*gaborMatrix) + noiseMatrices(:,:,round(rand(1) * (numNoises- 1) + 1))+ 1)/ 2;
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

