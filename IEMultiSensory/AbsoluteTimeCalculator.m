%Takes inputted duration and outputs theoretical actual output durations.

duration = 3333; %in ms
%load ifi from PTB script
%load refreshRate from PTB script
%load sampleFreq from PTB script

%VISUAL
frames = round(duration/1000*refreshRate)
vActual = frames * ifi * 1000

%AUDITORY
auditoryDuration = frames * ifi * 1000;
samples = round(sampleFreq*auditoryDuration);
aActual = samples * (1/sampleFreq)