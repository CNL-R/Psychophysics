function [responseMatrix] = PlayAVAnimation(VisualCell, AudioCell, responseMatrix, frameToTrialMatrix, pahandle, volume, window, ifi, rectCenter)
%Plays an AV animation given by an animation texture and AudioCell. The 
%   
%   VisualCell - matrix of all textures being played. Can be generated from GenerateAnimatedNoiseGabor
%   window: window ptr of the window to present the stimuli. [window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0.5, [], 32, 2,...
%       [], [],  kPsychNeed32BPCFloat);
%   vbl: if this is the first presentation of the stimulus, it creates one; use 0 in this case. This function returns vbl for subsequent presentation functions.
%       ENTER 0 if this is the first presentation!!! vbl is used to keep track of the time a stimulus was played for strict timing of presentations
%   ifi: Flip Interval. Use ifi = Screen('GetFlipInterval', windowPtr) to get it
%   Duration: For a stimulus of X ms, enter X for Duration1 and 0 for Duration 2. For a stimulus played for a random amount of time between X and Y, input X as
%   Duration1 and Y as Duration2
%   GetResp: set to true if you want response information (whether a response was made and RT)
%   tStart: start time of desired RT interval.
%   PreviousRespMade: represents response to the presentation that preceded this one if you are stringing presentation intervals of which you desire the same response. 
%       Set to 0 if there is no response to the presentation before this one. 
%   rt: represents previous reaction time to the presentation that preceded this one if you are stringing presentation intervals of which you desire the same response.
%       Set to 0 if there is no response to the presentation before this one. 
%   rectCenter: rectCenter = CenterRectOnPointd(baseRect, xPos, yPos); Used to center rectangle texture in the middle of the screen
%   
%IMPORTANT NOTE: This function will only change respMade to true if a response is
%made. If there is no response, respMade is NOT set to false. This is to accomodate
%for a series of presentations that wish to get user response. Initialize
%respMade as false before calling any presentX stimulus. 

%audiosetup stuff
repetitions = 1;
startCue = 0;
waitForDeviceStart = 1;
sampleFreq = 48000;
nrchannels = 2;


%setting number of frames to wait before redrawing
waitframes = 1;


trial = 1; %trial counter

PsychPortAudio('Volume', pahandle, volume);
PsychPortAudio('FillBuffer', pahandle, [AudioCell{trial}(:,:)  AudioCell{trial + 1}(:,:)]);
PsychPortAudio('Start', pahandle, 0, startCue, waitForDeviceStart);

for trial = 1:size(VisualCell, 2)
    trial
    responses = 0;
    timeFrames = round(numel(VisualCell{trial}(:)));
    
    if trial > 1 && trial < size(VisualCell, 2)
        [underflow, nextSampleStartIndex, nextSampleETASecs] = PsychPortAudio('FillBuffer', pahandle, AudioCell{trial + 1}(:,:), 1);
    end
    
    Screen('DrawTexture', window, VisualCell{trial}(1), [], rectCenter, [], [], [], []);
    vbl = Screen('Flip', window);
    
    for frame = 1:timeFrames - 1
        %Draw fixation point
        Screen('DrawTexture', window, VisualCell{trial}(frame + 1), [], rectCenter, [], [], [], []);
        
        %Flip to screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        
        %detecting response
        KeyIsDown = KbCheck;
        if KeyIsDown == 1
            responseMatrix(1, trial) = responses + 1;
        end
        
        
    end
end
PsychPortAudio('Stop', pahandle);
end



