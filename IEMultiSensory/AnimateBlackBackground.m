function [AnimationTextures, frameToTrialMatrix] = AnimateBlackBackground(AnimationTextures, blackTexture, frameToTrialMatrix, trial, duration, ifi)
%Code designed to test timing of AV stimuli. 

if numel(duration) > 1
    duration1 = duration(1);
    duration2 = duration(2);
    duration = rand(1) * (duration2 - duration1) + duration(1);
end

[bleh numTextures] = size(blackTexture);
refreshRate = round(1/ifi); %calculating monitor refresh rate. Assuming, you want it rounded to nearest integer
previous = 0;
for frame = 1:fix(refreshRate*duration/1000) %number of frames inside duration of presentation desired
    AnimationTextures = [AnimationTextures blackTexture];
    frameToTrialMatrix = [frameToTrialMatrix trial];
end


end

