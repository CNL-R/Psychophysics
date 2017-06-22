function [AudioMatrix, Duration] = AnimateAuditoryNoise(AudioMatrix, Duration, SampleRate)
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
    
  
    y = 2*rand(round(SampleRate * Duration), 1) - 1;
    y= y';
    y(2,:) =  y(1,:);
    AudioMatrix = [AudioMatrix y];
   
end

