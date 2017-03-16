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

%--------------------
% Drawing the Circle
%--------------------
circleColor = [0 0 0];
circleXpos = xCenter;
circleYpos = yCenter;
circleSizePix = 250;
circleRadius = 250/2;

Screen('DrawDots', window, [circleXpos circleYpos], circleSizePix, circleColor, [], 3);
Screen('Flip', window);

%--------------------
% Window Matrix
%--------------------
%Matrix to hold 0s or 1s for each pixel on the screen. 0 for no stimulus
%present in pixel, 1 for stimulus present in pixel

%zero matrix size of window
windowMat = zeros(windowRect(4), windowRect(3));

%Filling stimulus region of windowMat with 1's
for y = 1:windowRect(4)
    for x = 1:windowRect(3)
        %if windowMat index is within the circle drawn
        if ((x - circleXpos)^2 + (y - circleYpos)^2) < circleRadius^2
            %set the windowMat value at that index = to 1
            windowMat(y,x) = 1;           
        end 
    end
    
end

%--------------------
% Drawing Noise
%--------------------

for y = 1:windowRect(4)
    for x = 1:windowRect(3)

