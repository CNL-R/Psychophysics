function stimuliMatrix = EmbedInApperature(InnerMatrix, Type, SideLengthX, SideLengthY, Color, BackgroundColor)
%Calls CreateApperature to make an apperature and embeds 'InnerMatrix' in the center 
%   InnerMatrix- pixel value matrix of the inner matrix
%   Type - 'c' for circle, anything else for rectangle
%   SideLengthX - length X of the apperature in pixels
%   SideLengthY- length Y of the apperature in pixels
%   Color - color of the apperature. 'n' for noise
%   BackgroundColor - color behind the circle if 'c' is chosen for Type. 

[stimLengthY stimLengthX] = size(InnerMatrix);
%initializing variables used in CreateApperature
appXCenter = SideLengthX/2;
appYCenter = SideLengthY/2;

%calling CreateApperature
apperatureMatrix = CreateApperature(Type,SideLengthX, SideLengthY, Color, BackgroundColor);

%Setting stimuli matrix as the Inner Matrix embedded into the Apperature Matrix
stimuliMatrix = apperatureMatrix;
stimuliMatrix((appXCenter-0.5*stimLengthX):(appXCenter+0.5*stimLengthX - 1),(appYCenter-0.5*stimLengthY):(appYCenter+0.5*stimLengthY - 1), :) = InnerMatrix;

end

%Can be made more efficient by taking apperature matrix as an input and embed InnerMatrix into the given apperature matrix rather than generating an apperature.
%This is a relatively easy fix, as CreateApperature is a standalone function. 
