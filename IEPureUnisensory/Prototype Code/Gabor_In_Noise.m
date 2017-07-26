%--------------------
% Initial Set-up Stuff
%--------------------
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
% Stimuli Params
%--------------------
%coherence value
coherence = 0.15;

%apperture window properties
appX = 300; %app size
appY = 300;
appXCenter = appX/2;
appYCenter = appY/2;
appRadius = appX/2;

%gabor stimulus properties
stimLength = 150;
stimRadius = stimLength/2;
stimXPos = appXCenter/2;
stimYPos = appYCenter/2;
lambda = 50; %wavelegnth (number of pixels per cycle)
theta = 0; %grating orientation
sigma = 50; %gaussian standard deviation in pixels
imSize = stimLength;
X0 = 1:imSize;                          
X0 = (X0 / imSize) - .5;                 
[Xm Ym] = meshgrid(X0, X0);
s = sigma/imSize;
gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)));
A = 0.75; %amplitude variable
grating = A .* sin(Xm * imSize/lambda * 2 * pi);
gabor = grating .* gauss; 
gabor = (gabor./2 + 0.5);

%Putting noise in gabor
for y = 1:stimLength
    for x = 1:stimLength
        %if pixel is within the circle that defines the size of our dot
        %stimulus
        if ((x - stimXPos)^2 + (y - stimYPos)^2) > stimRadius^2
            gabor(y,x) = rand(1);
        end
        if rand(1) >= coherence * gauss(y,x)
            gabor(y,x) = rand(1);
        end
    end
    
end

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

gaborMat = appMat;
gaborMat((appXCenter-0.5*stimLength):(appXCenter+0.5*stimLength - 1),(appYCenter-0.5*stimLength):(appYCenter+0.5*stimLength - 1)) = gabor;

%create texture and place into textureMatrix. textureMatrix will be
%used by experimental loop to draw stimuli.
noiseTexture = Screen('MakeTexture', window, gaborMat);
Screen('DrawTextures', window, noiseTexture, [], rectCenter, [], [], [], []);
Screen('Flip', window);
