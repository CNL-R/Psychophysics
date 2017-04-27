function gabor = CreateGabor( Gabor_Diameter, Sigma, Lambda,  Orientation, Phase, Amplitude)
%Creates an array of pixel values for a Gabor given its parameters. The floor background color is gray. 
%   Gabor_Diameter: diameter(length or width of the square) of the gabor in pixels
%   Sigma: standard deviation of the 2D gaussian
%   Lambda: wavelength (number of pixels per cycle)
%   Orientation: orientation of the gabor in radians 0 - 2pi. 'r' can be inputted to make the orientation random
%   Phase: phase of the gabor in radians 0 - 2pi. 'r' can be inputted to make the phase random
%   Amplitude: amplitude of the sine wave in percentage (0 - 1)
%  
X0 = 1:Gabor_Diameter;                          
X0 = (X0 / Gabor_Diameter) - .5;                 
[Xm Ym] = meshgrid(X0, X0);
s = Sigma/Gabor_Diameter;
gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)));

%Setting orientation and randomizing if an 'r' is given 
if Orientation == 'r'
    theta = rand(1)*2*pi;
else
    theta = Orientation;
end
Xt = Xm * cos(theta);
Yt = Ym * sin(theta);
orientation = Xt + Yt;

%Setting phase and randomizing if an 'r' is given
if Phase == 'r'
    phase = rand(1) * 2* pi;
else
    phase = Phase;
end

%creating sin wave grating
grating = Amplitude .* sin(orientation * Gabor_Diameter/Lambda * 2 * pi + phase);

%creating gabor by dot-multiplying gauss matrix and grating matrix
gabor = grating .* gauss;

%changing value of floor color to mean gray
gabor = (gabor./2) + .5;
end

