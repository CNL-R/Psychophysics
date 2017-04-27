function stimulusMatrix = EmbedInAnnulus(InnerMatrix,AnnulusWidth, AnnulusColor)
%Given a square annulus pixelvalue matrix, puts a circular matrix in the hole of the annulus ring.  
%   AnnulusWidth - given in pixels 

%Assigning diameter
Diameter = size(InnerMatrix, 1);

stimulusMatrix = InnerMatrix;
for y = 1:Diameter
    for x = 1:Diameter
        %if y,x is outside of the Inner Matrix AND inside the outerbounds of the annulus circle
        if ((y - Diameter/2)^2 + (x - Diameter/2)^2 > ((Diameter/2) - AnnulusWidth)^2) && ((y - Diameter/2)^2 + (x - Diameter/2)^2 < (Diameter/2)^2)
            %Set that pixel = the annulus color
            stimulusMatrix(y,x) = AnnulusColor;
        end
    end
end

end

