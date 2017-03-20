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
% Stimulus and Experiment Parameters
%--------------------
%number of blocks
blocks = 1;

%number sets per block
setsPerBlock = 1;

%number of conditions (coherence values)
numConditions = 8;

%matrix for storing stimulus ID# and coherence values for each stimuli
%defined
% 1 - stimulus number
% 2 - stimulus coherence
stimCondMat = repmat(1:numConditions, 2, 1);

%Matrix to hold how many times each stimuli defined will be played per set.
%Default value is 1 time. 
condFreqMat = zeros(1, numConditions);
condFreqMat(1, :) = 1;

%Setting coherence for each stimuli and assigning stimuli frequency. 
%first row - stimulus ID#
%second row - coherence value 
%condFreqMat(1,n) - how many times each stimulus is played per set. Default
%is 1
stimCondMat(2,1) = 0;
condFreqMat(1,1) = 3; % three catch trials per set of stimuli. default is 1

stimCondMat(2,2) = 0.05;
stimCondMat(2,3) = 0.1;
stimCondMat(2,4) = 0.2;
stimCondMat(2,5) = 0.5;
stimCondMat(2,6) = 0.075;
stimCondMat(2,7) = 0.025;
stimCondMat(2,8) = 0.01;

%number of extra stimuli (deviations from default of 1 in condFreqMat)
numExtraStim = sum(condFreqMat) - numel(condFreqMat);

%number of trials per block.
numTrialsPerBlock = setsPerBlock * (numConditions + numExtraStim); 

%Expanding stimulusConditionsMatrix to setMatrix, which will be later
%expanded into stimulusMatrix (the matrix which will be shuffled and then
%used to generate textures for our stimuli)
%Creating setMat from copy of stimCondMat
setMat = stimCondMat;

%adding extra stimuli from condFreqMat to setMat
for i = 1:numConditions
    %setting counter for index of setMat
    indexCounter = 0;
    
    %setting counter for number of extra stimulus
    extraNumCounter = condFreqMat(1,i);
    
    %while there are extra stims --> expand setMat
    while extraNumCounter > 1;
        %expanding setMat
        indexCounter = indexCounter + 1;
        setMat(1, numConditions + indexCounter) = stimCondMat(1, i);
        setMat(2, numConditions + indexCounter) = stimCondMat(2, i);
        
        %decrementing extraNumCounter
        extraNumCounter = extraNumCounter - 1;
    end
    
end

%creating stimMat from setMat. stimMat will be shuffled and then used to
%create textures for our stimuli. 
stimMat = repmat(setMat, 1, setsPerBlock, blocks);

%Randomizing stimulusMatrix. stimMatShuffled will be the matrix used to
%create textures for each of the stimuli
stimMatShuffled = [];
for block = 1:blocks
    shuffler = Shuffle(1:numTrialsPerBlock);
    stimMatShuffled(:,:,block) = stimMat(:,shuffler,block);
end 

%--------------------
% Creating Textures for Stimuli
%--------------------
%apperture window properties
appX = 300; %app size
appY = 300;
appXCenter = appX/2;
appYCenter = appY/2;
appRadius = appX/2;

%circle stimulus properties
stimRadius = 50;
stimXPos = appXCenter;
stimYPos = appYCenter;
stimColor = white;

%Matrix to hold textures
texMat = zeros(numConditions);

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
  
%loop to draw circle with different coherence values for each stimulus type
%for each stim condition
for stimType = 1:numConditions
    windowMat = appMat;
    %Drawing circle into noise
    for y = 1:appY
        for x = 1:appX
            %if pixel is within the circle that defines the size of our dot
            %stimulus 
            if ((x - stimXPos)^2 + (y - stimYPos)^2) < stimRadius^2
                %coherence % chance to set pixelValue to stimColor
                if rand(1) <= stimCondMat(:,stimType);
                    windowMat(y,x) = stimColor;
                end
            end
        end
    end
    %create texture and place into textureMatrix. textureMatrix will be
    %used by experimental loop to draw stimuli. 
    noiseTexture = Screen('MakeTexture', window, windowMat);
    texMat(stimType) = noiseTexture;
end

%defining area the texture will be displayed
xPos = xCenter;
yPos = yCenter;
baseRect = [0 0 appX appY];

%Centering texture in center of window
rectCenter = CenterRectOnPointd(baseRect, xPos, yPos);

%--------------------
% Timing Information
%--------------------
%Generating interstimulus interval matrices between 1200 - 3400 ms
isiTimeSecs = (1200 + 2200 * rand(blocks, numTrialsPerBlock)) /1000;
isiTimeFrames = round(isiTimeSecs ./ ifi);

%Generating intrastimulus interval matrices of 50 ms (how long stimullus
%is being played
stimulusTimeSecs = repmat(.05, blocks, numTrialsPerBlock);
stimulusTimeFrames = round(stimulusTimeSecs ./ ifi);

%Generating prestimulus presentation interval when fixation cross
%dissapears (randomly between 500 - 1000 ms)
psiTimeSecs = (500 + 500 * rand(blocks, numTrialsPerBlock)) /1000;
psiTimeFrames = round(psiTimeSecs ./ ifi);

%Number of frames to wait before re-drawing
waitframes = 1;

%--------------------
% The Response Matrix
%--------------------
%3D matrix. Row 1 - stimulus Coherence . Row 2 - 1 or 0 for detected or not. Row
%3 - RT if detected. 0 if not detected. Each column is an individual
%stimulus presentation. Third dimmension is block number
respMatrix = nan(3, numTrialsPerBlock, blocks);

%--------------------
% The Experimental Loop
%--------------------
for block = 1:blocks
    for trial = 1:numTrialsPerBlock
        
        %setting type of stimulus being played to stimulus ID #
        stimNum = stimMatShuffled(1, trial, block);
        
        %Variable to determine whether or not a response was made
        respMade = false;
        
        %if first trial and block 1, present a start screen and wait for a key press.
        if trial == 1 && block == 1
            DrawFormattedText(window, 'Welcome to Allen''s constant stimuli detection task. Press any key to begin.', 'center', 'center', white);
            Screen('Flip', window);
            KbStrokeWait;
        %else if first trial and not block 1, present an interblock screen and wait for a key press    
        elseif trial == 1 && block ~= 1
            DrawFormattedText(window, ['Finished Block #' num2str(block) - 1 '. Press any key to continue.'], 'center', 'center')
            Screen('Flip', window);
            KbStrokeWait;
        end
        
        %Put fixation cross onto screen and don't look for userinput(first trial only)
        if  trial == 1
            DrawFormattedText(window, '+', 'center', 'center', white);
            vbl = Screen('Flip', window);

            %Play fixation point for the rest of the presentation interval (-1
            %frame because we played the fixation point at frame 1)
            for frame = 1:isiTimeFrames(block, trial) - 1

                %Draw fixation point
                DrawFormattedText(window, '+', 'center', 'center', white);

                %Flip to screen
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            end
        end 
        
        %Removing fixation cross
        for frame =1:psiTimeFrames(block, trial)
            Screen('FillRect', window, grey);
            vbl = Screen('Flip', window);
        end
       
        %Getting start time and drawing stimulus
        tStart = GetSecs;
        Screen('DrawTextures', window, texMat(stimNum), [], rectCenter, [], [], [], []);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        %Play stimulus patch for the rest of the presentation interval (-1
        %frame because we played the fixation point at frame 1)
        for frame = 1:stimulusTimeFrames(block, trial) - 1
            %Drawing Texture
            Screen('DrawTextures', window, texMat(stimNum), [], rectCenter, [], [], [], []);
        
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
        respMatrix(1, trial, block) = stimMatShuffled(1, trial, block);
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
    end
end

%end of experiment screen
DrawFormattedText(window, 'Experiment Over! Press any button to escape', 'center', 'center', black);
Screen('Flip', window);

%closes all the windows upon key press
KbStrokeWait;
close all;
sca;

%--------------------
% Plotting Psychometric Function
%--------------------
%Creating data matrix to store X and Y axis vectors
data = zeros(3, numConditions);

%Setting X axis to be a vector of coherence values in the order entered
%into condMatrix
for column = 1:numConditions
    data(1, column) = stimMat(2, column);
end

%Pooling across all trials and blocks for total number of yes responses for
%each coherence
for block = 1:blocks
    %iterate through stimMatShuffled/respMatrix 
    for i = 1:numTrialsPerBlock
       %iterate through data matrix
       for j =1:numConditions
           %if data column corresponds to matching coherence value and there
           %is a response
           if data(1, j) == stimMatShuffled(2, i, block) && respMatrix(2, i, block) == 1
               %count # of responses
               data(2, j) = data(2,j) + 1;
           end
           %set total number of stimuli played for each coherence
           data(3, j) = condFreqMat(1,j) .* setsPerBlock * blocks;
       end 
    end
end

%sorting data by coherence values, ascending order. 
[~, order] = sort(data(1,:));
sortedData = data(:, order);

%Plotting using sorted data matrix [X;Y]
figure;
psychFunction = plot(sortedData(1,:), sortedData(2,:)./(data(3,:)),'.-');
xlabel('Coherence');
ylabel('Performance');
title('Psychometric function');

