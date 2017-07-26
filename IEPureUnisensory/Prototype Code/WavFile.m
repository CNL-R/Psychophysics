%CreateWAV( 1000, 1000, 44100, 'Hello_World.WAV');

[y, Fs] = audioread('NoisyWAV.WAV');
y(:, 2) = y(:, 1);
y = y';
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