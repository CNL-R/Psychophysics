%This script generates moving noise
%   creates several frames of noise and plays by picking a random one 
Screen('Preference', 'SkipSyncTests', 1) %REMOVE THIS LATER!!!!
%--------------------
% INITIAL SET-UP
%--------------------
% Clear the workspace and the screen
sca;
close all;
clearvars;

% Setup PTB with some default values
PsychDefaultSetup(2);

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);

%Query the time duration
ifi = Screen('GetFlipInterval', window);

%Set the text font and size
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 40);

%Query the maximum priority level
topPriorityLevel = MaxPriority(window);

%Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

%random seed
rand('seed', sum(100 * clock));

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


%--------------------
% AUDITORY SET UP STUFF
%--------------------
% Initialize Sounddriver
InitializePsychSound(1);

% Number of channels and sample rate
nrchannels = 2;
sampleFreq = 48000;

%Volume %
volume = 0.5;

%Other Stuff
startCue = 0;
repetitions = 1;
waitForDeviceStart = 1;


%% --------------------
% Visual Noise Parameters & Generation
%--------------------
length = 700;
width = 700;
vnDuration = 1000; %duration pure noise in ms
vsDuration = 100; %duration stimulus in ms
waitframes = 1;

timeSecs = vsDuration/1000;
timeFrames = round(timeSecs ./ ifi);

%Centering texture in center of window
xPos = xCenter;
yPos = yCenter;
baseRect = [0 0 length width];
rectCenter = CenterRectOnPointd(baseRect, xPos, yPos);

%Generating Noise Textures
numTextures = 100;
noise = rand(width, length, numTextures);
for i = 1:numTextures
    textures(i) = Screen('MakeTexture', window, noise(:,:, i));
end 

%--------------------
% Visual Gabor Paremeters
%--------------------
gaborLength = 300;
gaborWidth = gaborLength;
coherence = 1;

sigma = 100;
lambda = 50;
A = 1;

gabor = CreateGabor(gaborWidth, sigma, lambda, 'r', 'r', A);

blank = Screen('MakeTexture', window, 0);
%--------------------
% Visual Gabor Generation & Playback
%--------------------
while coherence > 0
coherence = coherence - .1
%Generating Gabor w/ Animated Noise texture matrix
stimulusTextures = GenerateAnimatedNoiseGabor(gabor, noise, coherence, vsDuration, ifi, window);
% refreshRate = 1/ifi;
% for frame = 1:round(refreshRate*vsDuration/1000)
%     noised_gabor = EmbedInNoise(gabor, coherence, 0, 0);
%     stim = EmbedInEfficientApperature(noised_gabor, noise(:,:, round(rand(1) * (numTextures - 1) + 1)));
%     stimTexture(frame) = Screen('MakeTexture', window, stim);    
% end

% Playing Back Noise
vbl = PresentAnimatedNoise(textures, window, 0, ifi, vnDuration, 0, 0, 0, 0, 0, rectCenter);
% Screen('DrawTextures', window, textures(round(rand(1) * (numTextures - 1) + 1)), [], rectCenter, [], [], [], []);
% vbl = Screen('Flip', window);
% for frame = 1:timeFrames - 1
%     
%     Screen('DrawTextures', window, textures(round(rand(1) * (numTextures - 1) + 1)), [], rectCenter, [], [], [], []);
%     vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
%     
 %end

% Playing Back Gabors
vbl = PresentAnimatedNoiseGabor(stimulusTextures, window, vbl, ifi, vsDuration, 0, 0, 0, 0, 0, rectCenter);
% Screen('DrawTextures', window, stimulusTextures(1) ,[], rectCenter, [], [], [], []);
% vbl = Screen('Flip', window);
% for frame = 1:timeFrames - 1
%     Screen('DrawTextures', window, stimulusTextures(frame + 1), [], rectCenter, [], [], [], []);
%     vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
% end

% Playing Back Noise
vbl = PresentAnimatedNoise(textures, window, vbl, ifi, vnDuration, 0, 0, 0, 0, 0, rectCenter);
end

%% --------------------
% Auditory Generation & Playblack
%--------------------
% Auditory Parameters
anDuration = 1000; %duration auditory noise
asDuration = 100; %duration auditory pure tone stim in noise
frequency = 1000;
audCoherence = 1;

%Open audio port
pahandle = PsychPortAudio('Open', [], 1, 1, sampleFreq, nrchannels, [], [], [], []);

while audCoherence > 0
    %Generating WAVS
    audCoherence = audCoherence - .1
    CreateAuditoryNoise(anDuration, sampleFreq, 'Noise1.WAV');
    CreateAuditoryNoise(anDuration, sampleFreq, 'Noise2.WAV');
    CreateNoisyWAV(frequency, audCoherence, asDuration, sampleFreq, 'NoisyWAV.WAV');
    
    y1 = audioread('Noise1.WAV');
    y1(:, 2) = y1(:, 1);
    y2 = audioread('Noise2.WAV');
    y2(:, 2) = y2(:, 1);
    y3 = audioread('NoisyWAV.WAV');
    y3(:, 2) = y3(:, 1);
    
    y = [y1; y3; y2];
    y = y';
    
    PsychPortAudio('FillBuffer', pahandle, y);
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    pause(2.1);
    PsychPortAudio('Stop', pahandle, 1, 1);
end 

%% --------------------
%Multisensory Playback
%--------------------
%AV Noise #1
PresentAnimatedNoise(textures, y, pahandle, volume, window, vbl, ifi, vnDuration, 0, 0, 0, 0, 0, rectCenter);
PsychPortAudio('Close', pahandle);