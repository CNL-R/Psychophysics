function [] = PresentBeep(Frequency, Duration, NumberChannels, Volume)
%given a frequency, duration, and number of channels, play beep. Duration
%is in ms and volume is 0 - 1. 
    Duration = Duration / 1000;
    sampleFreq = 48000;
    repetitions = 1;
    startCue = 0;
    waitForDeviceStart = 1;
    pahandle = PsychPortAudio('Open', [], 1, 1, sampleFreq, NumberChannels, [], [], [], []);
    PsychPortAudio('Volume', pahandle, Volume);
    myBeep = MakeBeep(Frequency, Duration, sampleFreq);
    PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]);
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    PsychPortAudio('Stop', pahandle, 1, 1);
    PsychPortAudio('Close', pahandle);
end

%for further optimizing, allow for user response. 