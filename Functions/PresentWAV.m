function [] = PresentWAV(Filename, pahandle, repetitions, startCue, waitForDeviceStart)
%Presents a WAV. 

[y, Fs] = audioread('NoisyWAV.WAV');
y(:, 2) = y(:, 1);
y = y';

% Initialize Sounddriver
InitializePsychSound(1);

%Volume %
volume = 0.5;

%Open audio port
PsychPortAudio('FillBuffer', pahandle, y);
PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
PsychPortAudio('Stop', pahandle, 1, 1);


end

