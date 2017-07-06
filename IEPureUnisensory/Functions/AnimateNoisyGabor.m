function [AnimationTextures, frameToTrialMatrix]= AnimateNoisyGabor(AnimationTextures, gaborMatrix, noiseMatrices, frameToTrialMatrix, trial, coherence, duration, ifi, window)
%AnimateNoisyGabor2 takes a 2D gabor pixel matrix and animates it embedded in noise. Provide pixel value matrices for noise in noiseMatrices
%and gabor 2D Matrix as well as animationTextures matrix you are building into.

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
for frame = 1:fix(refreshRate*duration/1000) %number of frames inside duration of presentation desired
    noised_gabor = EmbedInNoise2(gaborMatrix, coherence, 0, 0);
    stimulusMatrix = EmbedInEfficientApperature(noised_gabor, noiseMatrices(:, :, round(rand(1) * (numNoises- 1) + 1))); 
    stimulusTexture = Screen('MakeTexture', window, stimulusMatrix);
    AnimationTextures = [AnimationTextures stimulusTexture];
    frameToTrialMatrix = [frameToTrialMatrix trial];
    
end 





end

