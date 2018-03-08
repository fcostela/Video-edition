function outputBubbleVideo(moviefilename, eyeTraces, bubbleSize, bubbleMagnify, width, height, outfilename, bubbleFlatness, splitFile)
% For a given video clip, output it with a bubble magnification.
%
% INPUT
%  eyetraces        A single eyetrack record containing the location of the
%  bubble over time (usually computed with a coi algorithm)
%  bubbleSize       Standard deviation of the bubble in pixels
%  bubbleMagnify    How much it's magnified at the peak magnification
%  width, height    Dimensions of the video clip
%  outfilename      Path of file to write out to
%  bubbleFlatness   Number from 0 to 1 to make the bubble flatter on top (0
%                   is the normal gaussian shape)
%  splitFile        If true, we make two 15 s files instead of 1.
%
% Usage: outputBubbleVideo(moviefilename, eyeTraces, bubbleSize, bubbleMagnify, width, height, outfilename, bubbleFlatness, splitFile)


if ~exist('bubbleFlatness')
    bubbleFlatness = 0;
end

if ~exist('splitFile')
    splitFile = 0;
end

AssertOpenGL;% Is the script running in OpenGL Psychtoolbox?
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'Verbosity', 2);
whichScreen=max(Screen('Screens'));
InitializeMatlabOpenGL(0,1); % initialize

videoModifier.method = 'bubbleMagnify';
videoModifier.bubbleSize = bubbleSize; %85;
videoModifier.MaxMag = bubbleMagnify; %2.5;
videoModifier.bubbleFlatness = bubbleFlatness;
videoModifier.stdevCircle = 0;

win = Screen('OpenWindow', whichScreen, 0, [200 200 width+200 height+200], []);
writeOutMovie = 1;
aspectRatioAdjustment = 1.185;
loop = 0;
playMovieWithTraces(win, moviefilename, eyeTraces, videoModifier, loop, writeOutMovie, aspectRatioAdjustment, outfilename, splitFile);


