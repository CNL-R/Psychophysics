%Generates pink noise and saves it as a .WAV file. 
filename = 'PinkNoise.WAV';
duration = 8 * 60; %in seconds
sampleRate = 48000;
N = duration * sampleRate;
y = pinknoise(N);
maximum = max(y);
minimum = min(y);
y = y/max([abs(minimum) abs(maximum)]);
audiowrite(filename, y, sampleRate);