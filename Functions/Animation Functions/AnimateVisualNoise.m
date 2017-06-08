function AnimationTextures = AnimateVisualNoise(AnimationTextures, noiseTextures, duration, ifi)
%GenerateAnimatedNoiseGabor creates a one dimensional array 'stimulusTextures' that contains the textures for each individual frame of an animation of the Gabor patch
%in animated noise
%   gaborMatrix - pixel value matrix of the gabor
%   noiseMatrices - 3D matrix containing several noise frames to choose randomly from for moving noise apperature of gabor
%   
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

end

