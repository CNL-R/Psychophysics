%Creates pixel matrix of an annulus given diameter, annuluswidth, color and
%background color
%Diameter - given in pixels
%AnnulusWidth - given in pixels

function annulusMatrix = CreateAnnulus(Diameter, AnnulusWidth, AnnulusColor, BackgroundColor)

%Drawing annulus. 
annulusMatrix = repmat(BackgroundColor, Diameter, Diameter);

%Drawing Outer Circle
for y = 1:Diameter
    for x = 1:Diameter
        if ((x - Diameter/2)^2 + (y - Diameter/2)^2) < (Diameter/2)^2
            annulusMatrix(y,x) = AnnulusColor;
        end
    end 
end 

%Drawing Inner Circle
for y = 1:Diameter
    for x = 1:Diameter
         if ((x - Diameter/2)^2 + (y - Diameter/2)^2) < ((Diameter/2) - AnnulusWidth)^2
            annulusMatrix(y,x) = BackgroundColor;
        end
    end 
end 
end


