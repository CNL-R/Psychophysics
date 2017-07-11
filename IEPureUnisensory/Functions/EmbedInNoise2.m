function gaborMatrix = EmbedInNoise2(GaborMatrix, Coherence, ProbabilityGaussian, GaussianMatrix)
%EmbedInNoise2 embeds a gabor matrix in noise. Different from EmbedInNoise in that it does not auto trim into a circle and converts all pixel values with 'n' to noise. 
%   GaborMatrix - 2D matrix that holds the pixel values of the Gabor that one wants embedded in noise
%   Coherence - % of the pixels that are not turned into noise
%   ProbabilityGaussian - 1 or 0 is given. if 1, the noise will be in a probability gaussian. 
%   Gaussian values Mat for the probability gaussian if there is a probability Gaussian
%  

%getting stimLength from GaborMatrix
[stimLength ~] = size(GaborMatrix);
gaborMatrix = GaborMatrix;
stimXPos = stimLength / 2;
stimYPos = stimLength / 2;
stimRadius = stimLength / 2;

for y = 1:stimLength
    for x = 1:stimLength
        %if pixel is within the circle that we want to cut off for our
        %gabor
        if ProbabilityGaussian == 1
            if rand(1) >= Coherence * GaussianMatrix(y,x)
                gaborMatrix(y,x) = rand(1);
            end
        else
            if gaborMatrix(y,x) == 0;
                gaborMatrix(y,x) = rand(1);
            elseif rand(1) >= Coherence
                gaborMatrix(y,x) = rand(1);
            end
        end
    end
end

end

