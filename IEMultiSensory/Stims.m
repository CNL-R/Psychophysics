[pinkNoiseMatrix, sampleFreq] = audioread('PinkNoise.WAV');

%2second pnoise normal amplitude
duration1 = 2 %in seconds
pn1 = pinkNoiseMatrix(1:duration*sampleFreq)
audiowrite('pinknoise1.wav',pn1,sampleFreq)

%2second pnoise half amplitude
duration2 = 2 %in seconds
pn2 = pinkNoiseMatrix(1:duration2*sampleFreq) .* 0.3;
audiowrite('pinknoise2.wav',pn2,sampleFreq);

%Stimuli in normal aplitude noise
duration3 = 60; %in ms
duration3 = duration3/1000;
Frequency1 = 1000; %in hz
Frequency2 = 200; %in hz
 t = 0:1/sampleFreq:duration3;
    t(1) = [];
    y1 = sin(2*pi*Frequency1*t);
    y2 = sin(2*pi*Frequency2*t);
    y = y1 .* y2;
   
pn = pinkNoiseMatrix(1:duration3*sampleFreq); 
yNoised = y .* 1 + pn';
audiowrite('stim.wav',yNoised,sampleFreq);