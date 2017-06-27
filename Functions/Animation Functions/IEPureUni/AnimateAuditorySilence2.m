function [AudioMatrix, responseWindowMatrix] = AnimateAuditorySilence2(AudioMatrix, responseWindowMatrix, Duration, SampleRate, getResp)
%Creates auditory silence and puts it in an auditory matrix. 
%Version 2 - builds responseWindowMatrix, a matrix containing the same
%amount of frames as AnimationTextures, but with a 1 or 0 telling the code
%whether or not to collect a response during this frame. 
%   AudioMatrix - audio matrix being built. 
%   Duration in ms
%   Sample Rate in Hz
%Version 2 - builds responseWindowMatrix, a matrix containing the same
%amount of frames as AnimationTextures, but with a 1 or 0 telling the code
%whether or not to collect a response during this frame. 

if numel(Duration) > 1
    Duration1 = Duration(1);
    Duration2 = Duration(2);
    
    Duration = rand(1) * (Duration2 - Duration1) + Duration1;
end

%Converting Duration from ms to seconds (because Hz is used as units in frequency and sample rate)
Duration = Duration / 1000;


y = zeros(2, round(SampleRate * Duration));
AudioMatrix = [AudioMatrix y];

responseWindow = AnimationTextures;
if getResp == 1
    responseWindow(:) = 1;
else
    responseWindow(:) = 0;
end

responseWindowMatrix = [responseWindowMatrix responseWindow];
end

