function [vbl,respMade,rt] = PresentAnimatedNoise(textures, window, vbl, ifi, Duration1, Duration2, GetResp, tStart, PreviousRespMade, rt, rectCenter)
%Plays a visual stimulus for the given Duration in ms. Will generate a vbl if no vbl is given. Has ability to receive user input in form of key press or rt. Works by
%choosing a random image from a pool of noise images to be presented for each frame. Must first give this function a pool of textures in a one dimensional matrix. 
%   
%   textures - matrix of pool of textures of noise images
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
numTextures = numel(textures);

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
    %Play stimulus
    Screen('DrawTexture', window, textures(round(rand(1) * (numTextures - 1) + 1)), [], rectCenter, [], [], [], []);
    vbl = Screen('Flip', window);
    
    %Play stimulus for the rest of the presentation interval (-1
    %frame because we played the fixation point at frame 1)
    for frame = 1:timeFrames - 1
        %Draw fixation point
        Screen('DrawTexture', window, textures(round(rand(1) * (numTextures - 1) + 1)), [], rectCenter, [], [], [], []);
        
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
    for frame = 1:timeFrames
        Screen('DrawTexture', window, textures(round(rand(1) * (numTextures - 1) + 1)), [], rectCenter, [], [], [], []);
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


