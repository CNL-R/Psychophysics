function [AudioMatrix, auditorySampleIndex] = AnimatePinkNoisyRipple(AudioMatrix, PinkNoiseMatrix, Frequency1, Frequency2, Coherence, Duration, SampleRate, auditorySampleIndex)
%for testing timing of multisensory experiment 

    taperDuration = 5; %in ms
    taperDuration = taperDuration / 1000;
    Duration = Duration / 1000;
    
    %Generating 5ms taper
    
    leftTaper = linspace(0,1,SampleRate*taperDuration);
    rightTaper = linspace(1,0,SampleRate*taperDuration);
    taper(1:round(SampleRate*Duration)) = 1;
    taper(1:round(SampleRate*taperDuration)) = leftTaper;
    taper((round(SampleRate*Duration) - round(SampleRate*taperDuration)) + 1: round(SampleRate*Duration)) = rightTaper;

    %Converting Duration from ms to seconds (because Hz is used as units in frequency and sample rate)
    
   
    t = 0:1/SampleRate:Duration;
    t(1) = [];
    y1 = sin(2*pi*Frequency1*t);
    y2 = sin(2*pi*Frequency2*t);
    y = y1 .* y2;
    y(2,:) = y(1,:);
    
    lastt = size(t,2);
    
    samples = round(SampleRate*Duration);
    pinknoiseY = PinkNoiseMatrix(:, auditorySampleIndex: auditorySampleIndex + samples - 1);
%     maximum = max(pinknoiseY);                                                               %
%     minimum = min(pinknoiseY);   
%     pinknoiseY = pinknoiseY/max([abs(minimum) abs(maximum)]);
    auditorySampleIndex = round(auditorySampleIndex + samples);
    
    
%     for i = 1:lastt
%         if rand(1) > Coherence
%             y(:,i) = y(:,i) + pinknoiseY(:,i);
%         end
%     end
    %yNoised = Coherence .* y + pinknoiseY;
%     maximum = max(yNoised);
%     minimum = min(yNoised);
%     yNoised = yNoised/max([abs(minimum) abs(maximum)]);

%     for i = 1:lastt
%         if rand(1) > Coherence
%             yNoised(:,i) = pinknoiseY(:,i);
%         end
%     end 
    AudioMatrix = [AudioMatrix y];
end
%     pinkNoiseSample = pinknoise()
%     for i = 1:lastt
%         if rand(1) > Coherence
%             ytimes5Noised(:,i) = pinkNoiseMatrix(:,i);
%         end
%     end 
% figure
% plot(pinknoiseY(1,:))
% figure
% plot(y(1,:))
% figure
% plot(yNoised(1,:))

