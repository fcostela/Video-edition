function [coi nsamples eyeStds] = coiOverallMedian(eyeTraces)
% Compute the COI for a video as the median across all participants and all
% frames.
%
% INPUT
% eyeTraces     An array of structs, each has an x,y,t, and missing field.
%               Can be eyetracking records or similar data created by some
%               other means.
% OUTPUT    
%  coi          An array of either 1 or 2 structs, of the form
%               x,y,t,missing, that consist of a decision about the COI for
%               each frame of the video. The first will be the primary COI,
%               the second entry the secondary (if we meet the criteria for
%               having a secondary)
%  nsamples     How many eyetrace samples went into computing the coi at
%               each video frame? Array of integers. 2D array if numCOIs >
%               1 (with first dimension being which COI).
%  eyeStds      The standard deviation of the gaze points used to compute
%               the COI at each point. 2D array if numCOIs >
%               1 (with first dimension being which COI).
%
% Usage: [coi nsamples eyeStds] = coiOverallMedian(eyeTraces)

x = [eyeTraces(:).x];
y = [eyeTraces(:).y];
clipLength = 30; % Length of the stimulus movie in seconds.
frameRate = 60;  % Framerate of the COI output in Hz
frameTimes = 0:(1000/frameRate):clipLength*1000;

coi(1).t = frameTimes;
n = length(frameTimes);
coi(1).x = repmat(median(x), n, 1);
coi(1).y = repmat(median(y), n, 1);
coi(1).missing = zeros(n,1); 
coi(2).t = coi(1).t;
coi(2).missing = ones(n,1);

nsamples = [];
eyeStds = [];