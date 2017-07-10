function [output, previous ] = RNRInt(min, max, previous)
%RNRInt draws a random int from min to max, but cannot draw the int 'previous'. For use when you don't want a random sampler
% to pick the same number twice

exclude = previous;
output = exclude;
while output == exclude
    output = round(rand(1)*(max - min) + min); 
    previous = output; 
end 


end

