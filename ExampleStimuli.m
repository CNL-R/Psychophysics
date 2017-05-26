%% INITIAL SETUP CODE
% Clear the workspace and screen
sca;
close all;
clearvars;
% Setup PTB with some default values
PsychDefaultSetup(2);
%Setting screen number: secondary monitor if it exists
screenNumber = 1;%max(Screen('Screens'));
% Define black, white and grey
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2, [], [], kPsychNeed32BPCFloat);
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

% Initialize Sounddriver
InitializePsychSound(1);
% Number of channels and sample rate
nrchannels = 2;
sampleFreq = 48000;
%Volume %
volume = 0.5;

% 
% %sound freq of cue in hz
% cueFreq = 1000;
% %Open audio port
% pahandle = PsychPortAudio('Open', [], 1, 1, sampleFreq, nrchannels, [], [], [], []);
% %Generate Sounds as .wav files
% CreateWAV(cueFreq, cueTime, sampleFreq, 'auditoryCue.wav');
% CreateWAV(0, cueTime, sampleFreq, 'nullCue.wav');

%% CREATE AND PRESENT YOUR VISUAL STIMULI
%SELECT YOUR MAIN PARAMETERS HERE
coherence = 1;
annulus = 1; %Insert annulus? 1 for yes. 0 for no. 
sigma = 50; %standard deviation of gaussian window in pixels
lambda = 50; %wavelength of sine grating (number of pixels per cycle) 
A = 1; %Amplitude variable of the sine wave grating. grating = A .* grating
probabilityGaussian = 0; %Embed stimulus in probability Gaussian? 1 for yes 0 for no
probability_sigma = 50; %standard deviation of probability gaussian window in pixels 

%apperture window properties
appX = 300; %apperature size (diameter of the circle in pixels)
appRadius = appX/2;
appY = appX;
appXCenter = appX/2;
appYCenter = appY/2;

%gabor size properties
stimLength = 150;
stimRadius = stimLength/2;
stimXPos = appXCenter/2;
stimYPos = appYCenter/2;

%Annulus Properties
if annulus == 1
    annulusDiameter = 300;
    annulusWidth = 10;
    annulusColor = .25;
    annulusBackgroundColor = 0.5;
end

%Creating Gaussian (used by embedInNoise if using probability gaussian as well. 
imSize = stimLength;
X0 = 1:imSize;                          
X0 = (X0 / imSize) - .5;                 
[Xm Ym] = meshgrid(X0, X0);
s = probability_sigma/imSize;
gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)));

%CREATING VISUAL STIMULUS
%Create annulus if annulus == 1;
if annulus == 1
    annulusMatrix = CreateAnnulus(annulusDiameter, annulusWidth, annulusColor, annulusBackgroundColor);
end 
%Create Stimulus
gaborMatrix = zeros(appY, appX);  %matrix containing pixel values for the texture being created. Expands to hold pixel values of all stimuli
gabor = CreateGabor(stimLength, sigma, lambda, 'r', 'r', A);
gabor = EmbedInNoise(gabor, coherence, probabilityGaussian, gauss);
gaborMatrix = EmbedInApperature(gabor, 'c', appX, appY, 'n', 0.5);
gaborMatrix = EmbedInAnnulus(gaborMatrix, annulusWidth, annulusColor);

hold on;
imshow(gaborMatrix);
%% PRESENTING THE STIMULUS
%create texture of stimulus
stimTexture = Screen('MakeTexture', window, gaborMatrix);

%defining area the texture will be displayed
xPos = xCenter;
yPos = yCenter;
baseRect = [0 0 appX appY];
%Centering texture in center of window
rectCenter = CenterRectOnPointd(baseRect, xPos, yPos);

Screen('DrawTextures', window, stimTexture, [], rectCenter, [], [], [], []);
Screen('Flip', window);

%Wait until kb stroke to close
KbStrokeWait;
close all;

