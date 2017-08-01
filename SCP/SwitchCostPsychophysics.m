close all;
clearvars;

%------------------------
% Participant Information
%------------------------
participant = 'Eric';                                                    %name of the participant.
filepath = uigetdir('C:\Users\lhshaw\Desktop\Psychophysics DATA','Please select where to save your files');

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
numberConditions = 2;
blocksPerCondition = 8;
numberBlocks = numberConditions * blocksPerCondition;
blockMatrix = repmat(1:numberConditions, 1, blocksPerCondition);         % blockMatrix contains block order instructions. 1D matrix with numbers indicating block type
shuffler = randperm(numberBlocks);                                         % Declaring shuffler matrix to shuffle blockMatrix
blockMatrix = blockMatrix(shuffler);                                      % Using shuffler shuffle blockMatrix

% Within Block Params & Logic                                              % Enter your within block experiment specific parameters here
gradationsPerCondition = 16;                                            % 
setsPerBlock = 5;                                                     % How many sets of gradationss per block? i.e 5 sets of 10 gradationss = 50 non-catch trials per block
stimuliPerBlock = gradationsPerCondition * setsPerBlock;
catchTrialsPerBlock = 0;                                                  % How many catch trials do you want in a block?
numberTrialsPerBlock = stimuliPerBlock + catchTrialsPerBlock;

%-------------------
% Stimuli Parameters
%-------------------
%Timing Information
startDuration = 2000;                                          % Interval before first stimulus of each block in ms
startDurationAuditory = (fix(startDuration/1000*refreshRate)) * (1/refreshRate) * 1000;
isiDurationPossible = [1400 2800];                                     % Inter-stimulus-interval duration in ms
stimulusDuration = 60;                                         % Duration stimulus is on screen in ms
stimulusDurationAuditory = (fix(stimulusDuration/1000*refreshRate)) *  (1/refreshRate) * 1000;

blockMaxDuration = startDuration + numberTrialsPerBlock*(max(isiDurationPossible)+stimulusDuration);

%Monitor params
sizeX = 500;                                                   % Dimmensions of the square noise patch
sizeY = 500;  
%Centering textures in center of window
xPos = xCenter;
yPos = yCenter;
baseRect = [0 0 sizeX sizeY];
rectCenter = CenterRectOnPointd(baseRect, xPos, yPos);

%Generating Pure Fixation Cross
crossLength = 10;
crossWidth = 1;
cross = zeros(sizeX);
cross(:,:) = 0.5;
crossCenter = size(cross, 1) / 2;
cross = repmat(cross, 1, 1, 3);
cross(crossCenter - crossWidth:crossCenter+crossWidth,crossCenter - crossLength:crossCenter + crossLength,1) = 1;
cross(crossCenter - crossWidth:crossCenter+crossWidth,crossCenter - crossLength:crossCenter + crossLength,2:3) = 0;
cross(crossCenter - crossLength:crossCenter + crossLength, crossCenter-crossWidth:crossCenter+crossWidth, 1) = 1;
cross(crossCenter - crossLength:crossCenter + crossLength, crossCenter-crossWidth:crossCenter+crossWidth, 2:3) = 0;
crossTexture = Screen('MakeTexture', window, cross);

%Generating Visual Noise                                                % This code creates noise by pregenerating a pool of noise images which are sampled randomly
numberNoiseTextures = 200;                                     %    to create the animated noise. numberNoiseTextures is the size of that pool
noiseMatrix = zeros(sizeY, sizeX, 3, numberNoiseTextures);
for i = 1:numberNoiseTextures
    noise = rand(sizeY, sizeX);
    noise = repmat(noise, 1, 1, 3);
    noise(crossCenter - crossWidth:crossCenter+crossWidth,crossCenter - crossLength:crossCenter + crossLength,1) = 1;
    noise(crossCenter - crossWidth:crossCenter+crossWidth,crossCenter - crossLength:crossCenter + crossLength,2:3) = 0;
    noise(crossCenter - crossLength:crossCenter + crossLength, crossCenter-crossWidth:crossCenter+crossWidth, 1) = 1;
    noise(crossCenter - crossLength:crossCenter + crossLength, crossCenter-crossWidth:crossCenter+crossWidth, 2:3) = 0;
    noiseMatrix(:,:,:,i) = noise;
    noiseTextures(i) = Screen('MakeTexture', window, noiseMatrix(:,:,:,i));
end
 

%Generating Base Gabor
gaborSize = 300;                                               % This is the diameter or length of any side of the gabor pixel matrix. 
sigma = 50;                                                    % Standard deviation of gaussian window in pixels
lambda = 20;                                                   % Wavelength of sine wave grating in pixels per cycle
orientation = 0;                                               % Orientation of gabor from 0 -> 2pi
phase = pi;                                                    % Phase of spatial sine wave from 0 -> 2pi
amplitude = 1;                                                 % Amplitude is a variable that changes peak values of the spatial sine wave. Change to 0.5
                                                               %  to make spatial sine wave take values from -.5 to .5   
gaborMatrix = CreateGabor2(gaborSize, sigma, lambda, orientation, phase, amplitude); %CreateGabor2 takes all of these parameters and spits out a pixel matrix for a gabor

%Visual Parameters
VTParameters = zeros(1, gradationsPerCondition);          % Matrix to keep track of parameters of each generated visual stimuli.
VTParameters(1,:) = [0 .025 .05 .06 .07 .08 .09 .1 .11 .12 .13 .14 .15 .2 .25 .3];                                   % Assigning coherences                                % Assigning phases. 0->2p
VCParameters = zeros(1, gradationsPerCondition);
VCParameters(1,:) = 1;


%Auditory Stimuli Parameters
frequency1 = 1000;                                             %To create a ripple, two sine waves are multiplied with each other 
frequency2 = 200;
ATParameters = zeros(1, gradationsPerCondition);
ATParameters(1,:) = [0 .025 .05 .06 .07 .08 .09 .1 .11 .12 .13 .14 .15 .2 .25 .3];   
ACParameters(1,:) = 1;

%--------------------------------
% Experimental Loop & Trial Logic
%--------------------------------
masterCell = cell(3, numberBlocks);                             %Creates masterCell

for block = 1:numberBlocks
    masterCell{1, block} = blockMatrix(block);
    
    
end 


