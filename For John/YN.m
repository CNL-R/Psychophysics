%This script generates moving noise
%   creates several frames of noise and plays by picking a random one 
%Screen('Preference', 'SkipSyncTests', 1) %REMOVE THIS LATER!!!!
%--------------------
% INITIAL SET-UP
%--------------------
% Clear the workspace and the screen
sca;
close all;
clearvars;

%BLOCK PARAMETERS
VCoherence = 1;
VFloor = 0;
VStep = .1;

ACoherence = 1;
AFloor = 0;
AStep = .1;

AVCoherence = 1;
AVFloor = 0;
AVStep = .1;

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
length = 500;
width = 500;
vnDuration = 1000; %duration pure noise in ms
vsDuration = 60; %duration stimulus in ms
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


sigma = 50;
lambda = 50;
A = 1;

gabor = CreateGabor2(gaborWidth, sigma, lambda, 'r', 'r', A);

blank = Screen('MakeTexture', window, 0);
%--------------------
% Visual Gabor Generation & Playback
%--------------------
while VCoherence >= VFloor 
VCoherence

AnimationTextures = [];

%Generating Noise
AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, vnDuration, ifi);

%Generating Noisy Gabor
AnimationTextures = AnimateNoisyGabor(AnimationTextures, gabor, noise, VCoherence, vsDuration, ifi, window);

%Generating Noise
AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, vnDuration, ifi);

%Playing Back Animation
vbl = PlayVisualAnimation(AnimationTextures, window, 0, ifi, 0, 0, 0, 0, rectCenter);

VCoherence = round(VCoherence - VStep, 5);
end

%% --------------------
% Auditory Generation & Playblack
%--------------------
% Auditory Parameters
anDuration = 1000; %duration auditory noise
asDuration = 100; %duration auditory pure tone stim in noise
frequency = 1000;


%Open audio port
pahandle = PsychPortAudio('Open', [], 1, 1, sampleFreq, nrchannels, [], [], [], []);

while ACoherence >= AFloor
    %Generating WAVS
    ACoherence
    CreateAuditoryNoise(anDuration, sampleFreq, 'Noise1.WAV');
    CreateAuditoryNoise(anDuration, sampleFreq, 'Noise2.WAV');
    CreateNoisyWAV(frequency, ACoherence, asDuration, sampleFreq, 'NoisyWAV.WAV');
    
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
    PsychPortAudio('Stop', pahandle, 1, 1);
    ACoherence = round(ACoherence - AStep, 5);
end 

%% --------------------
%Multisensory Playback
%--------------------
%AV Noise #1
while AVCoherence >= AVFloor
    AVCoherence
    %auditory pregeneration
    CreateAuditoryNoise(anDuration, sampleFreq, 'Noise1.WAV');
    CreateAuditoryNoise(anDuration, sampleFreq, 'Noise2.WAV');
    CreateNoisyWAV(frequency, AVCoherence, asDuration, sampleFreq, 'NoisyWAV.WAV');
    y1 = audioread('Noise1.WAV');
    y1(:, 2) = y1(:, 1);
    y2 = audioread('Noise2.WAV');
    y2(:, 2) = y2(:, 1);
    y3 = audioread('NoisyWAV.WAV');
    y3(:, 2) = y3(:, 1);
    
    y = [y1; y3; y2];
    y = y';
    
    AnimationTextures = [];
    
    %Generating Noise
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, vnDuration, ifi);
    
    %Generating Noisy Gabor
    AnimationTextures = AnimateNoisyGabor(AnimationTextures, gabor, noise, AVCoherence, vsDuration, ifi, window);
    
    %Generating Noise
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, vnDuration, ifi);
    
    %Play Back AV Animation
    vbl = PlayAVAnimation(AnimationTextures, y, pahandle, volume, window, 0, ifi, 0, 0, 0, 0, rectCenter);
    
    AVCoherence = round(AVCoherence - AVStep, 5);
end
PsychPortAudio('Close', pahandle);

KbStrokeWait;
sca;
Screen('CloseAll')
