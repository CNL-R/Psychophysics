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
vsDuration = 100; %duration stimulus in ms
waitframes = 1;

timeSecs = vsDuration/1000;
timeFrames = round(timeSecs ./ ifi);

%Making the fixation cross
crossLength = 50;
crossWidth = 3;
crossCenter = crossLength/2;

cross = zeros(crossLength);
cross(:,:) = 0.5;
cross(crossCenter-crossWidth:crossCenter+crossWidth, 1:crossLength) = 1;
cross( 1:crossLength, crossCenter-crossWidth:crossCenter+crossWidth) = 1;

crossTexture = Screen('MakeTexture', window, cross);

%Creating destination rects
baseRect = [0 0 length width];
baseRectCross = [0 0 crossLength crossLength];

xPos = xCenter;
yPos = yCenter;
rectCenter = CenterRectOnPointd(baseRectCross, xPos, yPos);

xPosL = xCenter - xCenter/2;
yPosL = yCenter;
rectLeft = CenterRectOnPointd(baseRect, xPosL, yPosL);

xPosR = xCenter + xCenter/2;
yPosR = yCenter;
rectRight = CenterRectOnPointd(baseRect, xPosR, yPosR);

stimDstRects = [rectLeft' rectRight'];
dstRects = [stimDstRects rectCenter'];

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

sigma = 75;
lambda = 50;
A = 1;

gabor = CreateGabor2(gaborWidth, sigma, lambda, 'r', 'r', A);

blank = Screen('MakeTexture', window, 0);


%--------------------
% Visual Gabor Generation & Playback
%--------------------
while VCoherence >= VFloor
VCoherence
shuffler = randperm(2);
dstRectsShuffled = stimDstRects(:,shuffler);
dstRectsShuffled = [dstRectsShuffled rectCenter'];
%Generating Gabor w/ Animated Noise texture matrix
stimulusTextures = GenerateAnimatedNoiseGabor(gabor, noise, VCoherence, vsDuration, ifi, window);
% refreshRate = 1/ifi;
% for frame = 1:round(refreshRate*vsDuration/1000)
%     noised_gabor = EmbedInNoise(gabor, VCoherence, 0, 0);
%     stim = EmbedInEfficientApperature(noised_gabor, noise(:,:, round(rand(1) * (numTextures - 1) + 1)));
%     stimTexture(frame) = Screen('MakeTexture', window, stim);    
% end

% Playing Back Noise
vbl = PresentSSAnimatedNoise(textures, crossTexture, window, 0, ifi, vnDuration, 0, 0, 0, 0, 0, dstRects);
% Screen('DrawTextures', dstRects, window, [textures(round(rand(1) * (numTextures - 1) + 1)) textures(round(rand(1) * (numTextures - 1) + 1))], [], dstRects, [0 0], [], [], []);
% vbl = Screen('Flip', window);
% for frame = 1:timeFrames - 1
%     
%     Screen('DrawTextures', window, [textures(round(rand(1) * (numTextures - 1) + 1)) textures(round(rand(1) * (numTextures - 1) + 1))], [], dstRects, [0 0], [], [], []);
%     vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
%     
%  end

% Playing Back Gabors
vbl = PresentSSAnimatedNoiseGabor(stimulusTextures, textures, crossTexture, window, vbl, ifi, vsDuration, 0, 0, 0, 0, 0, dstRectsShuffled);
% Screen('DrawTextures', window, [stimulusTextures(1) textures(round(rand(1) * (numTextures - 1) + 1))],[], dstRectsShuffled, [0 0], [], [], []);
% vbl = Screen('Flip', window);
% for frame = 1:timeFrames - 1
%     Screen('DrawTextures', window, [stimulusTextures(1) textures(round(rand(1) * (numTextures - 1) + 1))],[], dstRectsShuffled, [0 0], [], [], []);
%     vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
% end


% Playing Back Noise
vbl = PresentSSAnimatedNoise2(textures, crossTexture, window, vbl, ifi, vnDuration, 0, 0, 0, 0, dstRects);
% Screen('DrawTextures', window, [textures(round(rand(1)*numTextures - 1) + 1)) , textures(round(rand(1) * (numTextures - 1) + 1))], [], dstRects, [0 0], [], [], []);
% vbl = Screen('Flip', window);
% for frame = 1:timeFrames - 1
%     
%     Screen('DrawTextures', window, [textures(round(rand(1) * (numTextures - 1) + 1)) textures(round(rand(1) * (numTextures - 1) + 1))], [], dstRects, [0 0], [], [], []);
%     vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
%     
%  end
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
    ACoherence = round(ACoherence - AStep,  5);
end 

%% --------------------
%Multisensory Playback
%--------------------
%AV Noise #1
while AVCoherence >= AVFloor
    AVCoherence
    
    shuffler = randperm(2);
    dstRectsShuffled = stimDstRects(:,shuffler);
    dstRectsShuffled = [dstRectsShuffled rectCenter'];
    
    %auditory pregeneration
    CreateAuditoryNoise(anDuration, sampleFreq, 'Noise1.WAV');
    CreateAuditoryNoise(10000, sampleFreq, 'Noise2.WAV');
    CreateNoisyWAV(frequency, AVCoherence, asDuration, sampleFreq, 'NoisyWAV.WAV');
    y1 = audioread('Noise1.WAV');
    y1(:, 2) = y1(:, 1);
    y1 = y1';
    y2 = audioread('Noise2.WAV');
    y2(:, 2) = y2(:, 1);
    y2 = y2';
    y3 = audioread('NoisyWAV.WAV');
    y3(:, 2) = y3(:, 1);
    y3 = y3';
    
    %visual pregeneration
    stimulusTextures = GenerateAnimatedNoiseGabor(gabor, noise, AVCoherence, vsDuration, ifi, window);
    
    vbl = PresentSSAVNoise(textures, y1, crossTexture, pahandle, volume, window, 0, ifi, vnDuration, 0, 0, 0, 0, 0, dstRects);
    vbl = PresentSSAnimatedAVNoiseGabor(stimulusTextures, y3, textures, crossTexture, pahandle, volume, window, vbl, ifi, vsDuration, 0, 0, 0, 0, 0, dstRectsShuffled);
    vbl = PresentSSAVNoise2(textures, y2, crossTexture, pahandle, volume, window, 0, ifi, vnDuration, 0, 0, 0, 0, dstRects);
    
    AVCoherence = round(AVCoherence - AVStep, 5);
end
PsychPortAudio('Close', pahandle);

KbStrokeWait;
Screen('CloseAll')
sca;
