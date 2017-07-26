function [Parameters] = GenerateParameters(min, max)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    mid = mean([min max]);

A = [mean([mid min]) mean([mid max])];
B = [mean([A(1) min]) mean([max A(2)])];
C = [mean([A(1) mid]) mean([A(2) mid])];
D = [mean([A(1) C(1)]) mean([C(1) mid]) mean([mid C(2)]) mean([C(2) A(2)])];

Parameters = [0 min/2 min max mid A B C D .3];
Parameters = sort(Parameters);


end

