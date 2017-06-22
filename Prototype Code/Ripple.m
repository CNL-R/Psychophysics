SampleRate = 48000;
Duration = .060; %in seconds
Frequency1 = 1000;
Frequency2 = 30;

t = 0:1/SampleRate:Duration;
y1 = sin(2*pi*Frequency1*t);
y2 = sin(2*pi*Frequency2*t);

y1(2, :) = y1(1, :);
y2(2, :) = y1(1, :);

y = y1 .* y2;
% Initialize Sounddriver
InitializePsychSound(1);

% Number of channels and sample rate
nrchannels = 2;
sampleFreq = 48000;

%Volume %
volume = 0.5;

%Open audio port
pahandle = PsychPortAudio('Open', [], 1, [], 44100, 2, [], 0.015);
PsychPortAudio('FillBuffer', pahandle, y);
PsychPortAudio('Start', pahandle, 1, 0, 1);
PsychPortAudio('Stop', pahandle, 1, 1);
PsychPortAudio('Close', pahandle);