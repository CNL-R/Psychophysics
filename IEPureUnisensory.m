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
blocksPerCondition = 5;
numberBlocks = numberConditions * blocksPerCondition;
blockMatrix = repmat(1:numberConditions, 1, blocksPerCondition);           % blockMatrix contains block order instructions. 1D matrix with numbers indicating block type
shuffler = randperm(numberBlocks);                                          % Declaring shuffler matrix to shuffle blockMatrix
blockMatrix = blockMatrix(shuffler);                                      % Using shuffler shuffle blockMatrix

% Within Block Params & Logic                                               % Enter your within block experiment specific parameters here
graduationsPerCondition = 10;                                               % 
setsPerBlock = 5;                                                           % How many sets of graduations per block? i.e 5 sets of 10 graduations = 50 non-catch trials per block
stimuliPerBlock = graduationsPerCondition * setsPerBlock;
catchTrialsPerBlock = stimuliPerBlock;                                      % How many catch trials do you want in a block?
numberTrialsPerBlock = stimuliPerBlock + catchTrialsPerBlock;

%-------------------
% Stimuli Parameters
%-------------------
%Timing Information
startDuration = 2000;                                          % Interval before first stimulus of each block in ms
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

%Generating Pure Fixation Cross
crossLength = 50;
crossWidth = 3;
crossCenter = crossLength/2;
cross = zeros(crossLength);
cross(:,:) = 0.5;
cross(crossCenter-crossWidth:crossCenter+crossWidth, 1:crossLength) = 1;
cross( 1:crossLength, crossCenter-crossWidth:crossCenter+crossWidth) = 1;
crossTexture = Screen('MakeTexture', window, cross);

%Generating Base Gabor
gaborSize = 300;                                               % This is the diameter/length of any side of the gabor pixel matrix. 
sigma = 50;                                                    % Standard deviation of gaussian window in pixels
lambda = 20;                                                   % Wavelength of sine wave grating in pixels per cycle
orientation = 0;                                               % Orientation of gabor from 0 -> 2pi
phase = pi;                                                    % Phase of spatial sine wave from 0 -> 2pi
amplitude = 1;                                                 % Amplitude is a variable that changes peak values of the spatial sine wave. Change to 0.5
                                                               %  to make spatial sine wave take values from -.5 to .5   

gaborMatrix = CreateGabor2(gaborSize, sigma, lambda, orientation, phase, amplitude); %CreateGabor2 takes all of these parameters and spits out a pixel matrix for a gabor

%Visual Stimuli Parameters
visualParameters = zeros(3, graduationsPerCondition);          % Matrix to keep track of parameters of each generated visual stimuli.
visualParameters(1,:) = [0 .05 .1 .15 .2 .25 .3 .35 .45 .5 ];  % Assigning coherences
visualParameters(2,:) = orientation;                           % Assigning orientations. 0->2pi
visualParameters(3,:) = phase;                                 % Assigning phases. 0->2pi

%Auditory Stimuli Parameters
frequency1 = 1000;                                             %To create a ripple, two sine waves are multiplied with each other 
frequency2 = 200;

%--------------------------------
% Experimental Loop & Trial Logic
%--------------------------------
 baseTrialMatrix = [repmat(visualParameters, 1, setsPerBlock) zeros(3, catchTrialsPerBlock)];   % Creates a single row matrix to act as a base matrix for presenting a single block
 trialsPerBlock = size(baseTrialMatrix, 2);
 trialMatrix = repmat(baseTrialMatrix, 1, 1, numberBlocks);                                     % Expands the single row matrix in the third dimmension to accomodate all blocks. type of data - trial # - block # 
 shuffler = randperm(trialsPerBlock);                                                           % Shuffler matrix to randomly permute trialMatrix so that trial order is randomized. 
 trialMatrix = trialMatrix(:, shuffler, :);
 
for block = 1:1%numberBlocks
    
    %Generating Animation Matrices for this block
    timeElapsed = 0;                                                                         % Simple counter to keep track of how much time has elapsed in the animation. Willbe used to keep track of responseWindows
    visualMatrix = [];                                                                       % Initializing visualMatrix, a 1D array containing textures for the entire block. 
    audioMatrix = [];                                                                        % Initializing audioMatrix, a 2xtrials array containing audio information for the entire block
    responseWindowMatrix = [];                                                               % Initializing responseWindowMatrix, a 2D array containing response windows for the entire block
                                                                                                % [RWStart#1 RWStart#2...]
    
    %Building animation matrices for start interval before first presentation 
    if blockMatrix(block) == 1 %Pure Visual Block                                           % Checking block type and filling animation matrices with initial isi before first stimuli presentation
        visualMatrix = AnimateVisualNoise(visualMatrix, noiseTextures, startDuration, ifi, 0); % Adding visual noise to visualMatrix
        audioMatrix = AnimateAuditorySilence(audioMatrix, startDuration, sampleFreq);       % Adding silence to audioMatrix
    elseif blockMatrix(block) == 2 %Pure Auditory Block
        visualMatrix = AnimateVisualNoise(visualMatrix, crossTexture, startDuration, ifi);  % Adding fixation cross
        audioMatrix = AnimateAuditoryNoise(audioMatrix, startDuration, sam xxxxx cpleFreq);         % Adding Auditory Noise
    end
    timeElapsed = timeElapsed + startDuration;                                              % Upticking timeElapsed by startDuration
    
    %Building animation matrices for all trials per block
    for trial = 1:trialsPerBlock
        coherence = trialMatrix(1, trial, block);                                           % Loading parameters from trialMatrix for code readability
        orientation = trialMatrix(2, trial, block);
        phase = trialMatrix(3, trial, block);
        %Building stimulus
        if blockMatrix(block) == 1
            visualMatrix = AnimateNoisyGabor(visualMatrix, gaborMatrix, noiseMatrix, coherence, stimulusDuration, ifi, window); % Adding noisy gabor stimulus to visualMatrix
            audioMatrix = AnimateAuditorySilence(audioMatrix, stimulusDuration, sampleFreq);                                    % Adding silence to audioMatrix
        elseif blockMatrix(block) == 2
            visualMatrix = AnimateVisualNoise(visualMatrix, crossTexture, stimulusDuration, ifi);                               % Adding fixation cross to visualMatrix
            audioMatrix = AnimateNoisyRipple(audioMatrix, frequency1, frequency2, coherence, stimulusDuration, sampleFreq);     % Adding noisy ripple sound to audioMatrix
        end 
        timeElapsed = timeElapsed + stimulusDuration;                                                                           % Upticking timeElapsed by stimulusDuration                                                                           
        
        %Building ISI Response Interval
        if blockMatrix(block) == 1
            [visualMatrix isiActualTime] = AnimateVisualNoise(visualMatrix, noiseTextures, isiDuration, ifi);  % Adding visual noise to visualMatrix. Retrieve Response window, the interval during which to tell the presentation function to get responses
            audioMatrix = AnimateAuditorySilence(audioMatrix, isiDuration, sampleFreq);                        % Adding silence to audioMatrix                                        % Building responseWindowMatrix
        elseif blockMatrix(block) == 2
            [visualMatrix isiActualTime] = AnimateVisualNoise(visualMatrix, crossTexture, isiDuration, ifi);   % Adding fixation cross to visualMatrix
            audioMatrix = AnimateAuditoryNoise(audioMatrix, isiDuration, sampleFreq);                          % Adding Auditory Noise                                    % Building responseWindowMatrix
        end
        timeElapsed = timeElapsed + isiActualTime;                                                             % Upticking timeElapsed by the randomly chosen time interval for the isi. 
        responseWindow = [timeElapsed - isiActualTime; timeElapsed];                                           % Calculating the responseWindow by taking timeElapsed and subtracting by isiActualTime for responsewindow onset
                                                                                                                    % and using timeElapsed for end of responseWindow
        responseWindowMatrix = [responseWindowMatrix responseWindow];                                          % Building responseWindowMatrix
        
        
    end 
        sca;
end 

