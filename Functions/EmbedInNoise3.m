function gaborMatrix = EmbedInNoise3(GaborMatrix, Coherence, ProbabilityGaussian, GaussianMatrix)
%EmbedInNoise3 embeds a gabor matrix in noise. It does not trim the gabor into a circle, but instead sets all pixel values with a NaN to random noise. 
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
range = .1;

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
        elseif gaborMatrix(y,x) < 0.5 + range && gaborMatrix(y,x) > 0.5 - range
            gaborMatrix(y,x) = rand(1);
        else 
            
        end
    end 
end

end

