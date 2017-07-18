min = .05;
max = 1;
mid = mean([min max]);

A = [mean([mid min]) mean([mid max])];
B = [mean([A(1) min]) mean([max A(2)])];
C = [mean([A(1) mid]) mean([A(2) mid])];
D = [mean([A(1) C(1)]) mean([C(1) mid]) mean([mid C(2)]) mean([C(2) A(2)])];

trialHistory = [0 min max mid A B C D];
trialHistory = sort(trialHistory);