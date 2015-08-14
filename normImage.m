function normIm = normImage(im)
% Converts image to double, normalizes it and returns a [x,y,3] image.
    im      = double(im);
    normIm  = std(im,[],3); 
    normIm  = normIm - min(normIm(:)); 
    normIm  = normIm/max(normIm(:)); 
    normIm  = repmat(normIm,[1 1 3]);
end