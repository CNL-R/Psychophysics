function apperatureMatrix = CreateApperature(Type,SideLengthX, SideLengthY, Color, BackgroundColor)
%Creates a 2D array of pixel values for an apperature. This function is
%called by EmbedInApperature.m
%   Type: Default - rectangle. 'c' - circle. Input the desired diameter as SideLengthX & SideLengthY
%   SideLengthX: Length of side X dimmension in pixels
%   SideLengthY: Length of side Y dimmension in pixels
%   Color: Color of the apperature. 'n' for noise
%   BackgroundColor: Color of the background. Only relevant if circle is the chosen type.

%setting center of the output matrix
appXCenter = SideLengthX/2;
appYCenter = SideLengthY/2;

%initializing output matrix as a rectangular matrix of the given color and setting appRadius. 
apperatureMatrix = zeros(SideLengthY, SideLengthX);
apperatureMatrix(:,:) = BackgroundColor;
appRadius = SideLengthX/2;

%Creating apperature
%for each pixel in apperatureMatrix
for y = 1:SideLengthY
    for x = 1:SideLengthX
        if Type == 'c'
            %if the pixel is in the circle defined 
            if ((x - appXCenter)^2 + (y - appYCenter)^2) < appRadius^2
                %if the color was set to noise
                if Color == 'n'
                    %set value to noise values between 0 and 1
                    apperatureMatrix(y,x) = rand(1);
                else
                    apperatureMatrix(y,x) = Color;
                end
            end
        else
            %if the color was set to noise
            if Color == 'n'
                %set value to noise values between 0 and 1
                apperatureMatrix(y,x) = rand(1);
            else
                apperatureMatrix(y,x) = Color;
            end
        end
    end
end
end

