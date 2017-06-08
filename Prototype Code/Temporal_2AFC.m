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

%--------------------
% TIMING INFORMATION
%--------------------
preCIDuration = 1000;
postCIDuration = [500 1500]; %duration pure noise in ms
stimDuration = 100; %duration stimulus in ms
cueDuration = 500; %in ms

%% --------------------
% Visual Noise Parameters & Generation
%--------------------
length = 500;
width = 500;
isiDuration = 500;
waitframes = 1;

timeSecs = stimDuration/1000;
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

%--------------------
% Visual Gabor Paremeters
%--------------------
gaborLength = 300;
gaborWidth = gaborLength;
coherence = 0;

sigma = 50;
lambda = 50;
A = 1;

gabor = CreateGabor2(gaborWidth, sigma, lambda, 'r', 'r', A);

blank = Screen('MakeTexture', window, 0);
order = [1 2];

%--------------------
% Visual Gabor Generation & Playback
%--------------------
while coherence > 0
coherence
shuffler = randperm(2);
orderShuffled = order(shuffler)
%Generating Gabor w/ Animated Noise texture matrix
stimulusTextures = GenerateAnimatedNoiseGabor(gabor, noise, coherence, stimDuration, ifi, window);
% refreshRate = 1/ifi;
% for frame = 1:round(refreshRate*stimDuration/1000)
%     noised_gabor = EmbedInNoise(gabor, coherence, 0, 0);
%     stim = EmbedInEfficientApperature(noised_gabor, noise(:,:, round(rand(1) * (numTextures - 1) + 1)));
%     stimTexture(frame) = Screen('MakeTexture', window, stim);    
% end

% Playing preCI
vbl = PresentAnimatedNoise(textures, window, 0, ifi, preCIDuration, 0, 0, 0, 0, 0, rectCenter);
% Screen('DrawTextures', window, textures(round(rand(1) * (numTextures - 1) + 1)), [], rectCenter, [], [], [], []);
% vbl = Screen('Flip', window);
% for frame = 1:timeFrames - 1
%     
%     Screen('DrawTextures', window, textures(round(rand(1) * (numTextures - 1) + 1)), [], rectCenter, [], [], [], []);
%     vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
%     
 %end
 
 %Playing Back Cue
vbl = PresentAnimatedNoiseGabor(cueTextures, window, vbl, ifi, cueDuration, 0, 0, 0, 0, 0, cueRectCenter);

% Playing postCI
vbl = PresentAnimatedNoise(textures, window, vbl, ifi, postCIDuration(1), postCIDuration(2), 0, 0, 0, 0, rectCenter);

% Playing Back Gabor or Noise
if orderShuffled(1) == 1
    vbl = PresentAnimatedNoiseGabor(stimulusTextures, window, vbl, ifi, stimDuration, 0, 0, 0, 0, 0, rectCenter);
elseif orderShuffled(1) == 2
    vbl = PresentAnimatedNoise(textures, window, 0, ifi, stimDuration, 0, 0, 0, 0, 0, rectCenter);
end 
% Screen('DrawTextures', window, stimulusTextures(1) ,[], rectCenter, [], [], [], []);
% vbl = Screen('Flip', window);
% for frame = 1:timeFrames - 1
%     Screen('DrawTextures', window, stimulusTextures(frame + 1), [], rectCenter, [], [], [], []);
%     vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
% end

% Playing preCI
vbl = PresentAnimatedNoise(textures, window, vbl, ifi, preCIDuration, 0, 0, 0, 0, 0, rectCenter);

%Playing Cue
vbl = PresentAnimatedNoiseGabor(cueTextures, window, vbl, ifi, cueDuration, 0, 0, 0, 0, 0, cueRectCenter);

% Playing postCI
vbl = PresentAnimatedNoise(textures, window, vbl, ifi, postCIDuration(1), postCIDuration(2), 0, 0, 0, 0, rectCenter);

%Playing target interval
if orderShuffled(2) == 1
    vbl = PresentAnimatedNoiseGabor(stimulusTextures, window, vbl, ifi, stimDuration, 0, 0, 0, 0, 0, rectCenter);
elseif orderShuffled(2) == 2
    vbl = PresentAnimatedNoise(textures, window, 0, ifi, stimDuration, 0, 0, 0, 0, 0, rectCenter);
end 

% Playing preCI
vbl = PresentAnimatedNoise(textures, window, vbl, ifi, preCIDuration, 0, 0, 0, 0, 0, rectCenter);

% Playing Back Noise Response Period
vbl = PresentDiscriminationPeriod('Did the stimulus appear in the first interval or second interval?\n Press the left arrow key for the first and right arrow key for the second', window, vbl, ifi, isiDuration, 0, 0, 0, 0, rectCenter);

coherence = coherence - .1;
end

%% --------------------
% Auditory Generation & Playblack
%--------------------
% Auditory Parameters
frequency = 1000;
cueFrequency = 500;
audCoherence = 0;

%Open audio port
pahandle = PsychPortAudio('Open', [], 1, 1, sampleFreq, nrchannels, [], [], [], []);

order = [1 2];
while audCoherence > 0
    Screen('FillRect', window, 0.5);
    Screen('Flip', window);
    
    %Generating WAVS
    audCoherence
    shuffler = randperm(2);
    orderShuffled = order(shuffler);
    
    audCoherence = audCoherence - .1
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI1.WAV');
    CreateNoisyWAV(cueFrequency, .9, cueDuration, sampleFreq, 'Cue.WAV');
    CreateAuditoryNoise(postCIDuration, sampleFreq, 'PostCI.WAV');
    CreateNoisyWAV(frequency, audCoherence, stimDuration, sampleFreq, 'TargetTone.WAV');
    CreateAuditoryNoise(stimDuration, sampleFreq, 'TargetNoise.WAV');
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI2.WAV');
    CreateAuditoryNoise(postCIDuration, sampleFreq, 'PostCI2.WAV');
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI3.WAV');
    
    y1 = audioread('PreCI1.WAV');
    y1(:, 2) = y1(:, 1);
    y2 = audioread('Cue.WAV');
    y2(:, 2) = y2(:, 1);
    y3 = audioread('PostCI.WAV');
    y3(:, 2) = y3(:, 1);
    if orderShuffled(1) == 1
        y4 = audioread('TargetTone.WAV');
        y4(:, 2) = y4(:, 1);
    elseif orderShuffled(1) == 2
        y4 = audioread('TargetNoise.WAV');
        y4(:, 2) = y4(:, 1);
    end
    y5 = audioread('PreCI2.WAV');
    y5(:, 2) = y5(:, 1);
    y6 = audioread('Cue.WAV');
    y6(:, 2) = y6(:, 1);
    y7 = audioread('PostCI2.WAV');
    y7(:, 2) = y7(:, 1);
    if orderShuffled(2) == 1
        y8 = audioread('TargetTone.WAV');
        y8(:, 2) = y8(:, 1);
    elseif orderShuffled(2) == 2
        y8 = audioread('TargetNoise.WAV');
        y8(:, 2) = y8(:, 1);
    end
    y9 = audioread('PreCI3.WAV');
    y9(:, 2) = y9(:, 1);
    
    y = [y1; y2; y3; y4; y5; y6; y7; y8; y9];
    y = y';
    
    
    PsychPortAudio('FillBuffer', pahandle, y);
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    PsychPortAudio('Stop', pahandle, 1, 1);
    
    % Playing Back Noise Response Period
    PresentDiscriminationPeriod('Did the stimulus appear in the first interval or second interval?\n Press the left arrow key for the first and right arrow key for the second', window, 0, ifi, isiDuration, 0, 0, 0, 0, rectCenter);
    
    audCoherence = audCoherence - .1;
end 

%% --------------------
%Multisensory Playback
%--------------------
AVCoherence = 1;
%AV Noise #1
while AVCoherence > 0
    AVCoherence
    
    shuffler = randperm(2);
    orderShuffled = order(shuffler);
    
    
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI1.WAV');
    CreateNoisyWAV(cueFrequency, .9, cueDuration, sampleFreq, 'Cue.WAV');
    CreateAuditoryNoise(postCIDuration, sampleFreq, 'PostCI.WAV');
    CreateNoisyWAV(frequency, audCoherence, stimDuration, sampleFreq, 'TargetTone.WAV');
    CreateAuditoryNoise(stimDuration, sampleFreq, 'TargetNoise.WAV');
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI2.WAV');
    CreateAuditoryNoise(postCIDuration, sampleFreq, 'PostCI2.WAV');
    CreateAuditoryNoise(preCIDuration, sampleFreq, 'PreCI3.WAV');
    
    y1 = audioread('PreCI1.WAV');
    y1(:, 2) = y1(:, 1);
    y1 = y1';
    y2 = audioread('Cue.WAV');
    y2(:, 2) = y2(:, 1);
    y2 = y2';
    y3 = audioread('PostCI.WAV');
    y3(:, 2) = y3(:, 1);
    y3 = y3';
    if orderShuffled(1) == 1
        y4 = audioread('TargetTone.WAV');
        y4(:, 2) = y4(:, 1);
        y4 = y4';
    elseif orderShuffled(1) == 2
        y4 = audioread('TargetNoise.WAV');
        y4(:, 2) = y4(:, 1);
        y4 = y4';
    end
    y5 = audioread('PreCI2.WAV');
    y5(:, 2) = y5(:, 1);
    y5 = y5';
    y6 = audioread('Cue.WAV');
    y6(:, 2) = y6(:, 1);
    y6 = y6';
    y7 = audioread('PostCI2.WAV');
    y7(:, 2) = y7(:, 1);
    y7 = y7';
    if orderShuffled(2) == 1
        y8 = audioread('TargetTone.WAV');
        y8(:, 2) = y8(:, 1);
        y8 = y8';
    elseif orderShuffled(2) == 2
        y8 = audioread('TargetNoise.WAV');
        y8(:, 2) = y8(:, 1);
        y8 = y8';
    end
    y9 = audioread('PreCI3.WAV');
    y9(:, 2) = y9(:, 1);
    y9 = y9';
    
    %visual pregeneration
    stimulusTextures = GenerateAnimatedNoiseGabor(gabor, noise, AVCoherence, stimDuration, ifi, window);
    
    %Present PreCI
    vbl = PresentAVNoise(textures, y1, pahandle, volume, window, 0, ifi, preCIDuration, 0, 0, 0, 0, 0, rectCenter);
    %Present Cue
    vbl = PresentAnimatedAVNoiseGabor(cueTextures, y2, pahandle, volume, window, vbl, ifi, cueDuration, 0, 0, 0, 0, 0, rectCenter);
    %Present PostCI
    vbl = PresentAVNoise(textures, y3, pahandle, volume, window, vbl, ifi, postCIDuration(1), postCIDuration(2), 0, 0, 0, 0, rectCenter);
    %Present Target Period
    if orderShuffled(1) == 1
        vbl = PresentAnimatedAVNoiseGabor(stimulusTextures, y4, pahandle, volume, window, vbl, ifi, stimDuration, 0, 0, 0, 0, 0, rectCenter);
    elseif orderShuffled(1) == 2
        vbl = PresentAVNoise(textures, y4, pahandle, volume, window, vbl, ifi, stimDuration, 0, 0, 0, 0, 0, rectCenter);
    end
    %Present PreCI2
    vbl = PresentAVNoise(textures, y5, pahandle, volume, window, vbl, ifi, preCIDuration, 0, 0, 0, 0, 0, rectCenter);
    %Present Cue2
    vbl = PresentAnimatedAVNoiseGabor(cueTextures, y6, pahandle, volume, window, vbl, ifi, cueDuration, 0, 0, 0, 0, 0, rectCenter);
    %Present PostCI2
    vbl = PresentAVNoise(textures, y7, pahandle, volume, window, vbl, ifi, postCIDuration(1), postCIDuration(2), 0, 0, 0, 0, rectCenter);
    %Present Target Period 2
    if orderShuffled(2) == 1
        vbl = PresentAnimatedAVNoiseGabor(stimulusTextures, y8, pahandle, volume, window, vbl, ifi, stimDuration, 0, 0, 0, 0, 0, rectCenter);
    elseif orderShuffled(2) == 2
        vbl = PresentAVNoise(textures, y8, pahandle, volume, window, vbl, ifi, stimDuration, 0, 0, 0, 0, 0, rectCenter);
    end
    %Present PreCI3
    vbl = PresentAVNoise(textures, y9, pahandle, volume, window, vbl, ifi, preCIDuration, 0, 0, 0, 0, 0, rectCenter);
    
    % Playing Back Noise Response Period
    PresentDiscriminationPeriod('Did the stimulus appear in the first interval or second interval?\n Press the left arrow key for the first and right arrow key for the second', window, 0, ifi, isiDuration, 0, 0, 0, 0, rectCenter);
    AVCoherence = AVCoherence - .1;
end
PsychPortAudio('Close', pahandle);
