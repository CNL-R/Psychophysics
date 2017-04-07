function apperatureMatrix = CreateApperature(Type,SideLengthX, SideLengthY, Color, BackgroundColor)
%Creates a 2D array of pixel values for an apperature. Type
%   Type: Default - rectangle. 'c' - circle. Input desired diameter as SideLengthX 
%   SideLengthX: Length of side X dimmension in pixels
%   SideLengthY: Length of side Y dimmension in pixels
%   Color: Color of the apperature. 'n' for noise
%   BackgroundColor: Color of the background. Only relevant if circle is chosen type.

appXCenter = SideLengthX/2;
appYCenter = SideLengthY/2;

%initializing appmat as a rectangular matrix
apperatureMatrix = zeros(SideLengthY, SideLengthX);
apperatureMatrix(:,:) = BackgroundColor;
appRadius = SideLengthX/2;

%for each pixel in apperatureMatrix
for y = 1:SideLengthY
    for x = 1:SideLengthX
        if Type == 'c'
            %if the pixel is in a circle 
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

