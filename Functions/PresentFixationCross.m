
function [vbl,respMade,rt] = PresentFixationCross(window, vbl, ifi, color, Duration1, Duration2, GetResp, tStart, rt)
%Plays a fixation cross for the given Duration in ms. Will generate a vbl
%if no vbl is given
%   window: window ptr of the window to present the stimuli. [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2,...
%       [], [],  kPsychNeed32BPCFloat);
%   vbl: if this is the first presentation of the stimulus, it creates one
%   this function returns vbl for subsequent presentation functions. ENTER 0 if this is the first presentation!!!
%   Color of the fixation cross.
%   Duration1: duration fixation cross is played in ms. If no duration 2 is given / 0 is inputted, then this is how long the stimulus is playedfor.
%       If Duration 2 is given, this is the lower bound in seconds for the random interval
%   ifi: Flip Interval. Use ifi = Screen('GetFlipInterval', windowPtr) to get it
%   Duration2: if nothing or 0 is passed, function plays fixation cross for a fixed period of time. If a ms greater than Duration 1 is given, then
%      the function will play the fixation cross for a random duration between Duration1 and Duration2
%   GetResp: set to true if you want response information (gives if a response was made and the reaction time. If RT is desired, give tStart
%   tStart: start time of desired RT interval. from getSecs
%   respMade: represents response to presentation that preceded this one.
%   Set to 0 if there is no response to the presentation before this one. 
%
%NOTE: This function will only change respMade to true if a response is
%made. If there is no response, respMade is NOT set to false. This is to accomodate
%for a series of presentations that wish to get user response. Initialize
%respMade as false before calling any presentX stimulus. 

%setting respMade to previous response and setting default rt to 0
respMade = PreviousRespMade;

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
%if this is the first instance of putting something on the monitor
if vbl == 0
    %Play fixation cross
    DrawFormattedText(window, '+', 'center', 'center', color);
    vbl = Screen('Flip', window);
    
    %Play fixation cross for the rest of the presentation interval (-1
    %frame because we played the fixation point at frame 1)
    for frame = 1:timeFrames - 1
        %Draw fixation point
        DrawFormattedText(window, '+', 'center', 'center', color);
        
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
    %otherwise, use prevoius vbl
else
    for frame = 1:timeFrames
        DrawFormattedText(window, '+', 'center', 'center', color);
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
end

