function [AudioMatrix, Duration, auditorySampleIndex] = AnimateAuditoryPinkNoise(AudioMatrix, PinkNoiseMatrix, Duration, SampleRate, auditorySampleIndex)
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
    
    samples = fix(SampleRate * Duration);
    y = PinkNoiseMatrix(:, auditorySampleIndex: auditorySampleIndex + samples - 1);   %
%     maximum = max(y);                                                               %
%     minimum = min(y);                                                               %
%     y = y/max([abs(minimum) abs(maximum)]);
    auditorySampleIndex = round(auditorySampleIndex + samples - 1);
    AudioMatrix = [AudioMatrix y];
    
end

