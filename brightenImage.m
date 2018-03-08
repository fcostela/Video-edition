function [im thehist maxGrayLevel] = brightenImage(im)
% Modify an image stored as an RGB array. 
% Make everything a bit brighter. 

g = rgb2gray(im);
g = g(:);
thehist = histc(g, 0:1:256);
maxGrayLevel = quantile(g, 0.999);
im = im * (255/double(maxGrayLevel));
