function magRect = getZoomMagRect(x, y, srcRect, screenRect, magAmount)
% Compute the correct rectangle to draw from the source video for a certain
% magnification, centered (as closely as possible without going off the edge) around x and y. 
% magAmount is 
%
%sc
% INPUT
%  x, y        Location of center of interest to magnify around. In screen coordinates (not relative to the original movie dimensions).
%  srcRect     Dimensions of the original movie
%  screenRect  Dimensions of the screen.
%  magAmount   How much to magnify. Expressed in the form of a multiplier of the width, e.g. if
%               it is 2, the width is doubled.
%
% OUTPUT 
%  magRect     The rect from the original movie to pull the image from. If
%              it is smaller than the movie dimensions, the image will be
%              magnified.
%
% Usage: magRect = getZoomMagRect(x, y, srcRect, screenRect, magAmount)


% This code zooms into a rectangle with the same aspect ratio as the screen (e.g. 1.78) even if the
% original clip is a different aspect ratio, thus ensuring the magnified
% portion will fill the screen (if it can)
aspectRatioAdjustment = 1.185;
screenRatio = RectWidth(screenRect)/RectHeight(screenRect);
magWidth = RectWidth(srcRect) / magAmount;
magHeight = magWidth / (screenRatio/aspectRatioAdjustment);
if magHeight > RectHeight(srcRect)
    magHeight = RectHeight(srcRect);
end
magRect = [ 0 0 magWidth magHeight];

% magRect = srcRect / magAmount;  % The simpler version, where the magnified area has the same aspect ratio as the original clip (will have the same letterboxing).

% Scale the input x and y, assuming that it was captured on the iMac screen
destRect = scaleMovieFrame([0 0 2560 1440], aspectRatioAdjustment, srcRect);

% First define as a proportion of the rectangle of the movie on the
% screen...
x = (x - destRect(1))/RectWidth(destRect);
y = (y - destRect(2))/RectHeight(destRect);

% Then scale back to the dimensions of the src rect.
x = x * RectWidth(srcRect);
y = y * RectHeight(srcRect);

left = ceil(x - RectWidth(magRect)/2);
top = ceil(y - RectHeight(magRect)/2);

% Constrain the magnification so that it must be drawn from within the
% frame.
if left < 0 
    left = 0;
elseif left + RectWidth(magRect) > RectWidth(srcRect)
    left = RectWidth(srcRect) - RectWidth(magRect);
end
if top < 0 
    top = 0;
elseif top + RectHeight(magRect) > RectHeight(srcRect)
    top = RectHeight(srcRect) - RectHeight(magRect);
end

magRect(1) = left;
magRect(2) = top;
magRect(3) = magRect(3) + left;
magRect(4) = magRect(4) + top;