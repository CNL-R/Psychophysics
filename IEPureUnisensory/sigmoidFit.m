[filename filepath] = uigetfile('C:\Users\achen52\Documents\GitHub\Psychophysics\IEPureUnisensory\Psychophysics DATA\Saved Data', 'Please select your data');
load(strcat(filepath,'\',filename));

figure;
subplot(2,1,1);
hold on;
[param, stat] = sigm_fit(xAxis(1,:), yAxis(1,:), [], [], 1);
set(gca, 'ylim', [0 1]);
title('Visual');
plot(xAxis(1,:),yAxis(1,:))


subplot(2,1,2);
hold on;
[param, stat] = sigm_fit(xAxis(2,:), yAxis(2,:), [], [], 1);
set(gca, 'ylim', [0 1]);
title('Auditory');
plot(xAxis(2,:),yAxis(2,:))

