function AnimationTextures = AnimateTextureMatrix(AnimationTextures, textureMatrix, duration, ifi)
%AnimateVisualNoise takes some textureMatrix and concatenates it onto AnimationTextures for a specified duration
%   gaborMatrix - pixel value matrix of the gabor
%   noiseMatrices - 3D matrix containing several noise frames to choose randomly from for moving noise apperature of gabor
%   
if numel(duration) > 1
    duration1 = duration(1);
    duration2 = duration(2);
    duration = rand(1) * (duration2 - duration1) + duration(1);
end

refreshRate = 1/ifi; %calculating monitor refresh rate
for frame = 1:round(refreshRate*duration/1000) %number of frames inside duration of presentation desired
    AnimationTextures = [AnimationTextures textureMatrix(frame)];
end 

end

