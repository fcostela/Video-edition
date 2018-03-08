function playAllTraces(whichVideoNumber)
% A handy function to just play all the eyegaze traces as black and white
% dots on the video. Can also output to a file if writeOutMovie is set to
% true.
%
% INPUT
%  whichVideoNumber     Which clip, 1-200
%
% Usage: playAllTraces(whichVideoNumber)

%etPath='/Users/FranciscoCostela/Desktop/magnification/Video clip eyetracking data';
%movPath='/Users/FranciscoCostela/Desktop/magnification/ClipsForNorming';

whichScreen=max(Screen('Screens'));
load 'video number lookup.mat'
eyetrackDir = '/Users/FranciscoCostela/Desktop/magnification/Videoclipeyetrackingdata';%'/Users/danielsaunders/Free norm - eyetrack data';

videoModifier.method = 'contrastdot';
videoModifier.movementThreshold = 0;
videoModifier.stdevCircle = 1;
aspectRatioAdjustment = 1.185;
loop = 0;
writeOutMovie = true;

subjsForVid = find(videoNumbers == whichVideoNumber);
for i = 1:length(subjsForVid)
    load([eyetrackDir filesep eyetrackFiles{subjsForVid(i)}]);
    temp.x = eyetrackRecord.x;
    temp.y = eyetrackRecord.y;
    temp.t = eyetrackRecord.t;
    temp.missing = eyetrackRecord.missing;

    eyeTraces(i) = temp;
end
[pathstr name ext] = fileparts(movieFileName);
name = strrep(name, '_c 2','');
name = strrep(name, '_c','');
movieFileName = fullfile('/Users/FranciscoCostela/Desktop/magnification/ClipsForNorming',[name ext]);%fullfile('/Users/danielsaunders/Free norm - video clips/',[name ext]);

win = Screen('OpenWindow', whichScreen, 0, [], []);

playMovieWithTraces(win, movieFileName, eyeTraces, videoModifier, loop, writeOutMovie, aspectRatioAdjustment);

ShowCursor;
sca;