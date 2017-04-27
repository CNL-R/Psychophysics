function gaborMatrix = EmbedInNoise(GaborMatrix, Coherence, ProbabilityGaussian, GaussianMatrix)
%EmbedInNoise embeds a gabor matrix in noise. It has an additional function of trimming the gabor into a circle with diameter = GaborMatrix
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
        if ((x - stimXPos)^2 + (y - stimYPos)^2) < stimRadius^2
            if ProbabilityGaussian == 1
                if rand(1) >= Coherence * GaussianMatrix(y,x)
                    gaborMatrix(y,x) = rand(1);
                end
            else
                if rand(1) >= Coherence
                    gaborMatrix(y,x) = rand(1);
                end
            end
        else
            gaborMatrix(y,x) = rand(1);
        end
    end 
end

end

