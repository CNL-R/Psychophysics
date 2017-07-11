function stimuliMatrix = EmbedInEfficientApperature(InnerMatrix, OuterMatrix)
%Calls CreateApperature to make an apperature and embeds 'InnerMatrix' in the center 
%   InnerMatrix- pixel value matrix of the inner matrix
%   Type - 'c' for circle, anything else for rectangle
%   SideLengthX - length X of the apperature in pixels
%   SideLengthY- length Y of the apperature in pixels
%   Color - color of the apperature. 'n' for noise
%   BackgroundColor - color behind the circle if 'c' is chosen for Type. 

[stimLengthY stimLengthX] = size(InnerMatrix);
[SideLengthY SideLengthX] = size(OuterMatrix);

%initializing variables used in CreateApperature
appXCenter = SideLengthX/2;
appYCenter = SideLengthY/2;

%Setting stimuli matrix as the Inner Matrix embedded into the Apperature Matrix
stimuliMatrix = OuterMatrix;
stimuliMatrix((appXCenter-0.5*stimLengthX):(appXCenter+0.5*stimLengthX - 1),(appYCenter-0.5*stimLengthY):(appYCenter+0.5*stimLengthY - 1), :) = InnerMatrix;

end

