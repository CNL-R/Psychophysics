%Inverse Effectiveness Pure Block Trials Only. Constant Stimuli. Paints Psychometric curve for A and V. 

% Clear the workspace and the screen
sca;
close all;
clearvars;

%------------------------
% Participant Information
%------------------------
participant = 'plswork';                                                    %name of the participant.

%--------------------
% Initial PTB Set-up
%--------------------
PsychDefaultSetup(2);                                                       % Setup PTB with some default values
screenNumber = max(Screen('Screens'));                                      % Set the screen number to the external secondary monitor if there is one connected
white = WhiteIndex(screenNumber);                                           % Define black, white and grey
black = BlackIndex(screenNumber);
grey = white / 2;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2, [], [],  kPsychNeed32BPCFloat); % Open the screen
ifi = Screen('GetFlipInterval', window);                                    %Query the monitor flip interval
Screen('TextFont', window, 'Ariel');                                        %Set the text font and size
Screen('TextSize', window, 40);
topPriorityLevel = MaxPriority(window);                                     %Query the maximum priority level
[xCenter, yCenter] = RectCenter(windowRect);                                %Get the center coordinate of the window
rand('seed', sum(100 * clock));                                             %random seed
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');  % Set up alpha-blending for smooth (anti-aliased) lines

%---------------------
% Block Params & Logic
%---------------------
numberConditions = 2;
blocksPerCondition = 5;

numberBlocks = numberConditions * blocksPerCondition;
blocksMatrix = repmat(1:numberConditions, 1, blocksPerCondition);           % blocksMatrix contains block order instructions
shuffler = randperm(numberBlocks);                                          % Declaring shuffler matrix to shuffle blocksMatrix
blocksMatrix = blocksMatrix(shuffler);                                      % Using shuffler shuffle blocksMatrix

% Within Block Params & Logic                                               % Enter your within block experiment specific parameters here
graduationsPerCondition = 10;                                               %
setsPerBlock = 5;                                                           % How many sets of graduations per block? i.e 5 sets of 10 graduations = 50 trials per block
numberTrialsPerBlock = graduationsPerCondition * setsPerBlock; 

%-----------------------
% Stimuli Pre-Generation
%-----------------------
%Timing Information
isiDuration = [1000 3000];                                     % Inter-stimulus-interval duration in ms
stimulusDuration = 60;                                         % Duration stimulus is on screen in ms

%Generating Visual Noise
sizeX = 500;                                                   % Dimmensions of the square noise patch 
sizeY = 500;                                                   % This code creates noise by pregenerating a pool of noise images which are sampled randomly
numberNoiseTextures = 100;                                     %    to create the animated noise. numberNoiseTextures is the size of that pool
noiseMatrix = rand(sizeY, sizeX, numberNoiseTextures);         % Pixel value matrices are converted to textures and stored in noiseTextures  
for i = 1:numberNoiseTextures
    noiseTextures(i) = Screen('MakeTexture', window, noiseMatrix(:,:,i));
end 

%Generating Base Gabor
gaborSize = 300;                                               % This is the diameter/length of any side of the gabor pixel matrix. 
sigma = 50;                                                    % Standard deviation of gaussian window in pixels
lambda = 20;                                                   % Wavelength of sine wave grating in pixels per cycle
orientation = 0;                                               % Orientation of gabor from 0 -> 2pi
phase = pi;                                                    % Phase of spatial sine wave from 0 -> 2pi
amplitude = 1;                                                 % Amplitude is a variable that changes peak values of the spatial sine wave. Change to 0.5
                                                               %  to make spatial sine wave take values from -.5 to .5   

gaborMatrix = CreateGabor2(gaborSize, sigma, lambda, orientation, phase, amplitude); %CreateGabor2 takes all of these parameters and spits out a pixel matrix for a gabor



