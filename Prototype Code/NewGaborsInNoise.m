
%Generating Base Gabor
gaborSize = 500;                                               % This is the diameter/length of any side of the gabor pixel matrix. 
sigma = 50;                                                    % Standard deviation of gaussian window in pixels
lambda = 20;                                                   % Wavelength of sine wave grating in pixels per cycle
orientation = 0;                                               % Orientation of gabor from 0 -> 2pi
phase = pi;                                                    % Phase of spatial sine wave from 0 -> 2pi
amplitude = 1;                                                 % Amplitude is a variable that changes peak values of the spatial sine wave. Change to 0.5
                                                               %  to make spatial sine wave take values from -.5 to .5   

gabor = CreateGabor3(gaborSize, sigma, lambda, orientation, phase, amplitude); %CreateGabor2 takes all of these parameters and spits out a pixel matrix for a gabor
noise = rand(gaborSize, gaborSize);
for i = 1:gaborSize
    for j = 1:gaborSize
        if rand(1) < .5
            noise(i,j) = -1  * noise(i,j);
        end 
    end
end

% amplitudeGabor = .3;
% amplitudeNoise = 1;
% mash = ((amplitudeGabor*gabor + amplitudeNoise*noise) + 1)/2;

%Previously Worked
% amplitudeGabor = 1;
% amplitudeNoise = 1;
% mash = ((amplitudeGabor*gabor + amplitudeNoise*noise) + amplitudeNoise)/(amplitudeNoise*2);
% imshow(mash)

amplitudeGabor = .1;
amplitudeNoise = 1;
mash = ((amplitudeGabor*gabor + amplitudeNoise*noise));
randos = (-2 + rand(gaborSize)*4) + (-2 + rand(gaborSize)*4) / 2; 
mash(isnan(mash)) = randos(isnan(mash));
mash = mash + abs(min(min(mash)));
mash = mash / max(max(mash));
imshow(mash)
min(min(mash))
max(max(mash))
