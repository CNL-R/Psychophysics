%EXPERIMENT 2.0
%   - No Cues
%   - Yes/No Up-Down Transformed
%   - Animated Noise Patches & Animated Noise Gabor Patches

% Clear the workspace and the screen
sca;
close all;
clearvars;

%TIMING VERSION of EXPERIMENT 1_2
trials = 10; %How many trials per block %TIMING CODE
%all timing code has %TIMING CODE commented to the right of it. 
%--------------------
% Initial Initial Set-up Stuff
%--------------------
%name of the participant.
participant = 'test2';

%--------------------
% Initial Set-up Stuff
%--------------------
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

%Open audio port
pahandle = PsychPortAudio('Open', [], 1, 1, sampleFreq, nrchannels, [], [], [], []);

%--------------------
% Experiment Parameters
%--------------------
%number of blocks per condition
blocksPerCondition = 1;

%number of blocks total
blocks = blocksPerCondition * 3; %3 is number of conditions

%blocks Matrix to give experimental loop info about what type of block to play and keep track of psychometric threshold
blockMatrix = repmat([1:3; 0 0 0; 0 0 0], 1, blocksPerCondition);
%blockMatrix(1,:) = condition per each block
    %1 - Pure Visual Block
    %2 - Pure Auditory Block
    %3 - Pure Audiovisual Block
%blockMatrix(2,:) = psychThreshold
%blockMatrix(3,:) = average RT
blockMatrix(1,1:3) = [1 2 3];
blockMatrix(1,4:6) = [2 3 1];
blockMatrix(1,7:9) = [3 1 2];

%number of reversals/runs per block
runs = 8;
 
%initial step size
initialStep = 0.3;

%initial stimulus coherence value
initialCoherence = 0.5;

%preallocated number of trials per block
prealNum = 100;

%matrix for storing trial number and coherence value for that stimulus.
%Initially set to length 'prealNum' for pre-allocation
% 1 - trialNum
% 2 - stimCoherence
stimMat = repmat(1:prealNum, 1, 1, blocks);
stimMat(2,:,:) = 0;
stimMat(2,1,:) = initialCoherence;

%matrix for holding the sign of each trial. 
sign = zeros(prealNum, blocks);

%matrix for holding the UPD TRANSFORMED UpGroup and DownGroup. StartingIndex Matrices for holding what index to start checking from (used to accomodate for NaN's)
upGroup = [[NaN 0 0]; [0 1 0]; [1 0 0];];
upStartingIndex = [2, 1, 1];
downGroup = [[NaN 1 1];[1 0 1];[0 1 1];];
downStartingIndex = [2, 1, 1];

%Maximum number of elements per upGroup and downGroup. 
maxSizeUp = 3;
maxSizeDown = 3;

%catch trial information
catchFrequency = 0.5; %what percentage of the trials will be catch trials
subFrequency = 0.5; %what percentage of the catch trials will be subliminal (0% coherence). assuming supraFrequency is 1-subFrequency

%initializing catchMat, the matrix that holds data about which trials are
%catch trials, and what type of catch trial. 
catchMat = zeros(prealNum, blocks);

%--------------------
% Visual Stimulus Parameters
%--------------------
%Animated Noise Properties
animatedNoiseX = 300; %app size
animatedNoiseY = 300;
animatedNoiseXCenter = animatedNoiseX/2;
animatedNoiseYCenter = animatedNoiseY/2;
appRadius = animatedNoiseX/2;

%Visual Gabor Stimulus Properties
gaborLength = 150;
gaborRadius = gaborLength/2;
gaborXPos = animatedNoiseXCenter/2;
gaborYPos = animatedNoiseYCenter/2;
lambda = 50; %wavelegnth (number of pixels per cycle)
sigma = 50; %gaussian standard deviation in pixels
A = 1; %amplitude variable

%defining area the texture will be displayed
xPos = xCenter;
yPos = yCenter;
baseRect = [0 0 animatedNoiseX animatedNoiseY];
%Centering texture in center of window
rectCenter = CenterRectOnPointd(baseRect, xPos, yPos);

%--------------------
% Auditory Stimulus Parameters
%--------------------
%Auditory Noise Properties
auditoryNoiseDuration = 1000; %in ms


%--------------------
% Stimuli Pre-Generation
%--------------------
%Generating Visual Noise Pool
numTextures = 100;
noise = rand(animatedNoiseY, animatedNoiseX, numTextures);
for i = 1:numTextures
    visualTextures(i) = Screen('MakeTexture', window, noise(:,:, i));
end 

%Generating gabor matrices
gabor(:,:,1) = CreateGabor(gaborWidth, sigma, lambda, 0, 0, A);
gabor(:,:,2) = CreateGabor(gaborWidth, sigma, lamda, pi/2, 0, A);
gabor(:,:,3) = CreateGabor(gaborWidth, sigma, lamda, pi, 0, A);
gabor(:,:,4) = CreateGabor(gaborWidth, sigma, lamda, 3*pi/2, 0, A);

gabor(:,:,5) = CreateGabor(gaborWidth, sigma, lambda, 0, pi/2, A);
gabor(:,:,6) = CreateGabor(gaborWidth, sigma, lamda, pi/2, pi/2, A);
gabor(:,:,7) = CreateGabor(gaborWidth, sigma, lamda, pi, pi/2, A);
gabor(:,:,8) = CreateGabor(gaborWidth, sigma, lamda, 3*pi/2, pi/2, A);

gabor(:,:,9) = CreateGabor(gaborWidth, sigma, lambda, 0, pi, A);
gabor(:,:,10) = CreateGabor(gaborWidth, sigma, lamda, pi/2, pi, A);
gabor(:,:,11) = CreateGabor(gaborWidth, sigma, lamda, pi, pi, A);
gabor(:,:,12) = CreateGabor(gaborWidth, sigma, lamda, 3*pi/2, pi, A);

gabor(:,:,13) = CreateGabor(gaborWidth, sigma, lambda, 0, 3*pi/2, A);
gabor(:,:,14) = CreateGabor(gaborWidth, sigma, lamda, pi/2, 3*pi/2, A);
gabor(:,:,15) = CreateGabor(gaborWidth, sigma, lamda, pi, 3*pi/2, A);
gabor(:,:,16) = CreateGabor(gaborWidth, sigma, lamda, 3*pi/2, 3*pi/2, A);

%Creating WAV File for auditory Noise
CreateAuditoryNoise(auditoryNoiseDuration, sampleFreq, 'Noise.WAV');


%--------------------
% Timing Information %TIMING CODE: DeScrambled Intervals
%--------------------
%Grey Annulus (in ms)
annulusTime = [1000 1000];%[1000 2140]; TIMING CODE

%Cue Time (in ms)
cueTime = 512;
beepDuration = cueTime;

%Pre-Presentation Grey Annulus Time (in ms)
preStimTime = [200 200]; %[50 300]; TIMING CODE

%Stimulus Presentation Time (in ms)
stimulusTime = 60;

%Number of frames to wait before re-drawing
waitframes = 1;

timesCue = zeros(trials + 1, blocks); %TIMING CODE
timesPresentation = timesCue; %TIMING CODE
timesPreP = timesCue; %TIMING CODE
timesPostP = timesCue; %TIMING CODE
timesPreStim = timesCue; %TIMING CODE
timesStim = timesCue; %TIMING CODE
timesISI = timesCue; %TIMING CODE


%--------------------
% Data / Information Storage
%--------------------
%3D matrix. Row 1 - stimulus Coherence . Row 2 - 1 or 0 for detected or not. Row
%3 - RT if detected. 0 if not detected. Each column is an individual
%stimulus presentation. Third dimmension is block number
respMatrix = nan(3, prealNum, blocks);

%matrix to hold all peaks and valleys of the psychometric function
%(coherence values where a reversal happened)
pvMatrix = NaN(prealNum,blocks);

%matrix to hold all non-catch trial responses 
nonCatchMatrix = zeros(prealNum, blocks);

%index value matrix to hold index values of different types of responses
historyPRespMatrix = NaN(prealNum, blocks);
historyNRespMatrix = historyPRespMatrix;
historyCatchMatrix = historyPRespMatrix;

%matrix to hold calculated psychthresholds
psychThresh = zeros(blocks, 1);

%History Matrix
% Matrix to keep all useful information about a single trial in one place. 
%   Row 1: block type
%   Row 2: 1 for catch trial, 0 for not a catch trial
%   Row 3: Coherence
%   Row 4: 1 for respMade 0 for no RespMade
%   Row 5: RT
%   Row 6: 1 for positive sign. -1 for negative sign.
historyMatrix = NaN(6,prealNum, blocks);

%updating first trial info into history matrix
historyMatrix(2, 1, :) = 0; %catch trials set to 0 for the first trial of each block
historyMatrix(3, 1, :) = initialCoherence; %initialCoherence set for first tiral of each block

%matrix for holding all the coherence values played for UPDown method of
%finding threshold
UPDCoherenceMat = zeros(prealNum, 1, blocks);
UPDCoherenceMat(1, :) = initialCoherence;

%% --------------------
% The Experimental Loop
%--------------------
for block = 1:blocks
    %updating block number in history matrix
    historyMatrix(1, :, block) = blockMatrix(block);
    
    %counter for how many trials have been played and how many threshold
    %trials there have been (n, how many non-catch trials there have been
    trial = 1;
    n = 1;
    
    %matrix to hold RTs for supraliminal catches
    supraRT = [];
    
    %variable to keep track if a response was made
    respMade = false;
    rt = 0;
    
    %--------------------
    % Initial Trial -  Need to do this first to get initial sign of run
    %--------------------
    if trial == 1
        %variable to keep track of when there is a reversal of step size.
        reverse = 0;
        %if first trial and block 1, present a start screen and wait for a key press.
        if block == 1
%              DrawFormattedText(window, 'Welcome to Allen''s Up-Down Transformed detection task. Press any key to begin.', 'center', 'center', white); %TIMING CODE 
%              Screen('Flip', window);
%              KbStrokeWait;
            %else if first trial and not block 1, present an interblock screen and wait for a key press
        elseif block ~= 1
%              DrawFormattedText(window, ['Finished Block #' num2str(block) - 1 '. Press any key to continue.'], 'center', 'center') %TIMING CODE 
%              Screen('Flip', window);
%              KbStrokeWait;
        end
        
        
        %Presenting Grey Annulus
        vbl = PresentStimulus(annulusTexture, window, 0, ifi, annulusTime(1), annulusTime(2), false, 0, 0, 0, rectCenter);
        
        timeStart = GetSecs; %TIMING CODE
        cueStart = GetSecs; %TIMING CODE
        
        %Presenting Cue
        if blockMatrix(1, block) == 1
            %Presenting pure visual cue
            PresentMoreEfficientAVStimulus(cueTexture, 'nullCue.wav', pahandle, 0, window, vbl, ifi, cueTime, 0, 0, 0, 0, 0, rectCenter);
        elseif blockMatrix(1, block) == 2
            %presenting pure audio cue
            PresentMoreEfficientAVStimulus(annulusTexture, 'auditoryCue.wav', pahandle, 0.5, window, vbl, ifi, cueTime, 0, 0, 0, 0, 0, rectCenter);
        elseif blockMatrix(1, block) == 3
            %presenting AV cue
            PresentMoreEfficientAVStimulus(cueTexture, 'auditoryCue.wav', pahandle, 0.5, window, vbl, ifi, cueTime, 0, 0, 0, 0, 0, rectCenter);
        end
        
        timesCue(trial, block) = (GetSecs - cueStart); %TIMING CODE
        timePreStim = GetSecs;%TIMING CODE
        
        %Presenting Pre-Stim Annulus
        vbl = PresentStimulus(annulusTexture, window, 0, ifi, preStimTime(1), preStimTime(2), false, 0, 0, 0, rectCenter);
        timesPreStim(trial, block) = GetSecs - timePreStim;%TIMING CODE
        
        %Getting Start Time and Presenting the Stimulus
        tStart = GetSecs;
        [vbl,respMade,rt]= PresentStimulus(texMat(trial, block), window, vbl, ifi, stimulusTime, 0, true, tStart, respMade, rt, rectCenter);
        timesStim(trial,block) = GetSecs - tStart;%TIMING CODE
        
        %Interstimulus window where participant can make a response about
        %the stimulus that was just played
        timeISI = GetSecs; %TIMING CODE
        [vbl,respMade,rt] = PresentStimulus(annulusTexture, window, vbl, ifi, annulusTime(1), annulusTime(2), true, tStart, respMade, rt, rectCenter);
        timesISI(trial, block) = GetSecs - timeISI; %TIMING CODE
        
        %saving response to respMatrix
        %stimulus #
        timePostP = GetSecs; %TIMING CODE
        respMatrix(1, trial, block) = stimMat(1, trial, block);
        %1 or 0 for whether or not a response was made
        if respMade == true
            respMatrix(2, trial, block) = 1;
            nonCatchMatrix(1, block) = 1;
            historyMatrix(4, trial, block) = 1;
        else
            respMatrix(2, trial, block) = 0;
            nonCatchMatrix(1, block) = 0;
            historyMatrix(4, trial, block) = 0;
        end
        
        %assigning rt
        respMatrix(3, trial, block) = rt;
        historyMatrix(5, trial, block) = rt;
        
        %Assigning sign of this trial. -1 for negative. +1 for positive
        if respMade == true
            sign(1, block) = -1;
            historyMatrix(6, trial, block) = -1;
            historyPRespMatrix(trial, block) = initialCoherence;
        elseif respMade == false
            historyNRespMatrix(trial, block) = initialCoherence;
            sign(1, block) = 1;
            historyMatrix(6, trial, block) = 1;
        end
        
        %update trial number. 
        timesPostP(trial, block) = GetSecs - timePostP; %TIMING CODE
        timesPresentation(trial, block) = (GetSecs - timeStart); %TIMING CODE  
        trial = trial + 1;
         
    end
    
    %--------------------
    % The Rest of the Trials
    %--------------------
    %while a response is made when the sign is negatve or a response is
    %not made when the sign is positive and trial number is greater than one. (While a response is not a reversal and greater than one)
    run = 1;
    while trial <= trials
        timeStart = GetSecs; %TIMING CODE
        %setting respMade to false
        respMade = false;
        
        %setting the contrast level for this trial (step size of
        %initialStep / trial#)
        step = initialStep/(n);
        
        %if this is a catch trial (determined randomly)
        if rand(1) <= catchFrequency
            
            if rand(1) <= subFrequency
                coherence = 0;
                %catchMat = 1 --> subliminal
                catchMat(trial, block) = 1;
                historyMatrix(2, trial, block) = 1;
            else
                %coherenceis equal to a random value between 0.5 and 1;
                coherence = rand(1)*0.5 + 0.5;
                %catchMat = 2 --> supraliminal
                catchMat(trial, block) = 2;
                historyMatrix(2, trial, block) = 2;
            end
            historyCatchMatrix(trial, block) = coherence;
        else
            historyMatrix(2, trial, block) = 0;
            %updating n: the ntrial number of all NON-Catch trials.
            n = n + 1;
            
            %calculating new coherence level if this is not a catch trial
            %based off of info from previous non-catch trials ONLY
            UPDCoherenceMat(n, block) = UPDCoherenceMat(n - 1, block) + (step * sign(n-1, block));
            if UPDCoherenceMat(n, block) < 0
                UPDCoherenceMat(n, block) = 0;
            elseif UPDCoherenceMat(n, block) > 1
                UPDCoherenceMat(n, block) = 1;   
            end
            coherence = UPDCoherenceMat(n, block);
        end
        stimMat(2, trial, block) = coherence;
        historyMatrix(3, trial, block) = coherence;
       
        %creating stimulus
        %loop to draw circle with different coherence values for each stimulus type
        %for each stim condition
        gabor = CreateGabor(gaborLength, sigma, lambda, 'r', 'r', A);
        gabor = EmbedInNoise(gabor, coherence, 0, gauss);
        visualMatrix(:, :, trial) = EmbedInApperature(gabor, 'c', animatedNoiseX, animatedNoiseY, 'n', 0.5);
        visualMatrix(:, :, trial) = EmbedInAnnulus(visualMatrix(:, :, trial), annulusWidth, annulusColor);
        
        %create texture and place into textureMatrix. textureMatrix will be
        %used by experimental loop to draw stimuli.
        noiseTexture = Screen('MakeTexture', window, visualMatrix(:,:,trial));
        texMat(trial, block) = noiseTexture;
        
        timesPreP(trial, block) = GetSecs - timeStart; %TIMING CODE
        cueStart = GetSecs; %TIMING CODE
        
        %Presenting Cue
        if blockMatrix(1, block) == 1
            %Presenting pure visual cue
            PresentMoreEfficientAVStimulus(cueTexture, 'nullCue.wav', pahandle, 0, window, vbl, ifi, cueTime, 0, 0, 0, 0, 0, rectCenter);
        elseif blockMatrix(1, block) == 2
            %presenting pure audio cue
            PresentMoreEfficientAVStimulus(annulusTexture, 'auditoryCue.wav', pahandle, 0.5, window, vbl, ifi, cueTime, 0, 0, 0, 0, 0, rectCenter);
        elseif blockMatrix(1, block) == 3,
            %presenting AV cue
            PresentMoreEfficientAVStimulus(cueTexture, 'auditoryCue.wav', pahandle, 0.5, window, vbl, ifi, cueTime, 0, 0, 0, 0, 0, rectCenter);
        end
        
         timesCue(trial, block) = (GetSecs - cueStart); %TIMING CODE
                
        %Presenting Pre-Stim Annulus
        timePreStim = GetSecs; %TIMING CODE
        vbl = PresentStimulus(annulusTexture, window, 0, ifi, preStimTime(1), preStimTime(2), false, 0, 0, 0, rectCenter);
        timesPreStim(trial, block) = GetSecs - timePreStim;%TIMING CODE
        
        %Getting Start Time and Presenting the Stimulus
        tStart = GetSecs;
        [vbl,respMade,rt]= PresentStimulus(texMat(trial, block), window, vbl, ifi, stimulusTime, 0, true, tStart, respMade, rt, rectCenter);
        timesStim(trial,block) = GetSecs - tStart;%TIMING CODE

        %Interstimulus window where participant can make a response about
        %the stimulus that was just played
        timeISI = GetSecs; %TIMING CODE
        [vbl,respMade,rt] = PresentStimulus(annulusTexture, window, vbl, ifi, annulusTime(1), annulusTime(2), true, tStart, respMade, rt, rectCenter);
        timesISI(trial, block) = GetSecs - timeISI; %TIMING CODE
        
        %saving response to respMatrix
        %stimulus #
        timePostP = GetSecs; %TIMING CODE
        respMatrix(1, trial, block) = stimMat(1, trial, block);
        
        %1 or 0 for whether or not a response was made
        if respMade == true
            respMatrix(2, trial, block) = 1;
            historyMatrix(4, trial, block) = 1;
            historyPRespMatrix(trial, block) = coherence;
            if catchMat(trial, block) == 0
                nonCatchMatrix(n, block) = 1;             
            end
        else
            respMatrix(2, trial, block) = 0;
            historyMatrix(4, trial, block) = 0;
            historyNRespMatrix(trial, block) = coherence;
            if catchMat(trial, block) == 0
                nonCatchMatrix(n, block) = 0;          
            end
        end
        
        %assigning rt
        respMatrix(3, trial, block) = rt;
        historyMatrix(5, trial, block) = rt;
        
        %If this is not a catch trial, check to see if the UpGroup or
        %DownGroup condition has been satisfied.
        reverse = 0;
        if catchMat(trial, block) == 0
            %Check if conditions are satisfied
            if sign(n - 1, block) == 1
                    %setting index to avoid nonpositive indices in matrices.
                    index = n-maxSizeDown + 1;
                    if index <= 0
                        index = 1;
                    end
                    for sequence = 1:size(downGroup,1)
                        
                        %setting conditionIndex to accomodate for NaNs in downGroup and upGroup
                        conditionIndex = downStartingIndex(sequence);
                        
                        %to account for first few trials, in which nonCatchMatrix 's size is less than the number of stimuli in the up/down Group
                        if size(index + (conditionIndex-1):n) < maxSizeDown
                            %do nothing
                        elseif nonCatchMatrix(index + (conditionIndex-1):n, block) == (downGroup(sequence, conditionIndex:end)')
                            reverse = 1;
                        end
                        
                    end
            elseif sign(n - 1, block) == -1
                %setting index to avoid nonpositive indices in matrices.
                index = n-maxSizeUp + 1;
                if index <= 0
                    index = 1;
                end 
                for sequence = 1:size(upGroup,1)
                    %setting conditionIndex to accomodate for NaNs in downGroup and upGroup
                    conditionIndex = upStartingIndex(sequence);     
                    if size(nonCatchMatrix(index + (conditionIndex-1):n, block), 1) < maxSizeUp
                        %do nothing
                    elseif nonCatchMatrix(index + (conditionIndex-1):n, block) == (upGroup(sequence, conditionIndex:end)')
                        reverse = 2;
                    end
                end
            end
            
            if reverse > 0
                pvMatrix(trial, block) = coherence;
                run = run + 1;
            end
        elseif catchMat(trial,block) == 2
            supraRT = [supraRT rt];
        end
        

        %Assigning sign. True for negative. False for positive IF this is
        %not a catch trial
        if catchMat(trial, block) == 0
            %reversal is a downgroup
            if reverse == 1
                sign(n, block) = -1;
                historyMatrix(6, trial, block) = -1;
            %reversal is an upgroup
            elseif reverse == 2
                sign(n, block) = 1;
                historyMatrix(6, trial, block) = 1;
            else
                sign(n, block) = sign(n - 1, block);
                historyMatrix(6, trial, block) = sign(n - 1, block);
            end
        end
        
        timesPresentation(trial, block) = (GetSecs - timeStart); %TIMING CODE 
        timesPostP(trial,block) = GetSecs - timePostP; %TIMING CODE       
        trial = trial + 1;
    end

%Calculating psychometric threshold using Wetherill method
numReversals = 0;
for i = 1:numel(pvMatrix(:,block))
    if ~isnan(pvMatrix(i, block))
        numReversals = numReversals + 1;
    end
end

psychThresh(block) = nansum(pvMatrix(:,block)) / numReversals;
blockMatrix(2, block) = psychThresh(block);
blockMatrix(3, block) = mean(supraRT);


% DrawFormattedText(window, 'Block Finished! Press any key to continue.','center', 'center', white, window); %TIMING CODE
% Screen('Flip', window);
% KbStrokeWait;
%
% %--------------------
% % Plotting Run History %TIMING CODE
% %--------------------
% figure();
% 
% 
% %setting dimmensions of plot
% set(gca, 'xlim', [0 trial], 'ylim', [0 1]);
% 
% %plotting
% %turning on hold
% hold on;
% plot(1:prealNum, historyPRespMatrix(:, block),'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
% plot(1:prealNum, historyNRespMatrix(:, block),'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
% plot(1:prealNum, historyCatchMatrix(:, block),'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'none');
% title(['Block #' num2str(block)]);
% 
% 
 end


%end of experiment screen
PsychPortAudio('Close', pahandle);
DrawFormattedText(window, 'Experiment Finished! Press any key to exit.','center', 'center', white, window);
Screen('Flip', window);

%closes all the windows upon key press
KbStrokeWait;
sca;

%% ------------------
%  Calculating Averages on times Matrices %TIMING CODE
%--------------------
        timesCue(trials + 1, :) = NaN(1, blocks);
        timesCue(trials + 2, :) = mean(timesCue(1:trials, :));
        timesCue(trials + 3, :) = std(timesCue(1:trials, :));
        
        timesISI(trials + 1, :) = NaN(1, blocks);
        timesISI(trials + 2, :) = mean(timesISI(1:trials, :));
        timesISI(trials + 3, :) = std(timesISI(1:trials, :));
        
        timesPostP(trials + 1, :) = NaN(1, blocks);
        timesPostP(trials + 2, :) = mean(timesPostP(1:trials, :));
        timesPostP(trials + 3, :) = std(timesPostP(1:trials, :));
        
        timesPreP(trials + 1, :) = NaN(1, blocks);
        timesPreP(trials + 2, :) = mean(timesPreP(1:trials, :));
        timesPreP(trials + 3, :) = std(timesPreP(1:trials, :));
        
        timesPreSTim(trials + 1, :) = NaN(1, blocks);
        timesPreStim(trials + 2, :) = mean(timesPreStim(1:trials, :));
        timesPreStim(trials + 3, :) = std(timesPreStim(1:trials, :));
        
        timesPresentation(trials + 1, :) = NaN(1, blocks);
        timesPresentation(trials + 2, :) = mean(timesPresentation(1:trials, :));
        timesPresentation(trials + 3, :) = std(timesPresentation(1:trials, :));
        
        timesStim(trials + 1, :) = NaN(1, blocks);
        timesStim(trials + 2, :) = mean(timesStim(1:trials, :));
        timesStim(trials + 3, :) = std(timesStim(1:trials, :));
%% ------------------
% SAVING DATA
%--------------------
%filesaving
filepath = 'C:\Users\lhshaw\Desktop\Psychophysics DATA';
filename = [participant '_timing' '.mat']; %TIMING CODE: remove '_timing'

save(fullfile(filepath, filename), 'timesCue','timesISI', 'timesPostP', 'timesPreP', 'timesPreStim', 'timesPresentation', 'timesStim');

