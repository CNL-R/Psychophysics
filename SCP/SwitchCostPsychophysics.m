%Switch Cost Psychophysics  
close all;
clearvars;

%------------------------
% Participant Information
%------------------------
participant = 'Developing';                                                    %name of the participant.
filepath = uigetdir('C:\Users\lhshaw\Desktop\Psychophysics DATA','Please select where to save your files');

Vmin = 0.1;
Vmax = .15;

Amin = 0.05;
Amax = 0.1;

%--------------------
% Initial PTB Set-up
%--------------------
PsychDefaultSetup(2);                                                       % Setup PTB with some default values
screenNumber = max(Screen('Screens'));                                      % Set the screen number to the external secondary monitor if there is one connected
white = WhiteIndex(screenNumber);                                           % Define black, white and grey
black = BlackIndex(screenNumber);
grey = white / 2;
%PsychDebugWindowConfiguration(1, 1);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2, [], [],  kPsychNeed32BPCFloat); % Open the screen
%Screen('ColorRange', window, 1);
ifi = Screen('GetFlipInterval', window);                                    %Query the monitor flip interval
refreshRate = 1/ifi;
Screen('TextFont', window, 'Ariel');                                        %Set the text font and size
Screen('TextSize', window, 40);
topPriorityLevel = MaxPriority(window);                                     %Query the maximum priority level
[xCenter, yCenter] = RectCenter(windowRect);                                %Get the center coordinate of the window
rand('seed', sum(100 * clock));                                             %random seed
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  % Set up alpha-blending for smooth (anti-aliased) lines
InitializePsychSound(1);                                                    % Initialize Sounddriver
nrchannels = 2;                                                             % Number of channels and sample rate
sampleFreq = 48000;
volume = 0.5;
startCue = 0;
repetitions = 1;
waitForDeviceStart = 1;

%---------------------
% Block Params & Logic
%---------------------
numberConditions = 4;
%1 - Pure A
%2 - Mix A
%3 - Pure V
%4 - Mix V
blockMatrix = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4];
shuffler = randperm(numel(blockMatrix));
blockMatrix = blockMatrix(shuffler);

%-------------------
% Stimuli Parameters
%-------------------
%Cue
cueDuration = 60; %in ms
cueFrequency = 500; %in hz
cueDiameter = 100; %in pixels

cueDot = zeros(cueDiameter);
cueDot(:,:) = 0.5;


%Stimulus
gradationsPerCondition = 16;
