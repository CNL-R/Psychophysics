function [vbl,respMade,rt] = PresentEfficientAVStimulus(stimulusTexture, WAVFile, volume, window, vbl, ifi, Duration1, Duration2, GetResp, tStart, PreviousRespMade, rectCenter)
%Plays a stimulus given stimulusTexture and audio objects. 
%if no vbl is given
%   window: window ptr of the window to present the stimuli. [window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0.5, [], 32, 2,...
%       [], [],  kPsychNeed32BPCFloat);
%   vbl: if this is the first presentation of the stimulus, it creates one
%   this function returns vbl for subsequent presentation functions. ENTER 0 if this is the first presentation!!!
%   Color of the stimulus.
%   Duration1: duration stimulus is played in ms. If no duration 2 is given / 0 is inputted, then this is how long the stimulus is playedfor.
%       If Duration 2 is given, this is the lower bound in seconds for the random interval
%   ifi: Flip Interval. Use ifi = Screen('GetFlipInterval', windowPtr) to get it
%   Duration2: if nothing or 0 is passed, function plays stimulus for a fixed period of time. If a ms greater than Duration 1 is given, then
%      the function will play the stimulus for a random duration between Duration1 and Duration2
%   GetResp: set to true if you want response information (gives if a response was made and the reaction time. If RT is desired, give tStart
%   tStart: start time of desired RT interval. from getSecs
%   respMade: represents response to presentation that preceded this one.
%   Set to 0 if there is no response to the presentation before this one. 
%
%NOTE: This function will only change respMade to true if a response is
%made. If there is no response, respMade is NOT set to false. This is to accomodate
%for a series of presentations that wish to get user response. Initialize
%respMade as false before calling any presentX stimulus.  

%audiosetup stuff
repetitions = 1;
startCue = 0;
waitForDeviceStart = 1;
sampleFreq = 48000;
nrchannels = 2;

[y, ~] = audioread(WAVFile);
y(:, 2) = y(:, 1);
y = y';

%setting respMade to previous response and setting default rt to 0
respMade = PreviousRespMade;
rt = 0;

%setting number of frames to wait before redrawing
waitframes = 1;

%setting Time in Frames
if Duration2 > Duration1
    timeMSecs = (rand(1)*(Duration2 - Duration1) + Duration1)/1000;
    timeFrames = round(timeMSecs ./ ifi);
else
    timeMSecs = Duration1/1000;
    timeFrames = round(timeMSecs ./ ifi);
end

pahandle = PsychPortAudio('Open', [], 1, 1, sampleFreq, nrchannels, [], [], [], []);
PsychPortAudio('Volume', pahandle, volume);
PsychPortAudio('FillBuffer', pahandle, y);

%if this is the first instance of putting something on the monitor
if vbl == 0
    
    %play sound
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    
    %Play stimulus
    Screen('DrawTextures', window, stimulusTexture, [], rectCenter, [], [], [], []);
    vbl = Screen('Flip', window);
    
    %Play stimulus for the rest of the presentation interval (-1
    %frame because we played the fixation point at frame 1)
    for frame = 1:timeFrames - 1       
        %Draw fixation point
        Screen('DrawTextures', window, stimulusTexture, [], rectCenter, [], [], [], []);
        
        %Flip to screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        if GetResp == true
            %detecting response
            KeyIsDown = KbCheck;
            if KeyIsDown == 1
                respMade = true;
                tEnd = GetSecs;
                rt = tEnd - tStart;
            end
        end
    end
    %otherwise, use previous vbl
else
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    for frame = 1:timeFrames
        Screen('DrawTextures', window, stimulusTexture, [], rectCenter, [], [], [], []);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        if GetResp == true
            %detecting response
            KeyIsDown = KbCheck;
            if KeyIsDown == 1
                respMade = true;
                tEnd = GetSecs;
                rt = tEnd - tStart;
            end
        end
    end
end
PsychPortAudio('Close', pahandle);
end


