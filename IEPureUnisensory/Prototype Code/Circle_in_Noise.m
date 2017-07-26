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
% Creating Texture
%--------------------
%coherence value
coherence = 0.5;

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

%defining windowMat as random noise within a circle with centered in
%apperture with radius appX/2
windowMat = repmat(grey, appY, appX);
for y = 1:appY
    for x = 1:appX
        %if pixel is not in stimulus
        if ((x - appXCenter)^2 + (y - appYCenter)^2) < appRadius^2
           %set value to noise 
           windowMat(y,x) = rand(1);
        end 
    end 
end


%Drawing circle into noise
for y = 1:appY
    for x = 1:appX
        %if pixel is not in stimulus
        if ((x - stimXPos)^2 + (y - stimYPos)^2) < stimRadius^2
            %coherence % chance to set pixelValue to color
            if rand(1) <= coherence
                windowMat(y,x) = stimColor;
            end
        end 
    end 
end

%--------------------
% Drawing Texture
%--------------------
%create texture object
noiseTexture = Screen('MakeTexture', window, windowMat);

%defining area texture will be displayed
xPos = xCenter;
yPos = yCenter;
baseRect = [0 0 appX appY];

%Centering texture in center of window
rectCenter = CenterRectOnPointd(baseRect, xPos, yPos);

%Drawing and flipping
Screen('DrawTextures', window, noiseTexture, [], rectCenter, [], [], [], []);
Screen('Flip', window);
%

