% Script to generate 'video number lookup', which maps eyetracking file
% names to the video ids they're associated with.
%
% Usage: gatherVideoNumbers

eyetrackDir = /Users/FranciscoCostela/Desktop/PRL study/All%'/Users/danielsaunders/Free norm - eyetrack data';

eyetrackFiles = dir([eyetrackDir '/*.mat']);
eyetrackFiles = {eyetrackFiles.name};

for i = 1:length(eyetrackFiles)
    load([eyetrackDir filesep eyetrackFiles{i}]);
    if isfield(eyetrackRecord,'t')
        videoNumbers(i) = videoNumber;
    else
        videoNumbers(i) = -1;
    end
end
save 'video number lookup2.mat' eyetrackFiles videoNumbers
