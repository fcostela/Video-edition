function [eyeTraces movieFileName] = loadTracesForVideo(whichVideoNumber, eyetrackDir)
% For a particular video number, load all of the eyetrack records we can
% find for it into an array.
% 
% INPUT
%  whichVideoNumber  the clip from 1-200
%  eyetrackDir       the directory we will find the eyetracking files in
%                   (.mat format, x,y,t and missing)
% OUTPUT
%  eyetraces        An array of structs, each one an eyetrackRecord (with
%                   x,y,t, and missing)
%  movieFileName    The base file name for the movie these originate from.
%
% Usage: loadTracesForVideo(whichVideoNumber, eyetrackDir)

% This file is generated using gatherVideoNumbers.
load 'video number lookup.mat'

subjsForVid = find(videoNumbers == whichVideoNumber);
for i = 1:length(subjsForVid)
    load([eyetrackDir filesep eyetrackFiles{subjsForVid(i)}]);
    temp.x = eyetrackRecord.x;
    temp.y = eyetrackRecord.y;
    temp.t = eyetrackRecord.t;
    temp.missing = eyetrackRecord.missing;

    eyeTraces(i) = temp;
end