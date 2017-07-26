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

%Set the blend function for the screen
%Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%--------------------
% Initial Gabor-Setup
%--------------------
%Dimension of the region where will draw Gabor in pixels
gaborDimPix = windowRect(4)/2;

%Sigma of Gaussian
sigma = gaborDimPix/7;

% Build a procedural gabor texture (Note: to get a "standard" Gabor patch
% we set a grey background offset, disable normalisation, and set a
% pre-contrast multiplier of 0.5.
% For full details see:
% https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/topics/9174
backgroundOffset = [0.5 0.5 0.5 0.0];
disableNorm = 1;
preContrastMultiplier = 0.5;
gabortex = CreateProceduralGabor(window, gaborDimPix, gaborDimPix, [], ... 
    backgroundOffset, disableNorm, preContrastMultiplier);

%--------------------
% Stimulus and Experiment Parameters
%--------------------
%number of blocks
blocks = 1;

%number of trials per condition
trialsPerCondition = 5;

%number of conditions (gabors)
numConditions = 3;

%number of trials per block
numTrialsPerBlock = trialsPerCondition * numConditions; 

%matrix for storing stimuli conditions information
% 1 - Gabor #
% 2 - Orientation
% 3 - Contrast
% 4 - Aspect Ratio
% 5 - Phase 
% 6 - Number of cycles
% 7 - frequency 
stimCondBase = transpose([1 2 3 4 5 6 7]); 
stimCondMat = repmat(stimCondBase, 1, numConditions); 

%SETTING PARAMETERS FOR EACH GABOR
stimCondMat(:,1) = [1 0 .0005 1 0 5 stimCondMat(6, 1)/gaborDimPix]; %Gabor #1
stimCondMat(:,2) = [2 0 .00055 1 0 5 stimCondMat(6, 2)/gaborDimPix]; %Gabor #2
stimCondMat(:,3) = [3 0 .0006 1 0 5 stimCondMat(6, 3)/gaborDimPix]; %Gabor #3

%Expanding stimulusConditionsMatrix to stimulusMatrix (what experimental
%loop will iterate through to get information about stimulus)
stimMat = repmat(stimCondMat, 1, trialsPerCondition, blocks);

%Randomizing stimulusMatrix. stimMatShuffled will be the matrix used by the
%experimental loop to get parameters for the Gabor being created
rand('seed', sum(100 * clock));
stimMatShuffled = [];
for block = 1:blocks
    %rand('seed', sum(100 * clock));
    shuffler = Shuffle(1:numTrialsPerBlock);
    stimMatShuffled(:,:,block) = stimMat(:,shuffler,block);
end 

%--------------------
% Timing Information
%--------------------
%Generating interstimulus interval matrices between 1200 - 3400 ms
isiTimeSecs = (1200 + 2200 * rand(blocks, numTrialsPerBlock)) /1000;
isiTimeFrames = round(isiTimeSecs ./ ifi);

%Generating intrastimulus interval matrices of 300 ms (how long stimullus
%is being played
stimulusTimeSecs = repmat([.3], blocks, numTrialsPerBlock);
stimulusTimeFrames = round(stimulusTimeSecs ./ ifi);

%Generating prestimulus presentation interval where fixation cross
%dissapears
psiTimeSecs = (500 + 500 * rand(blocks, numTrialsPerBlock)) /1000;
psiTimeFrames = round(psiTimeSecs ./ ifi);

%Number of frames to wait before re-drawing
waitframes = 1;

%--------------------
% The Response Matrix
%--------------------
%3D matrix. Row 1 - gabor number . Row 2 - 1 or 0 for detected or not. Row
%3 - RT if detected. 0 if not detected. Each column is an individual
%stimulus presentation. Third dimmension is block number
respMatrix = nan(3, numTrialsPerBlock, blocks);

%--------------------
% The Experimental Loop
%--------------------
for block = 1:blocks
    for trial = 1:numTrialsPerBlock
        
        %setting type of stimulus being played to gabor type
        condNum = stimMatShuffled(1, trial, block);
        
        %Variable to determine whether or not a response was made
        respMade = false;
        
          %if first trial, present a start screen and wait for a key press.
        if trial == 1 && block == 1
            DrawFormattedText(window, 'Welcome to Allen''s constant stimuli detection task. Press any key to begin.', 'center', 'center', white);
            Screen('Flip', window);
            KbStrokeWait;
            
        elseif trial == 1 && block ~= 1
            DrawFormattedText(window, ['Finished Block #' num2str(block) - 1 '. Press any key to continue.'], 'center', 'center')
            Screen('Flip', window);
            KbStrokeWait;
        end
        
        %Put fixation cross onto screen (first trial only)
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
        
         %Setting properties Matrix for the gabor being played this trial
        propertiesMat = [stimMatShuffled(5, trial, block), stimMatShuffled(7, trial, block), sigma, stimMatShuffled(3, trial, block), stimMatShuffled(4, trial, block), 0, 0, 0];
       
        %Getting start time and drawing gabor
        tStart = GetSecs;
        Screen('DrawTextures', window, gabortex, [], [], stimMatShuffled(2, trial, block), [], [], [], [],...
             kPsychDontDoRotation, propertiesMat');
        vbl = Screen('Flip', window);
        
        %Play Gabor patch for the rest of the presentation interval (-1
        %frame because we played the fixation point at frame 1)
        for frame = 1:stimulusTimeFrames(block, trial) - 1
            %Drawing Texture
            Screen('DrawTextures', window, gabortex, [], [], stimMatShuffled(2, trial, block), [], [], [], [],...
            kPsychDontDoRotation, propertiesMat');
        
            %flipping to screen
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
        %Gabor #
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
data = zeros(2, numConditions);

%Setting X axis
for column = 1:numConditions
    data(1, column) = stimMat(3, column);
end

%Pooling across all trials and blocks for total number of yes responses for
%each orientation
for block = 1:blocks
    %iterate through stimMatShuffled/respMatrix 
    for i = 1:numTrialsPerBlock
       %iterate through data matrix
       for j =1:numConditions
           if data(1, j) == stimMatShuffled(3, i, block) && respMatrix(2, i) == 1
               data(2, j) = data(2,j) + 1;
           end
       end 
    end
end

%Plotting using data matrix [X;Y]
figure;
plot(data(1,:), data(2,:)/(trialsPerCondition*block));
xlabel('Contrast');
ylabel('Performance');
title('Psychometric function');
