function outputBlurredVideo(blurLevel, moviename, width, height, outputFileName)
% Apply a certain level of blur to the video and output it to a file.
%
% INPUT
%  blurLevel    Standard deviation of the gaussian blur kernel to apply.
%  moviename    Full path of the movie to apply it to.
%  width, height Dimensions of the movie
%  outputFileName Filename to output to.
%
% Usage: outputBlurredVideo(blurLevel, moviename, width, height, outputFileName)

enhanceParams.type = 'none';
enhanceParams.blurSD = blurLevel;
outputEnhancedMovie(moviename, width, height, outputFileName, enhanceParams, false);
