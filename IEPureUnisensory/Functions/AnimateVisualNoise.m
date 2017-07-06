function [AnimationTextures, frameToTrialMatrix] = AnimateVisualNoise(AnimationTextures, noiseTextures, frameToTrialMatrix, trial, duration, ifi)
% AnimateVisualNoise takes noise textures and concatenates them onto an existing AnimationTexture (1D matrix containing textures). Duration can be a single value or bielement array containing desired
% random presentation interval. Also outputs the duration in case the length of this duration is desired. 
%Version 2 - builds frameToTrialMatrix, a matrix containing the same
%amount of frames as AnimationTextures, but with a 1 or 0 telling the code
%whether or not to collect a response during this frame. 

if numel(duration) > 1
    duration1 = duration(1);
    duration2 = duration(2);
    duration = rand(1) * (duration2 - duration1) + duration(1);
end

[bleh numTextures] = size(noiseTextures);
refreshRate = 1/ifi; %calculating monitor refresh rate
previous = 0;
for frame = 1:fix(refreshRate*duration/1000) %number of frames inside duration of presentation desired
    [randindx, previous] = RNRInt(1, numTextures, previous);
    AnimationTextures = [AnimationTextures noiseTextures(randindx)];
    frameToTrialMatrix = [frameToTrialMatrix trial];
end


end

