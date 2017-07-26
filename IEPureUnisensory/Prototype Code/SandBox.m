%Nice little script with everything needed to do a presentation and some basic matrices, textures, and sounds to mess around with. 
%% --------------------
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

%% ------------------
% Sample Textures
%--------------------
gaborDiameter = 300;
sigma = 50;
lambda = 50;
A = 1;

vSample1Matrix = CreateGabor(gaborDiameter, sigma, lambda, 0, 0, A);
vSample2Matrix = CreateGabor(gaborDiameter, sigma, lambda, pi/2, 0, A);

vSample1Texture = Screen('MakeTexture', window, vSample1Matrix);
vSample2Texture = Screen('MakeTexture', window, vSample2Matrix);

length = gaborDiameter;
height = gaborDiameter;
baseRect = [0 0 length height];
%% ------------------
% Playground
%--------------------
crossLength = 50;
crossWidth = 3;
crossCenter = crossLength/2;

cross = zeros(crossLength);
cross(:,:) = 0.5;
cross(crossCenter-crossWidth:crossCenter+crossWidth, 1:crossLength) = 1;
cross( 1:crossLength, crossCenter-crossWidth:crossCenter+crossWidth) = 1;
imshow(cross)