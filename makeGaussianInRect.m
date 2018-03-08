function arrayWithGaussian = makeGaussianInRect(meanX,meanY, sd, boundingRect, peakheight)
% Create a 2D gaussian within a certain size of array. Used to make
% fixation maps.
%
% INPUT
%  meanX, meanY     Center of the gaussian
%  sd               Standard deviation of gaussian (equal in both
%                   dimensions)
%  boundingRect     A rect with the dimensions containing the gaussian.
%  peakheight       Maximum height of the gaussian
% 
% OUTPUT
%  arrayWithGaussian A 2D array with dimensions matching the size of
%                    boundingRect, containing the specified 2D gaussian.
%
% Usage: arrayWithGaussian = makeGaussianInRect(meanX,meanY, sd, boundingRect, peakheight)


if ~exist('peakheight')
    peakheight = 1;
end

[x y] = meshgrid((boundingRect(RectLeft)+1):boundingRect(RectRight), ...
    (boundingRect(RectTop)+1):boundingRect(RectBottom));
z = exp(-((x-meanX).^2)/(2*sd^2));
z = z .* exp(-((y-meanY).^2)/(2*sd^2));
z = z * peakheight;
arrayWithGaussian = z;