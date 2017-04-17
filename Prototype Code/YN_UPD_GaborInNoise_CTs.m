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
sign = zeros(1,prealNum,blocks);

%catch trial information
catchFrequency = 0.5; %what percentage of the trials will be catch trials
subFrequency = 0.5; %what percentage of the catch trials will be subliminal (0% coherence). assuming supraFrequency is 1-subFrequency

%matrix for holding
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

%matrix for holding all the coherence values played for UPD method of
%finding threshold
UPDCoherenceMat = zeros(prealNum, 1);
%Putting noise in gabor
UPDCoherenceMat(1) = initialCoherence;

%--------------------
% Timing Information
%--------------------
%Generating interstimulus interval matrices between 1200 - 3400 ms
isiTimeSecs = (1200 + 2200 * rand(blocks, prealNum)) /1000;
isiTimeFrames = round(isiTimeSecs ./ ifi);

%Generating intrastimulus interval matrices of 50 ms (how long stimullus
%is being played
stimulusTimeSecs = repmat(.03, blocks, prealNum);
stimulusTimeFrames = round(stimulusTimeSecs ./ ifi);

%Generating prestimulus presentation interval when fixation cross
%dissapears (randomly between 500 - 1000 ms)
psiTimeSecs = (500 + 500 * rand(blocks, prealNum)) /1000;
psiTimeFrames = round(psiTimeSecs ./ ifi);

%Generating post-stimulus presentation interval when fixation cross
%dissapears (randomly between 750 ms)
postSITimeSecs = repmat(.75, blocks, prealNum);
postSITimeFrames = round(postSITimeSecs ./ ifi);

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
%--------------------
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
        vbl = PresentFixationCross(window, 0, ifi, white, 1000, 0, 0, 0, 0);
        
        %Removing fixation cross
        vbl = PresentBlankScreen(window, vbl, ifi, grey, 1000, 2400, 0, 0, 0);
        
        %Getting Start Time and Presenting the Stimulus
        tStart = GetSecs;
        [vbl,respMade,rt]= PresentStimulus(texMat(1), window, vbl, ifi, 60, 0, true, tStart, respMade, rectCenter);
        
        %Removing Stimulus
        [vbl,respMade,rt] = PresentBlankScreen(window, vbl, ifi, grey, 1000, 0, true, tStart, respMade);
               
        %Interstimulus window where participant can make a response about
        %the stimulus just played
        [vbl,respMade,rt] = PresentFixationCross(window, vbl, ifi, white, 1000, 0, true, tStart, respMade);
        
        %saving response to respMatrix
        %stimulus #
        respMatrix(1, trial, block) = stimMat(1, trial, block);
        %1 or 0 for whether or not a response was made
        if respMade == true
            respMatrix(2, trial, block) = 1;
        else
            respMatrix(2, trial, block) = 0;
        end
        
        %assigning rt
        respMatrix(3, trial, block) = rt;
        
        %Assigning sign of this trial. -1 for negative. +1 for positive
        if respMade == true
            sign(1, block) = -1;
        elseif respMade == false
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
        
        %Presenting Fixation Cross
        vbl = PresentFixationCross(window, 0, ifi, white, 1000, 0, 0, 0, 0);
        
        %Removing fixation cross
        vbl = PresentBlankScreen(window, vbl, ifi, grey, 1000, 2400, 0, 0, 0);
        
        %Getting Start Time and Presenting the Stimulus
        tStart = GetSecs;
        [vbl,respMade,rt]= PresentStimulus(texMat(trial), window, vbl, ifi, 60, 0, true, tStart, respMade, rectCenter);
        
        %Removing Stimulus
        [vbl,respMade,rt] = PresentBlankScreen(window, vbl, ifi, grey, 1000, 0, true, tStart, respMade);
               
        %Interstimulus window where participant can make a response about
        %the stimulus just played
        [vbl,respMade,rt] = PresentFixationCross(window, vbl, ifi, white, 1000, 0, true, tStart, respMade);
        
        %if this response is a reversal, assign coherence level to
        %peaks and valley Mat and mark as reversal and run++
        if catchMat(trial) == 0
            if (respMade == true && sign(n - 1) == 1)|| (respMade == false && sign(n - 1) == -1)
                pvMatrix(trial, block) = coherence;
                reverse = 1;
                run = run + 1;
            end
        end
        
        %saving response to respMatrix
        %stimulus #
        respMatrix(1, trial, block) = stimMat(1, trial, block);
        
        %1 or 0 for whether or not a response was made
        if respMade == true
            respMatrix(2, trial, block) = 1;
        else
            respMatrix(2, trial, block) = 0;
        end
        
        %assigning rt
        respMatrix(3, trial, block) = rt;
        
        %Assigning sign. True for negative. False for positive IF this is
        %not a catch trial
        if catchMat(trial) == 0
            if respMade == true
                sign(n, block) = -1;
            elseif respMade == false
                sign(n, block) = 1;
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

%--------------------
% Plotting Run History
%--------------------

%turning on hold
hold on;

%setting dimmensions of plot
set(gca, 'xlim', [0 trial], 'ylim', [0 1]);

%creating matrices to plot
positives = stimMat(2, 1:trial, block);
negatives = positives;
supras = positives;
subs = positives;


for t =1:trial
    %looping through positives and negatives matrix and setting all negative responses to
    %NaN in positives and all pos responses to NaN in negatives
    if respMatrix(2, t, block) == 0 || catchMat(t) ~= 0
        positives(t) = NaN;
    elseif respMatrix(2, t, block) == 1 || catchMat(t) ~= 0
        negatives(t) = NaN;
    end
    
    %looping through supras and subs matrix and setting all non-supra
    %stimuli to NaN in supras and all non-sub stimuli in subs NaN
    if catchMat(t) ~= 1
        subs(t) = NaN;
    end 
    if catchMat(t) ~= 2
        supras(t) = NaN;
    end 
    
end
%plotting
trialHistory = plot(1:trial-1, positives(1:end-1), 1:trial-1, negatives(1:end-1), 1:trial-1, subs(1:end-1), 1:trial-1, supras(1:end-1), 'LineStyle', 'none');
%setting positives to have + symbol and negatives to have - symbol
trialHistory(1).Marker = 'o';
trialHistory(1).MarkerFaceColor = 'g';
trialHistory(1).MarkerEdgeColor = 'g';

trialHistory(2).Marker = 'o';
trialHistory(2).MarkerFaceColor = 'r';
trialHistory(2).MarkerEdgeColor = 'r';

trialHistory(3).Marker = 'o';
trialHistory(3).MarkerFaceColor = 'b';
trialHistory(3).MarkerEdgeColor = 'b';

trialHistory(4).Marker = 'o';
trialHistory(4).MarkerFaceColor = 'b';
trialHistory(4).MarkerEdgeColor = 'b';
