function [AnimationTextures, RseponseWindow] = AnimateVisualNoise2(AnimationTextures, noiseTextures, duration, ifi, getResp)
% AnimateVisualNoise takes noise textures and concatenates them onto an existing AnimationTexture (1D matrix containing textures). Duration can be a single value or bielement array containing desired
% random presentation interval. Also outputs the duration in case the length of this duration is desired. 

if numel(duration) > 1
    duration1 = duration(1);
    duration2 = duration(2);
    duration = rand(1) * (duration2 - duration1) + duration(1);
end

[bleh numTextures] = size(noiseTextures);
refreshRate = 1/ifi; %calculating monitor refresh rate
for frame = 1:round(refreshRate*duration/1000) %number of frames inside duration of presentation desired
    AnimationTextures = [AnimationTextures noiseTextures(round(rand(1) * (numTextures - 1) + 1))];
end

ResponseWindow = AnimationTextures;
if getResp == 1
    ResponseWindow(:) = 1;
else
    ResponseWindow(:) = 0;
end

end

