function stimuliMatrix = EmbedInApperature(InnerMatrix, Type, SideLengthX, SideLengthY, Color, BackgroundColor)
%Embeds one matrix in the center of an apperture that is created by the function. 
%   InnerMatrix- pixel value matrix of the inner matrix
%   Type - 'c' for circle, anything else for rectangle
%   SideLengthX - in pixels
%   SideLengthY- in pixels
%   Color - color of the apperature. 'n' for noise
%   BackgroundColor - color behind the circle if 'c' is chosen for Type. 

[stimLengthY stimLengthX] = size(InnerMatrix);
%initializing variables created in CreateApperature
appXCenter = SideLengthX/2;
appYCenter = SideLengthY/2;

%calling CreateApperature
apperatureMatrix = CreateApperature(Type,SideLengthX, SideLengthY, Color, BackgroundColor);

%Setting stimuli matrix as the Inner Matrix embedded into the Apperature Matrix
stimuliMatrix = apperatureMatrix;
stimuliMatrix((appXCenter-0.5*stimLengthX):(appXCenter+0.5*stimLengthX - 1),(appYCenter-0.5*stimLengthY):(appYCenter+0.5*stimLengthY - 1), :) = InnerMatrix;

end

