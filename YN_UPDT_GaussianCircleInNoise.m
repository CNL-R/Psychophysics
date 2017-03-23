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
initialStep = 0.25;

%initial stimulus coherence value
initialCoherence = 1;

%preallocated number of trials per block
prealNum = 100;

%matrix for storing trial number and coherence value for that stimulus.
%Initially set to length 'prealNum' for pre-allocation
% 1 - trialNum
% 2 - stimCoherence
stimMat = repmat(1:prealNum, 1, 1, blocks);
stimMat(2,:,:) = 0;
stimMat(2,1,:) = initialCoherence;

%sign vector to hold sign of runs
sign = zeros(1,prealNum,blocks);

%--------------------
% Stimuli Params
%--------------------
%apperture window properties
appX = 300; %app size
appY = 300;
appXCenter = appX/2;
appYCenter = appY/2;
appRadius = appX/2;

%circle stimulus properties
stimRadius = 100;
stimXPos = appXCenter;
stimYPos = appYCenter;
stimColor = white;

%Matrix to hold textures
texMat = zeros(prealNum, blocks);

%defining appMat as random noise within a circle centered in
%apperture with radius appX/2
appMat = repmat(grey, appY, appX);
for y = 1:appY
    for x = 1:appX
        %if pixel is in circle defined by (x-appXCenter)^2 + (y -
        %appYCenteR)^2 < appRadius^2
        if ((x - appXCenter)^2 + (y - appYCenter)^2) < appRadius^2
            %set value to noise values between 0 and 1
            appMat(y,x) = rand(1);
        end
    end
end


%defining area the texture will be displayed
xPos = xCenter;
yPos = yCenter;
baseRect = [0 0 appX appY];

%Centering texture in center of window
rectCenter = CenterRectOnPointd(baseRect, xPos, yPos);

%Gaussian window properties
imSize = appX;
X0 = 1:imSize;                          
X0 = (X0 / imSize) - .5;                 
[Xm Ym] = meshgrid(X0, X0);
sigma = 15;
s = sigma/imSize;
gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)) );

%Drawing the stimulus for trial 1
windowMat = appMat;
for y = 1:appY
    for x = 1:appX
        %if pixel is within the circle that defines the size of our dot
        %stimulus
        if ((x - stimXPos)^2 + (y - stimYPos)^2) < stimRadius^2
           
         
            %coherence % chance to set pixelValue to stimColor
            if rand(1) <= stimMat(2,1, blocks)  * gauss(y, x);
                windowMat(y,x) = stimColor;
            end

        end
    end
end
%create texture and place into textureMatrix. textureMatrix will be
%used by experimental loop to draw stimuli.
noiseTexture = Screen('MakeTexture', window, windowMat);
texMat(1) = noiseTexture;

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
    %counter for how many trials have been played
    trial = 1;
    
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
        
        %Play fixation cross
        DrawFormattedText(window, '+', 'center', 'center', white);
        vbl = Screen('Flip', window);
        
        %Play fixation cross for the rest of the presentation interval (-1
        %frame because we played the fixation point at frame 1)
        for frame = 1:isiTimeFrames(block, trial) - 1
            
            %Draw fixation point
            DrawFormattedText(window, '+', 'center', 'center', white);
            
            %Flip to screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end
        
        %Removing fixation cross
        for frame =1:psiTimeFrames(block, trial)
            Screen('FillRect', window, grey);
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end
        
        %Getting start time and drawing stimulus
        tStart = GetSecs;
        Screen('DrawTextures', window, texMat(trial, block), [], rectCenter, [], [], [], []);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        %Play stimulus patch for the rest of the presentation interval (-1
        %frame because we played the fixation point at frame 1)
        for frame = 1:stimulusTimeFrames(block, trial) - 1
            %Drawing Texture
            Screen('DrawTextures', window, texMat(trial,block), [], rectCenter, [], [], [], []);
            
            %flipping to screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            
            %detecting response
            KeyIsDown = KbCheck;
            if KeyIsDown == 1
                respMade = true;
                tEnd = GetSecs;
                rt = tEnd - tStart;
            end
        end
        
        %Clearing stimulus for post Stimulus interval
        for frame =1:postSITimeFrames(block, trial)
            Screen('FillRect', window, grey);
            vbl = Screen('Flip', window);
            
            %detecting response
            KeyIsDown = KbCheck;
            if KeyIsDown == 1
                respMade = true;
                tEnd = GetSecs;
                rt = tEnd - tStart;
            end
        end
        
        %Interstimulus window where participant can make a response about
        %the stimulus just played
        DrawFormattedText(window, '+', 'center', 'center', white);
        vbl = Screen('Flip', window);
        
        %Play fixation point for the rest of the presentation interval (-1
        %frame because we played the fixation point at frame 1)
        for frame = 1:isiTimeFrames(block, trial) - 1
            
            %Draw fixation point
            DrawFormattedText(window, '+', 'center', 'center', white);
            
            %Flip to screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            
            %detecting response
            KeyIsDown = KbCheck;
            if KeyIsDown == 1
                respMade = true;
                tEnd = GetSecs;
                rt = tEnd - tStart;
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
        
        %RT if resp made or 0 if no resp made
        if respMade == true
            respMatrix(3, trial, block) = rt;
        else
            respMatrix(3, trial, block) = 0;
        end
        
        %Assigning sign. True for negative. False for positive
        if respMade == true
            sign(1, block) = -1;
        elseif respMade == false
            sign(1, block) = 1;
        end
        
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
        step = initialStep/trial;
        newCoherence = stimMat(2,trial-1,block) + (step * sign(trial - 1));
        if newCoherence < 0
            newCoherence = 0;
        elseif newCoherence > 1
            newCoherence = 1;
        end
        stimMat(2, trial, block) = newCoherence;
        %creating stimulus
        %loop to draw circle with different coherence values for each stimulus type
        %for each stim condition
        
        windowMat = appMat;
        %Drawing circle into noise
        for y = 1:appY
            for x = 1:appX
                %if pixel is within the circle that defines the size of our dot
                %stimulus
                if ((x - stimXPos)^2 + (y - stimYPos)^2) < stimRadius^2
                    %coherence % chance to set pixelValue to stimColor
                    if rand(1) <= stimMat(2,trial,block) * gauss(y, x);
                        windowMat(y,x) = stimColor;
                    end
                end
            end
        end
        %create texture and place into textureMatrix. textureMatrix will be
        %used by experimental loop to draw stimuli.
        noiseTexture = Screen('MakeTexture', window, windowMat);
        texMat(trial) = noiseTexture;
        
        %Play fixation cross
        DrawFormattedText(window, '+', 'center', 'center', white);
        vbl = Screen('Flip', window);
        
        %Play fixation cross for the rest of the presentation interval (-1
        %frame because we played the fixation point at frame 1)
        for frame = 1:isiTimeFrames(block, trial) - 1
            
            %Draw fixation point
            DrawFormattedText(window, '+', 'center', 'center', white);
            
            %Flip to screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end
        
        %Removing fixation cross
        for frame =1:psiTimeFrames(block, trial)
            Screen('FillRect', window, grey);
            vbl = Screen('Flip', window);
        end
        
        %Getting start time and drawing stimulus
        tStart = GetSecs;
        Screen('DrawTextures', window, texMat(trial), [], rectCenter, [], [], [], []);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        %Play stimulus patch for the rest of the presentation interval (-1
        %frame because we played the fixation point at frame 1)
        for frame = 1:stimulusTimeFrames(block, trial) - 1
            %Drawing Texture
            Screen('DrawTextures', window, texMat(trial), [], rectCenter, [], [], [], []);
            
            %flipping to screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            
            %detecting response
            KeyIsDown = KbCheck;
            if KeyIsDown == 1
                respMade = true;
                tEnd = GetSecs;
                rt = tEnd - tStart;
            end
        end
        
        %Clearing stimulus for post stimulus interval Frames. 
        for frame =1:postSITimeFrames(block, trial)
            Screen('FillRect', window, grey);
            vbl = Screen('Flip', window);
            
            %detecting response
            KeyIsDown = KbCheck;
            if KeyIsDown == 1
                respMade = true;
                tEnd = GetSecs;
                rt = tEnd - tStart;
            end
        end
        
        %Interstimulus window where participant can make a response about
        %the stimulus just played
        DrawFormattedText(window, '+', 'center', 'center', white);
        vbl = Screen('Flip', window);
        
        %Play fixation point for the rest of the presentation interval (-1
        %frame because we played the fixation point at frame 1)
        for frame = 1:isiTimeFrames(block, trial) - 1
            
            %Draw fixation point
            DrawFormattedText(window, '+', 'center', 'center', white);
            
            %Flip to screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            
            %detecting response
            KeyIsDown = KbCheck;
            if KeyIsDown == 1
                respMade = true;
                tEnd = GetSecs;
                rt = tEnd - tStart;
            end
            
        end
        
        %if this response is a reversal, assign coherence level to
        %peaks and valley Mat and mark as reversal
        if respMade == (true && sign(trial - 1) == 1)|| (respMade == false && sign(trial - 1) == -1)
            pvMatrix(trial, block) = newCoherence;
            reverse = 1;
            run = run + 1;
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
        
        %RT if resp made or 0 if no resp made
        if respMade == true
            respMatrix(3, trial, block) = rt;
        else
            respMatrix(3, trial, block) = 0;
        end
        
        %Assigning sign. True for negative. False for positive
        if respMade == true
            sign(trial, block) = -1;
        elseif respMade == false
            sign(trial, block) = 1;
        end
        
        trial = trial + 1;
        
    end

    %Calculating psychometric threshold using Wetherill method
    psychThresh = zeros(blocks);
    psychThresh(block) = sum(pvMatrix(:,block)) / numel(pvMatrix(:,block));
    
    %plotting run history
    %for each trial
    
    %turning on hold
    hold on;
    
    %setting dimmensions of plot
    set(gca, 'xlim', [0 trial], 'ylim', [0 1]);
    
    %creating matrices to plot
    positives = stimMat(2, 1:trial, block);
    negatives = positives;
    
    
    %looping through positives and negatives matrix and setting all negative responses to
    %NaN in positives and all pos responses to NaN in negatives
    for t =1:trial
        if respMatrix(2, t, block) == 0
            positives(t) = NaN;
        elseif respMatrix(2, t, block) == 1
            negatives(t) = NaN; 
        end
    end
    
    
    %plotting
    trialHistory = plot(1:trial-1, positives(1:end-1), 1:trial-1, negatives(1:end-1), 'LineStyle', 'none');
    %setting positives to have + symbol and negatives to have - symbol
    trialHistory(1).Marker = 'o';
    trialHistory(1).MarkerFaceColor = 'g';
    trialHistory(1).MarkerEdgeColor = 'g';
    
    trialHistory(2).Marker = 'o';
    trialHistory(2).MarkerFaceColor = 'r';
    trialHistory(2).MarkerEdgeColor = 'r';
    

    
end

%end of experiment screen
DrawFormattedText(window, ['Experiment Finished! Press any key to exit. \nYour psychometric threshold is: ' num2str(psychThresh)], 'center', 'center', white, window);
Screen('Flip', window);

%closes all the windows upon key press
KbStrokeWait;
close all;
sca;
