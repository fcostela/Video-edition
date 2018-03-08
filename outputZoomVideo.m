function outputZoomVideo(moviefilename, eyeTraces, magnification, width, height, outfilename)
% Create a zoomed-in version of a video file, based on a COI.
%
% INPUT
%  moviefilename    Full path of the movie to apply it to.
%  eyeTraces        The coi to center the magnification around. Struct with
%                   x,y,t and missing.
%  width, height    Dimensions of the movie
%  outputFileName   Filename to output to.
%
% Usage: outputZoomVideo(moviefilename, eyeTraces, magnification, width, height, outfilename)

Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'Verbosity', 2);
whichScreen=max(Screen('Screens'));

videoModifier.method = 'zoomMagnify';
videoModifier.mag = magnification;

win = Screen('OpenWindow', whichScreen, 0, [200 200 width+200 height+200], []);
writeOutMovie = 1;
aspectRatioAdjustment = 1.185;
loop = 0;
playMovieWithTraces(win, moviefilename, eyeTraces, videoModifier, loop, writeOutMovie, aspectRatioAdjustment, outfilename);


