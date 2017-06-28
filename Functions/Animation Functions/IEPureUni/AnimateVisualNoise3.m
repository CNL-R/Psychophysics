function [AnimationTextures, responseWindowMatrix] = AnimateVisualNoise3(AnimationTextures, noiseTextures, responseWindowMatrix, duration, ifi, getResp)
% AnimateVisualNoise takes noise textures and concatenates them onto an existing AnimationTexture (1D matrix containing textures). Duration can be a single value or bielement array containing desired
% random presentation interval. Also outputs the duration in case the length of this duration is desired. 
%Version 3 - Averages noise fields to get a closer to mean gray noise
%amount of frames as AnimationTextures, but with a 1 or 0 telling the code
%whether or not to collect a response during this frame. 

if numel(duration) > 1
    duration1 = duration(1);
    duration2 = duration(2);
    duration = rand(1) * (duration2 - duration1) + duration(1);
end

[bleh numTextures] = size(noiseTextures);
refreshRate = 1/ifi; %calculating monitor refresh rate
for frame = 1:round(refreshRate*duration/1000) %number of frames inside duration of presentation desired
    AnimationTextures = [AnimationTextures (noiseTextures(round(rand(1) * (numTextures - 1) + 1)) + noiseTextures(round(rand(1) * (numTextures - 1) + 1)))/2];
end

responseWindow = AnimationTextures;
if getResp == 1
    responseWindow(:) = 1;
else
    responseWindow(:) = 0;
end

responseWindowMatrix = [responseWindowMatrix responseWindow];
end

