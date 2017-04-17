%Yes-No Up-Down. Press any key to say that there is a stimulus. 

%Step Size = c/n, c = initial step size, n = trial number. Step size
%shrinks as experiment progresses

%Termination after set number of runs (# reversals)

%Threshold calculated via Wetherill method. Average of all peaks and
%valleys (coherence value at every reversal). 

%--------------------
% Initial Set-up Stuff
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
% Experiment Params
%--------------------
%number of blocks
blocks = 1;

%number of reversals/runs
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
sign = zeros(prealNum, 1);

%matrix for holding the the UPD TRANSFORMED UpGroup and DownGroup. StartingIndex Matrices for holding what index to start checking from (used to accomodate for NaN's)
upGroup = [[NaN 0 0]; [0 1 0]; [1 0 0];];
upStartingIndex = [2, 1, 1];
downGroup = [[NaN 1 1];[1 0 1];[0 1 1];];
downStartingIndex = [2, 1, 1];

%Maximum number of elements per upGroup and downGroup. 
maxSizeUp = 3;
maxSizeDown = 3;

%catch trial information
catchFrequency = 0; %what percentage of the trials will be catch trials
subFrequency = 0.5; %what percentage of the catch trials will be subliminal (0% coherence). assuming supraFrequency is 1-subFrequency

%initializing catchMat, the matrix that holds data about which trials are
%catch trials, and what type of trial. 
catchMat = zeros(prealNum,1);

%--------------------
% Stimuli Params
%--------------------
%apperture window properties
appX = 300; %app size
appY = 300;
appXCenter = appX/2;
appYCenter = appY/2;
appRadius = appX/2;

%gabor stimulus properties
stimLength = 150;
stimRadius = stimLength/2;
stimXPos = appXCenter/2;
stimYPos = appYCenter/2;
lambda = 50; %wavelegnth (number of pixels per cycle)
sigma = 50; %gaussian standard deviation in pixels
imSize = stimLength;
X0 = 1:imSize;                          
X0 = (X0 / imSize) - .5;                 
[Xm Ym] = meshgrid(X0, X0);
s = sigma/imSize;
gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)));
A = 0.75; %amplitude variable

%Creating stimuli #1
gaborMat = zeros(appY, appX, prealNum);  %matrix containing pixel values for the texture being created. Expands to hold pixel values of all stimuli
gabor = CreateGabor(stimLength, sigma, lambda, 'r', 'r', A);
gabor = EmbedInNoise(gabor, initialCoherence, 1, gauss);
gaborMat(:, :, 1) = EmbedInApperature(gabor, 'c', appX, appY, 'n', 0.5);

%defining area the texture will be displayed
xPos = xCenter;
yPos = yCenter;
baseRect = [0 0 appX appY];

%Centering texture in center of window
rectCenter = CenterRectOnPointd(baseRect, xPos, yPos);

%create texture and place into textureMatrix. textureMatrix will be
%used by experimental loop to draw stimuli.
noiseTexture = Screen('MakeTexture', window, gaborMat(:,:,1));
texMat(1) = noiseTexture;

%matrix for holding all the coherence values played for UPDown method of
%finding threshold
UPDCoherenceMat = zeros(prealNum, 1);
UPDCoherenceMat(1) = initialCoherence;

%--------------------
% Timing Information
%--------------------
%Fixation Cross Interval (in ms)
fixationTime = 1000; 

%Cue Time (in ms)
cueTime = [1000 2400];

%Stimulus Presentation Time (in ms)
stimulusTime = 60;

%Post-Stimulus blank screen time (im ms)
postTime = fixationTime;

%Number of frames to wait before re-drawing
waitframes = 1;

%--------------------
% The Response Matrix
%--------------------
%3D matrix. Row 1 - stimulus Coherence . Row 2 - 1 or 0 for detected or not. Row
%3 - RT if detected. 0 if not detected. Each column is an individual
%stimulus presentation. Third dimmension is block number
respMatrix = nan(3, prealNum, blocks);

%matrix to hold all peaks and valleys of the psychometric function
%(coherence values where a reversal happened)
pvMatrix = zeros(runs + 2,blocks);

%matrix to hold all non-catch trial responses
nonCatchMatrix = zeros(prealNum, 1);

%index value matrix to hold index values of different types of responses
indexPRespMatrix = [];
indexNRespMatrix = [];
indexPRevMatrix = [];
indexNRevMatrix = [];
indexCatchMatrix = [];

%% --------------------
% The Experimental Loop
%--------------------
for block = 1:blocks
    %counter for how many trials have been played and how many threshold
    %trials there have been (n, how many non-catch trials there have been
    trial = 1;
    n = 1;
    
    %variable to keep track if a response was made
    respMade = false;
 
    %--------------------
    % Initial Trial -  Need to do this first to get initial sign of run
    %--------------------
    if trial == 1
        %variable to keep track of when there is a reversal of step size.
        reverse = 0;
        %if first trial and block 1, present a start screen and wait for a key press.
        if block == 1
            DrawFormattedText(window, 'Welcome to Allen''s Up-Down Transformed detection task. Press any key to begin.', 'center', 'center', white);
            Screen('Flip', window);
            KbStrokeWait;
            %else if first trial and not block 1, present an interblock screen and wait for a key press
        elseif block ~= 1
            DrawFormattedText(window, ['Finished Block #' num2str(block) - 1 '. Press any key to continue.'], 'center', 'center')
            Screen('Flip', window);
            KbStrokeWait;
        end
        
        %Presenting Fixation Cross
        vbl = PresentFixationCross(window, 0, ifi, white, fixationTime, 0, 0, 0, 0);
        
        %Presenting Cue
        vbl = PresentBlankScreen(window, vbl, ifi, grey, cueTime(1), cueTime(2), 0, 0, 0);
        
        %Getting Start Time and Presenting the Stimulus
        tStart = GetSecs;
        [vbl,respMade,rt]= PresentStimulus(texMat(1), window, vbl, ifi, stimulusTime, 0, true, tStart, respMade, rectCenter);
        
        %Removing Stimulus
        [vbl,respMade,rt] = PresentBlankScreen(window, vbl, ifi, grey, postTime, 0, true, tStart, respMade);
               
        %Interstimulus window where participant can make a response about
        %the stimulus just played
        [vbl,respMade,rt] = PresentFixationCross(window, vbl, ifi, white, fixationTime, 0, true, tStart, respMade);
        
        %saving response to respMatrix
        %stimulus #
        respMatrix(1, trial, block) = stimMat(1, trial, block);
        %1 or 0 for whether or not a response was made
        if respMade == true
            respMatrix(2, trial, block) = 1;
            nonCatchMatrix(1) = 1;
        else
            respMatrix(2, trial, block) = 0;
            nonCatchMatrix(1) = 0;
        end
        
        %assigning rt
        respMatrix(3, trial, block) = rt;
        
        %Assigning sign of this trial. -1 for negative. +1 for positive
        if respMade == true
            sign(1, block) = -1;
            indexPRespMatrix =[indexPRespMatrix trial];
        elseif respMade == false
            indexNRespMatrix =[indexNRespMatrix trial];
            sign(1, block) = 1;
        end
        
        %update trial number. 
        trial = trial + 1;
    end
    
    %--------------------
    % The Rest of the Trials
    %--------------------
    %while a response is made when the sign is negatve or a response is
    %not made when the sign is positive and trial number is greater than one. (While a response is not a reversal and greater than one)
    run = 1;
    while run <= runs
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
                catchMat(trial) = 1;
                indexCatchMatrix = [indexCatchMatrix trial];
            else
                %coherenceis equal to a random value between 0.5 and 1; 
                coherence = rand(1)*0.5 + 0.5; 
                %catchMat = 2 --> supraliminal
                catchMat(trial) = 2;
            end 
        else 
            %updating n: the ntrial number of all NON-Catch trials. 
            n = n + 1;
            
            %calculating new coherence level if this is not a catch trial
            %based off of info from previous non-catch trials ONLY
            UPDCoherenceMat(n) = UPDCoherenceMat(n - 1) + (step * sign(n-1));
            if UPDCoherenceMat(n) < 0
                UPDCoherenceMat(n) = 0;
            elseif UPDCoherenceMat(n) > 1
                UPDCoherenceMat(n) = 1;   
            end
            coherence = UPDCoherenceMat(n);
        end
        stimMat(2, trial, block) = coherence;
       
        %creating stimulus
        %loop to draw circle with different coherence values for each stimulus type
        %for each stim condition
        gabor = CreateGabor(stimLength, sigma, lambda, 'r', 'r', A);
        gabor = EmbedInNoise(gabor, coherence, 1, gauss);
        gaborMat(:, :, trial) = EmbedInApperature(gabor, 'c', appX, appY, 'n', 0.5);
        
        %create texture and place into textureMatrix. textureMatrix will be
        %used by experimental loop to draw stimuli.
        noiseTexture = Screen('MakeTexture', window, gaborMat(:,:,trial));
        texMat(trial) = noiseTexture;
               
        %Presenting Cue: red fixation cross
        vbl = PresentBlankScreen(window, vbl, ifi, grey, cueTime(1), cueTime(2), 0, 0, 0);
        
        %Getting Start Time and Presenting the Stimulus
        tStart = GetSecs;
        [vbl,respMade,rt]= PresentStimulus(texMat(trial), window, vbl, ifi, stimulusTime, 0, true, tStart, respMade, rectCenter);
        
        %Removing Stimulus: Post-Stimulus interval. Participant can make response.
        [vbl,respMade,rt] = PresentBlankScreen(window, vbl, ifi, grey, postTime, 0, true, tStart, respMade);
        
        %Interstimulus window where participant can make a response about
        %the stimulus that was just played
        [vbl,respMade,rt] = PresentFixationCross(window, vbl, ifi, white, fixationTime, 0, true, tStart, respMade);
        
        %saving response to respMatrix
        %stimulus #
        respMatrix(1, trial, block) = stimMat(1, trial, block);
        
        %1 or 0 for whether or not a response was made
        if respMade == true
            respMatrix(2, trial, block) = 1;
            indexPRespMatrix = [indexPRespMatrix trial];
            if catchMat(trial) == 0
                nonCatchMatrix(n) = 1;             
            end
        else
            respMatrix(2, trial, block) = 0;
            indexNRespMatrix = [indexNRespMatrix trial];
            if catchMat(trial) == 0
                nonCatchMatrix(n) = 0;          
            end
        end
        
        %assigning rt
        respMatrix(3, trial, block) = rt;
        
        
        %If this is not a catch trial, check to see if the UpGroup or
        %DownGroup condition has been satisfied.
        reverse = 0;
        if catchMat(trial) == 0
            %Check if conditions are satisfied
            if sign(n - 1) == 1
                    %setting index to avoid nonpositive indices in matrices.
                    index = n-maxSizeDown + 1;
                    if index <= 0
                        index = 1;
                    end
                    for sequence = 1:size(downGroup,1)
                        
                        %setting conditionIndex to accomodate for NaNs in downGroup and upGroup
                        conditionIndex = downStartingIndex(sequence);
                        
                        %to account for first few trials, in which nonCatchMatrix 's size is less than the number of stimuli in the up/down Group
                        
                        nonCatchMatrix(index + (conditionIndex-1):n) %DEBUGGING CODE
                        downGroup(sequence, conditionIndex:end)' %DEBUGGING CODE
                        disp('------------------------------------------')
                        if size(index + (conditionIndex-1):n) < maxSizeDown
                            %do nothing
                        elseif nonCatchMatrix(index + (conditionIndex-1):n) == (downGroup(sequence, conditionIndex:end)')
                            reverse = 1;
                            reverse
                        end
                        
                    end
            elseif sign(n - 1) == -1
                %setting index to avoid nonpositive indices in matrices.
                index = n-maxSizeUp + 1;
                if index <= 0
                    index = 1;
                    end 
                for sequence = 1:size(upGroup,1)
                    %setting conditionIndex to accomodate for NaNs in downGroup and upGroup
                    conditionIndex = upStartingIndex(sequence);     
                    nonCatchMatrix(index + (conditionIndex-1):n) %DEBUGGING CODE
                    upGroup(sequence, conditionIndex:end)' %DEBUGGING CODE
                    disp('------------------------------------------')
                    if size(nonCatchMatrix(index + (conditionIndex-1):n)) < maxSizeUp
                        %do nothing
                    elseif nonCatchMatrix(index + (conditionIndex-1):n) == (upGroup(sequence, conditionIndex:end)')
                        reverse = 2;
                        reverse
                    end
                end
            end
            
            if reverse > 0
                pvMatrix(trial, block) = coherence;
                run = run + 1;
            end
        end
        

        %Assigning sign. True for negative. False for positive IF this is
        %not a catch trial
        if catchMat(trial) == 0
            %reversal is a downgroup
            if reverse == 1
                sign(n, block) = -1;
                indexNRevMatrix = [indexNRevMatrix trial];
            %reversal is an upgroup
            elseif reverse == 2
                sign(n, block) = 1;
                indexPRevMatrix = [indexPRevMatrix trial];
            else
                sign(n, block) = sign(n - 1, block);
                if sign(n, block) == 1
                    indexPRevMatrix = [indexPRevMatrix trial];
                elseif sign(n, block) == -1
                    indexNRevMatrix = [indexNRevMatrix trial];
                end
            end
        end
        
        trial = trial + 1;
    end


end

%Calculating psychometric threshold using Wetherill method
psychThresh = zeros(blocks);
numReversals = 0;
for i = 1:numel(pvMatrix(:,block))
    if pvMatrix(i, block) ~= 0
        numReversals = numReversals + 1;
    end
end

psychThresh(block) = sum(pvMatrix(:,block)) / numReversals;
%end of experiment screen
DrawFormattedText(window, ['Experiment Finished! Press any key to exit. \nYour psychometric threshold is: ' num2str(psychThresh)], 'center', 'center', white, window);
Screen('Flip', window);

%closes all the windows upon key press
KbStrokeWait;
close all;
sca;

%% --------------------
% Plotting Run History
%--------------------

%turning on hold
hold on;

%setting dimmensions of plot
set(gca, 'xlim', [0 trial], 'ylim', [0 1]);

%plotting
%trialHistory = plot(indexPRespMatrix, stimMat(2, indexPRespMatrix), indexNRespMatrix, stimMat(2, indexNRespMatrix), indexPRevMatrix, stimMat(2, indexPRevMatrix), indexNRevMatrix, stimMat(2, indexNRevMatrix), indexCatchMatrix, stimMat(2,indexCatchMatrix),'LineStyle', 'none');
trialHistory = plot(indexPRespMatrix, stimMat(2, indexPRespMatrix),'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'g');
trialHistory = plot(indexNRespMatrix, stimMat(2, indexNRespMatrix),'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'r');

%setting positives to have + symbol and negatives to have - symbol ;

% 
% trialHistory(3).Marker = 'o';
% trialHistory(3).MarkerFaceColor = 'g';
% trialHistory(3).MarkerEdgeColor = 'none';
% 
% trialHistory(4).Marker = 'o';
% trialHistory(4).MarkerFaceColor = 'r';
% trialHistory(4).MarkerEdgeColor = 'none';
% 
% trialHistory(5).Marker = 'o';
% trialHistory(5).MarkerFaceColor = 'b';
% trialHistory(5).MarkerEdgeColor = 'none';
