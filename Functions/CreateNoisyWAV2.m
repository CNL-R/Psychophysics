function [] = CreateNoisyWAV(Frequency, Coherence, Duration, SampleRate, Filename)
%Generates a sine wave, hides it in white noise and converts to audio WAV file. 
%   Frquency in Hz
%   Duration in ms
%   Sample Rate in Hz

    %Converting Duration from ms to seconds (because Hz is used as units in frequency and sample rate)
    Duration = Duration / 1000;
    
    t = 0:1/SampleRate:Duration;
    y = sin(2*pi*Frequency*t);
    [bleh lastt] = size(t);
    
    for i = 1:lastt
        if rand(1) > Coherence
            y(i) = y(i) + rand(1);
        end
    end 
    audiowrite(Filename, y, SampleRate);
end

