function [AudioMatrix, ResponseWindow] = AnimateAuditorySilence2(AudioMatrix, Duration, SampleRate, getResp)
%Generates auditory noise and converts to audio WAV file.
%   Frquency in Hz
%   Duration in ms
%   Sample Rate in Hz

if numel(Duration) > 1
    Duration1 = Duration(1);
    Duration2 = Duration(2);
    
    Duration = rand(1) * (Duration2 - Duration1) + Duration1;
end

%Converting Duration from ms to seconds (because Hz is used as units in frequency and sample rate)
Duration = Duration / 1000;


y = zeros(2, round(SampleRate * Duration));
AudioMatrix = [AudioMatrix y];

if getResp == 1
    ResponseWindow(:) = 1;
else
    ResponseWindow(:) = 0;
end
end

