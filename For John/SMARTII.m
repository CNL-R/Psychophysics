%This script generates moving noise
%   creates several frames of noise and plays by picking a random one 
%Screen('Preference', 'SkipSyncTests', 1) %REMOVE THIS LATER!!!!
% Clear the workspace and the screen
sca;
close all;
clearvars;
%--------------------
% INITIAL SET-UP
%--------------------
%BLOCK PARAMETERS
VVCoherence = -1;
VVFloor = 0;
VVStep = .1;

AACoherence = -1;
AAFloor = 0;
AAStep = .1;

AVAVCoherence = -1;
AVAVFloor = 0;
AVAVStep = .1;

VACoherence = -1;
VAFloor = 0;
VAStep = .1;

AVCoherence = -1;
AVFloor = 0;
AVStep = .1;

A_AVCoherence = 1;
A_AVFloor = 0;
A_AVStep = .1;

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
refreshRate = 1/ifi;

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
% Timing
%--------------------
preCIDuration = 1000;
cueDuration = 500;
postCIDuration = [500 1500];
stimDuration = 100;
%% --------------------
% Visual Noise Parameters & Generation
%--------------------
length = 500;
width = 500;
waitframes = 1;

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
% Cue Production
%--------------------
visualCueDiameter = 50;
visualCue = zeros(visualCueDiameter);
cueRect = [0 0 length width];
cueRectCenter = CenterRectOnPointd(cueRect, xPos, yPos);

for frame = 1:round(refreshRate * cueDuration/1000)
    for y = 1:visualCueDiameter
        for x = 1:visualCueDiameter
            if (x-visualCueDiameter/2)^2 + (y-visualCueDiameter/2)^2 <= (visualCueDiameter/2)^2
                visualCue(y,x) = 1;
            else 
                visualCue(y,x) = rand(1);
            end
            
        end
    end
    visualCueMatrix = EmbedInEfficientApperature(visualCue, noise(:, :, round(rand(1) * (numTextures- 1) + 1))); 
    cueTextures(frame) = Screen('MakeTexture', window, visualCueMatrix);
end

cueFrequency = 500;
cueCoherence = .65;

%--------------------
% Blank Stimuli Production
%--------------------
numTextures = 100;
blank = zeros(width, length, numTextures);
blank(:, :, :) = 0.5;
for i = 1:numTextures
    blankTextures(i) = Screen('MakeTexture', window, blank(:,:, i));
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
% Pure Visual Block
%--------------------
while VVCoherence >= VVFloor

AnimationTextures = [];

%preCI
AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, preCIDuration, ifi);
%Cue
AnimationTextures = AnimateTextureMatrix(AnimationTextures, cueTextures, cueDuration, ifi);
%PostCI
AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, postCIDuration, ifi);
%Target Gabor
AnimationTextures = AnimateNoisyGabor(AnimationTextures, gabor, noise, VVCoherence, stimDuration, ifi, window);
%preCI response period
AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, preCIDuration, ifi);

%Playing Back Animation
vbl = PlayVisualAnimation(AnimationTextures, window, 0, ifi, 0, 0, 0, 0, rectCenter);

VVCoherence = round(VVCoherence - VVStep, 5);
end

%% --------------------
% Pure Auditory
%--------------------
% Auditory Parameters
frequency = 1000;


%Open audio port
pahandle = PsychPortAudio('Open', [], 1, 1, sampleFreq, nrchannels, [], [], [], []);

while AACoherence >= AAFloor
    %Generating WAVS
    AACoherence
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI1.WAV');
    CreateNoisyWAV(cueFrequency, cueCoherence, cueDuration, sampleFreq, 'Cue.WAV');
    CreateAuditoryNoise(postCIDuration, sampleFreq, 'PostCI.WAV');
    CreateNoisyWAV(frequency, AACoherence, stimDuration, sampleFreq, 'TargetTone.WAV');
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI2.WAV');    
    
    y1 = audioread('PreCI1.WAV');
    y1(:, 2) = y1(:, 1);
    y2 = audioread('Cue.WAV');
    y2(:, 2) = y2(:, 1);
    y3 = audioread('PostCI.WAV');
    y3(:, 2) = y3(:, 1);
    y4 = audioread('TargetTone.WAV');
    y4(:, 2) = y4(:, 1);
    y5 = audioread('PreCI2.WAV');
    y5(:, 2) = y5(:, 1);    
    
    y = [y1; y2; y3; y4; y5];
    y = y';
    
    PsychPortAudio('FillBuffer', pahandle, y);
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    PsychPortAudio('Stop', pahandle, 1, 1);
    AACoherence = round(AACoherence - AAStep, 5);
end 

%% --------------------
% Pure AV Block
%--------------------
%AV Noise #1
while AVAVCoherence >= AVAVFloor
    AVAVCoherence
    trialPostCIDuration = rand(1) * (postCIDuration(2) - postCIDuration(1)) + postCIDuration(1);
    
    %auditory pregeneration
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI1.WAV');
    CreateNoisyWAV(cueFrequency, cueCoherence, cueDuration, sampleFreq, 'Cue.WAV');
    CreateAuditoryNoise(trialPostCIDuration, sampleFreq, 'PostCI.WAV');
    CreateNoisyWAV(frequency, AVAVCoherence, stimDuration, sampleFreq, 'TargetTone.WAV');
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI2.WAV');  
    
    y1 = audioread('PreCI1.WAV');
    y1(:, 2) = y1(:, 1);
    y2 = audioread('Cue.WAV');
    y2(:, 2) = y2(:, 1);
    y3 = audioread('PostCI.WAV');
    y3(:, 2) = y3(:, 1);
    y4 = audioread('TargetTone.WAV');
    y4(:, 2) = y4(:, 1);
    y5 = audioread('PreCI2.WAV');
    y5(:, 2) = y5(:, 1);    
    
    y = [y1; y2; y3; y4; y5];
    y = y';
    
    
    AnimationTextures = [];
    
    %preCI
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, preCIDuration, ifi);
    %Cue
    AnimationTextures = AnimateTextureMatrix(AnimationTextures, cueTextures, cueDuration, ifi);
    %PostCI
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, trialPostCIDuration, ifi);
    %Target Gabor
    AnimationTextures = AnimateNoisyGabor(AnimationTextures, gabor, noise, AVAVCoherence, stimDuration, ifi, window);
    %preCI response period
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, preCIDuration, ifi);
    
    %Playing Back Animation
    vbl = PlayAVAnimation(AnimationTextures, y, pahandle, volume, window, 0, ifi, 0, 0, 0, 0, rectCenter);
    
    
    AVAVCoherence = round(AVAVCoherence - AVAVStep, 5);
end
%% --------------------
% Pure V --> A Block
%--------------------
%AV Noise #1
while VACoherence >= VAFloor
    VACoherence
    trialPostCIDuration = rand(1) * (postCIDuration(2) - postCIDuration(1)) + postCIDuration(1);
    
    %auditory pregeneration
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI1.WAV');
    CreateNoisyWAV(0, 0, cueDuration, sampleFreq, 'Cue.WAV');
    CreateAuditoryNoise(trialPostCIDuration, sampleFreq, 'PostCI.WAV');
    CreateNoisyWAV(frequency, VACoherence, stimDuration, sampleFreq, 'TargetTone.WAV');
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI2.WAV');  
    
    y1 = audioread('PreCI1.WAV');
    y1(:, 2) = y1(:, 1);
    y2 = audioread('Cue.WAV');
    y2(:, 2) = y2(:, 1);
    y3 = audioread('PostCI.WAV');
    y3(:, 2) = y3(:, 1);
    y4 = audioread('TargetTone.WAV');
    y4(:, 2) = y4(:, 1);
    y5 = audioread('PreCI2.WAV');
    y5(:, 2) = y5(:, 1);    
    
    y = [y1; y2; y3; y4; y5];
    y = y';
    
    
    AnimationTextures = [];
    
    %preCI
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, preCIDuration, ifi);
    %Cue
    AnimationTextures = AnimateTextureMatrix(AnimationTextures, cueTextures, cueDuration, ifi);
    %PostCI
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, trialPostCIDuration, ifi);
    %Blank Screen during Target Period
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, stimDuration, ifi);
    %preCI response period
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, preCIDuration, ifi);
    
    %Playing Back Animation
    vbl = PlayAVAnimation(AnimationTextures, y, pahandle, volume, window, 0, ifi, 0, 0, 0, 0, rectCenter);
    
    
    VACoherence = round(VACoherence - VAStep, 5);
end 
    
%% --------------------
% Pure A --> V Block
%--------------------
%AV Noise #1
while AVCoherence >= AVFloor
    AVCoherence
    trialPostCIDuration = rand(1) * (postCIDuration(2) - postCIDuration(1)) + postCIDuration(1);
    
    %auditory pregeneration
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI1.WAV');
    CreateNoisyWAV(cueFrequency, cueFrequency, cueDuration, sampleFreq, 'Cue.WAV');
    CreateAuditoryNoise(trialPostCIDuration, sampleFreq, 'PostCI.WAV');
    CreateNoisyWAV(frequency, 0, stimDuration, sampleFreq, 'TargetTone.WAV');
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI2.WAV');  
    
    y1 = audioread('PreCI1.WAV');
    y1(:, 2) = y1(:, 1);
    y2 = audioread('Cue.WAV');
    y2(:, 2) = y2(:, 1);
    y3 = audioread('PostCI.WAV');
    y3(:, 2) = y3(:, 1);
    y4 = audioread('TargetTone.WAV');
    y4(:, 2) = y4(:, 1);
    y5 = audioread('PreCI2.WAV');
    y5(:, 2) = y5(:, 1);    
    
    y = [y1; y2; y3; y4; y5];
    y = y';
    
    
    AnimationTextures = [];
    
    %preCI
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, preCIDuration, ifi);
    %Cue
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, cueDuration, ifi);
    %PostCI
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, trialPostCIDuration, ifi);
    %Target Gabor
    AnimationTextures = AnimateNoisyGabor(AnimationTextures, gabor, noise, AVCoherence, stimDuration, ifi, window);
    %preCI response period
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, preCIDuration, ifi);
    
    %Playing Back Animation
    vbl = PlayAVAnimation(AnimationTextures, y, pahandle, volume, window, 0, ifi, 0, 0, 0, 0, rectCenter);
    
    
    AVCoherence = round(AVCoherence - AVStep, 5);
end

%% --------------------
% Pure A --> AV Block
%--------------------
%AV Noise #1
while A_AVCoherence >= A_AVFloor
    A_AVCoherence
    trialPostCIDuration = rand(1) * (postCIDuration(2) - postCIDuration(1)) + postCIDuration(1);
    
    %auditory pregeneration
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI1.WAV');
    CreateNoisyWAV(cueFrequency, cueCoherence, cueDuration, sampleFreq, 'Cue.WAV');
    CreateAuditoryNoise(trialPostCIDuration, sampleFreq, 'PostCI.WAV');
    CreateNoisyWAV(frequency, A_AVCoherence, stimDuration, sampleFreq, 'TargetTone.WAV');
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI2.WAV');  
    
    y1 = audioread('PreCI1.WAV');
    y1(:, 2) = y1(:, 1);
    y2 = audioread('Cue.WAV');
    y2(:, 2) = y2(:, 1);
    y3 = audioread('PostCI.WAV');
    y3(:, 2) = y3(:, 1);
    y4 = audioread('TargetTone.WAV');
    y4(:, 2) = y4(:, 1);
    y5 = audioread('PreCI2.WAV');
    y5(:, 2) = y5(:, 1);    
    
    y = [y1; y2; y3; y4; y5];
    y = y';
    
    
    AnimationTextures = [];
    
    %preCI
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, preCIDuration, ifi);
    %Cue
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, cueDuration, ifi);
    %PostCI
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, trialPostCIDuration, ifi);
    %Target Gabor
    AnimationTextures = AnimateNoisyGabor(AnimationTextures, gabor, noise, A_AVCoherence, stimDuration, ifi, window);
    %preCI response period
    AnimationTextures = AnimateVisualNoise(AnimationTextures, textures, preCIDuration, ifi);
    
    %Playing Back Animation
    vbl = PlayAVAnimation(AnimationTextures, y, pahandle, volume, window, 0, ifi, 0, 0, 0, 0, rectCenter);
    
    
    A_AVCoherence = round(A_AVCoherence - A_AVStep, 5);
end


PsychPortAudio('Close', pahandle);

KbStrokeWait;
sca;