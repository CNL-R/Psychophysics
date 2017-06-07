function [] = CreateNoisyWAV(Frequency, Coherence, Duration, SampleRate, Filename)
%Generates a sine wave, hides it in white noise and converts to audio WAV file. Also adds 5ms taper function
%   Frquency in Hz
%   Duration in ms
%   Sample Rate in Hz
    
    taperDuration = 5; %in ms
    taperDuration = taperDuration / 1000;
    Duration = Duration / 1000;
    
    %Generating 5ms taper
    
    leftTaper = linspace(0,1,SampleRate*taperDuration);
    rightTaper = linspace(1,0,SampleRate*taperDuration);
    taper(1:SampleRate*Duration) = 1;
    taper(1:SampleRate*taperDuration) = leftTaper;
    taper((SampleRate*Duration - SampleRate*taperDuration) + 1: SampleRate*Duration) = rightTaper;

    %Converting Duration from ms to seconds (because Hz is used as units in frequency and sample rate)
    
   
    t = 0:1/SampleRate:Duration;
    y = sin(2*pi*Frequency*t);
    [bleh lastt] = size(t);
    
    for i = 1:lastt
        if rand(1) > Coherence
            y(i) = (2)*rand(1) - 1;
        end
    end 
    audiowrite(Filename, y, SampleRate);
end

