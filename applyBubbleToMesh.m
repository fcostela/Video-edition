function [x y magfactor newdist] = applyBubbleToMesh(x, y, mx, my, MaxMag, bubbleSize, bubbleFlatness)
% The math for applying the bubble transformation to a 2D mesh of points.
% Pushes grid points away from the focal point according to a 2D normal
% distribution.
%
% INPUT
%  x,y      Coordinates to draw the bubble on, in pixels.
%  mx,my    The grid
%  MaxMag   Magnification of the bubble at the peak.
%  bubbleSize Standard deviation of the bubble, in pixels
%  bubbleFlatness   Number from 0 to 1 to make the bubble flatter on top (0
%                   is the normal gaussian shape)
%
% OUTPUT
%  x,y      The transformed mesh
%  magfactor Corresponding to the mesh, how much each point gets magnified
%           (pushed away from center)
%  newdist  The new distance from the center for each mesh point.
%
% Usage: [x y magfactor newdist] = applyBubbleToMesh(x, y, mx, my, MaxMag, bubbleSize, bubbleFlatness)

if ~exist('bubbleFlatness')
    bubbleFlatness = 0;
end

dist1=sqrt((x-mx).^2+(y-my).^2);

% Instead of using the basic gaussian function, we're using the pearson
% distribution, which lets us control the kurtosis (flatness on top)
% magfunction = exp(-(dist1.^2)./(2*bubbleSize.^2));
magfunction = pearspdf(dist1,0,bubbleSize, 0, flatnessToKurtosis(bubbleFlatness)); 

magfunction = magfunction ./ max(max(magfunction));
magfactor=(1+(MaxMag-1).* magfunction);
newdist=dist1.*magfactor;
ang1=atan2((y-my),(x-mx));
x=mx+(newdist.*cos(ang1));
y=my+(newdist.*sin(ang1));