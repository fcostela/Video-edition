function destRect = scaleMovieFrame(screenRect, aspectRatioAdjustment, srcRect)
% Given a frame of the movie, figure out how to best scale it so that the 
% video fills as much of the screen as possible, while staying at its 
% proper aspect ratio. aspectRatioAdjustment is needed if the film is in
% anamorphic widescreen (file is squished by a factor of 1.185 typically)

destRect = screenRect;

%     aspectRatio = (RectWidth(srcRect)*1.185)/RectHeight(srcRect);
movieAspectRatio = (RectWidth(srcRect)*aspectRatioAdjustment)/RectHeight(srcRect);
screenAspectRatio = RectWidth(screenRect)/RectHeight(screenRect);

% This code makes sure the video fills as much of the screen as
% possible, and displays at its proper aspect ratio.
if movieAspectRatio < screenAspectRatio
    destRect(3) = destRect(4)*movieAspectRatio;
elseif movieAspectRatio > screenAspectRatio
    destRect(4) = destRect(3)/movieAspectRatio;
end
destRect = CenterRect(destRect,screenRect);