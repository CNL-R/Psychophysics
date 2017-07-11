function [AnimationTextures, frameToTrialMatrix]= AnimateNoisyGabor(AnimationTextures, gaborMatrix, noiseMatrix, crossLength, crossWidth, frameToTrialMatrix, trial, coherence, duration, ifi, window)
%AnimateNoisyGabor2 takes a 2D gabor pixel matrix and animates it embedded in noise. Provide pixel value matrices for noise in noiseMatrix
%and gabor 2D Matrix as well as animationTextures matrix you are building into.

%   gaborMatrix - pixel value matrix of the gabor
%   noiseMatrix - 3D matrix containing several noise frames to choose randomly from for moving noise apperature of gabor
%   crossDimmensions - 1x2 matrix. [crossLength crossWidth]. Each value is the radius in pixels. i.e crossLength of 20 creates actual length of 40
if numel(duration) > 1
    duration1 = duration(1);
    duration2 = duration(2);
    duration = rand(1) * (duration2 - duration1) + duration(1);
end

[x y numNoises] = size(noiseMatrix);
refreshRate = 1/ifi; %calculating monitor refresh rate
for frame = 1:fix(refreshRate*duration/1000) %number of frames inside duration of presentation desired
    noised_gabor = EmbedInNoise2(gaborMatrix, coherence, 0, 0);
    stimulusMatrix = EmbedInEfficientApperature(noised_gabor, noiseMatrix(:, :, round(rand(1) * (numNoises- 1) + 1)));
    %Embedding Fixation Cross
    stimulusMatrix = repmat(stimulusMatrix, 1, 1, 3);
    crossCenter = size(stimulusMatrix, 1) / 2;
    stimulusMatrix(crossCenter - crossWidth:crossCenter+crossWidth,crossCenter - crossLength:crossCenter + crossLength,1) = 1;
    stimulusMatrix(crossCenter - crossWidth:crossCenter+crossWidth,crossCenter - crossLength:crossCenter + crossLength,2:3) = 0;
    stimulusMatrix(crossCenter - crossLength:crossCenter + crossLength, crossCenter-crossWidth:crossCenter+crossWidth, 1) = 1;
    stimulusMatrix(crossCenter - crossLength:crossCenter + crossLength, crossCenter-crossWidth:crossCenter+crossWidth, 2:3) = 0;
    stimulusTexture = Screen('MakeTexture', window, stimulusMatrix);
    AnimationTextures = [AnimationTextures stimulusTexture];
    frameToTrialMatrix = [frameToTrialMatrix trial];
    
end 





end

