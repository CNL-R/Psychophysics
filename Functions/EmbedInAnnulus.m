function stimulusMatrix = EmbedInAnnulus(InnerMatrix,AnnulusWidth, AnnulusColor)
%Given an annulus pixelvalue matrix, puts a circular matrix inside that annulus matrix.  
%   Detailed explanation goes here

%Assigning diameter
Diameter = size(InnerMatrix, 1);



stimulusMatrix = InnerMatrix;
for y = 1:Diameter
    for x = 1:Diameter
        if ((y - Diameter/2)^2 + (x - Diameter/2)^2 > ((Diameter/2) - AnnulusWidth)^2) && ((y - Diameter/2)^2 + (x - Diameter/2)^2 < (Diameter/2)^2)
            stimulusMatrix(y,x) = AnnulusColor;
        end
    end
end

end

