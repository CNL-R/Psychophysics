%Changed from V1 to change output data to separate different runs. 
%       averageMatrix: [M, N, X, Y] 
%           M: Block #
%           N: Trial #
%           X: Empty Dimension
%           Y: Experiment Run #
%
%       respMatrix: [M, N, X, Y]
%           M = 1: Type of stimulus played. 1 = R. 2 = G. 3 = B. 
%           M = 2: RT to stimulus
%           N: Trial #
%           X: Block #
%           Y: Experiment Run #

%clear the workspace
close all;
clearvars;
sca;

%Setup PTB with some default values
PsychDefaultSetup(2);

%Seed random number generator
rand('seed', sum(100 * clock));

%Set the screen number to the external secondary monitor if there is one
%connected
screenNumber = max(Screen('Screens'));

%Define black, white and gray
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

%open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, [], 32, 2);

%flip to clear window
Screen('Flip', window);

%Query the time duration
ifi = Screen('GetFlipInterval', window);

%Set the text font and size
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 50);

%Query the maximum priority level
topPriorityLevel = MaxPriority(window);

%Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

%Set the blend function for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


%-----------------------------------------------------------------------------------
%                                                                  STIMULUS MATRICES
%-----------------------------------------------------------------------------------
%matrix for our different stimulus types and a base matrix for building the
%conditions matrix
condList = {'R', 'G', 'B'};
condMatrixBase = [1,2,3];
numConditions = numel(condList);

%number of blocks
blocks = 2;

%amount of trials per condition per block and total
trialsPerCondition = 1;
trialsPerBlock = trialsPerCondition * numConditions;
numTrials = trialsPerCondition * numel(condList) * blocks;

%creating the conditions Matrix
condMatrix = repmat(condMatrixBase, blocks, trialsPerCondition);

% Get number of trials per block
[~, numTrialsPerBlock] = size(condMatrix(1,:));

%randomizing the conditions Matrix
condMatrixShuffled = [];
for block = 1:blocks
    %rand('seed', sum(100 * clock));
    shuffler = Shuffle(1:numTrialsPerBlock);
    condMatrixShuffled(block,:) = condMatrix(block,shuffler);
end 


%----------------------------------------------------------------------------------
%                                                                TIMING INFORMATION
%----------------------------------------------------------------------------------

%Randomized Interstimulus interval time in seconds and frames and placed in
%matrices
isiTimeSecs = repmat([randi(2200) + 1200 randi(2200) + 1200 randi(2200) + 1200], blocks, trialsPerCondition);
isiTimeSecs = isiTimeSecs ./ 1000;
isiTimeFrames = round(isiTimeSecs .* (1/ifi));

%Numer of frames to wait before re-drawing
waitframes = 1;

%---------------------------------------------------------------------------------------
%                                                                   THE RESPONSE MATRIX
%---------------------------------------------------------------------------------------

%2 row matrix. Row one will hold the type of stimulus played. Row two will
%hold the reaction time to that stimulus. Row three will be which block
%that stimulus was played in
respMatrix = nan(2, numTrialsPerBlock, blocks);



%---------------------------------------------------------------------------------------
%                                                                     EXPERIMENTAL LOOP
%---------------------------------------------------------------------------------------

for block = 1:blocks
    %Animation loop. Loop for total number of trials per block
    for trial = 1:trialsPerBlock
        
        %Setting type of stimulus being played
        condNum = condMatrixShuffled(block, trial);
        
        %Variable to determine whether or not a response was made
        respMade = false;
        
        %if first trial, present a start screen and wait for a key press.
        if trial == 1 && block == 1
            DrawFormattedText(window, 'Welcome to Allen''s RT Task. Press any key to begin.', 'center', 'center', white);
            Screen('Flip', window);
            KbStrokeWait;
            
        elseif trial == 1 && block ~= 1
            DrawFormattedText(window, ['Finished Block #' num2str(block) - 1 '. Press any key to continue.'], 'center', 'center')
            Screen('Flip', window);
            KbStrokeWait;
        end
        
        %Put fixation cross onto screen and get the timestamp at the beginning of
        %the first frame
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
        
        %Branching statement to determine what stimulus to play and to play the
        %stimulus
        
        %Getting start time
        
        tStart = GetSecs;
        while respMade == false
            
            %playing R
            if condNum == 1
                
                Screen('DrawDots', window, [xCenter; yCenter], 20, [1 0 0], [], 2);
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                %Getting response
                
                %Check if the keyboard is being pressed and calculate an rt
                KeyIsDown = KbCheck;
                if KeyIsDown == 1
                    respMade = true;
                    tEnd = GetSecs;
                    rt = tEnd - tStart;
                end
                
                %playing G stimulus
            elseif condNum == 2
                
                Screen('DrawDots', window, [xCenter; yCenter], 20, [0 1 0], [], 2);
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                
                %Getting response
                
                %Check if the keyboard is being pressed and calculate an rt
                KeyIsDown = KbCheck;
                if KeyIsDown == 1
                    respMade = true;
                    tEnd = GetSecs;
                    rt = tEnd - tStart;
                end
                
                %playing B stimulus
            elseif condNum == 3
                
                Screen('DrawDots', window, [xCenter; yCenter], 20, [0 0 1], [], 2);
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                
                %Getting response
                
                %Check if the keyboard is being pressed and calculate an rt
                KeyIsDown = KbCheck;
                if KeyIsDown == 1
                    respMade = true;
                    tEnd = GetSecs;
                    rt = tEnd - tStart;
                end
            end
            
            %Record the trial data into data matrix
            respMatrix(1, trial, block) = condNum;
            
            if respMade == true
                respMatrix(2, trial, block) = rt;
            elseif respMade == false
                respMatrix(2, trial, block) = 0;
            end
        end
    end
end

%---------------------------------------------------------------------------------------
%                                                                 CALCULATING AVERAGE RT
%---------------------------------------------------------------------------------------
%calculates an average RT time for each stimulus condition and saves it to
%averageMatrix. 

%Matrix to hold the average RT for each stimulus condition per block
averageMatrix = repmat([0 0 0], blocks, 1);

%Matrix to hold pooled RT across all blocks per condition
totalAverageMatrix = [0 0 0];

%calculating average RT per condition per block
for block = 1:blocks
    for conditionNumber = 1: numConditions
        sum = 0;
        for n = 1: trialsPerBlock
            if respMatrix(1, n, block) == conditionNumber
                sum = sum + respMatrix(2, n, block);
            end 
        end
        averageMatrix(block,conditionNumber) = sum/trialsPerCondition;
    end
end 

%calculating average RT per condition across all blocks
for condition = 1:numConditions
    sum = 0;
    for block = 1:blocks 
        sum = sum + averageMatrix(block, condition);
    end
    totalAverageMatrix(condition) = sum/blocks;
end

%end of experiment screen
DrawFormattedText(window, ['Experiment Finished!\n Here are your reaction times: \nRed: '...
    num2str(totalAverageMatrix(1)) '\nGreen: ' num2str(totalAverageMatrix(2)) '\nBlue: ' num2str(totalAverageMatrix(3)) '\n Press any key to exit '], 'center', 'center', white);
Screen('Flip', window);


%---------------------------------------------------------------------------------------
%                                                                            SAVING DATA
%---------------------------------------------------------------------------------------
%Setting filepath and filename 
filepath = 'C:\toolbox\Code\RGB_RT_MultiBlock';
filename = 'test.mat';

%Uncomment to get initial .mat file set up
%save(fullfile(filepath,filename),'averageMatrix', 'respMatrix', 'isiTimeSecs');
%close all;
%sca;
%return;

%copying the data we want to send out 
averageMatrixCopy = averageMatrix;
respMatrixCopy = respMatrix;
isiTimeSecsCopy = isiTimeSecs;

%loading each of the variables in the datafile. 
load(filename, 'averageMatrix');
load(filename, 'respMatrix');
load(filename, 'isiTimeSecs');

%appending the data we just collected to the loaded data. 
averageMatrix = cat(4, averageMatrix, averageMatrixCopy);
respMatrix = cat(4, respMatrix, respMatrixCopy);  
isiTimeSecs = cat(4, isiTimeSecs, isiTimeSecsCopy);

%saving combined data to file
save(fullfile(filepath,filename),'averageMatrix', 'respMatrix', 'isiTimeSecs');

%closes all the windows upon key press
KbStrokeWait;
close all;
sca;
