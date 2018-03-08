function coi = coiByShot(eyeTraces, numBubbles, minDistance, shotBoundaries, overallMedian)
% An alternate approach to computing the COI which maintains a fixed coi
% within each shot for a video. Requires you to pass in a list of the shot
% boundaries.
%
% INPUT
% eyeTraces     An array of structs, each has an x,y,t, and missing field.
%               Can be eyetracking records or similar data created by some
%               other means.
% numCOIs       Can be either 1 or 2. If 2 then function computes and
%               returns two COIs.
% minDistance   If in 2 COI mode, the centers of the COIs must be at least
%               this many pixels apart for the second COI to be active.
% shotBoundaries       A list of all the instances of the shot changing
%                      for this particular video. In ms from start of the
%                       video file.
% overallMedian        If true, then find the median of the position within
%                      each shot. Otherwise, first use the normal COI
%                      algorithm and then find the median of that (so
%                      benefitting from its tricky discounting of secondary
%                      clusters for example) This does not seem to work at
%                      the moment.
%
% OUTPUT
%  coi          An array of either 1 or 2 structs, of the form
%               x,y,t,missing, that consist of a decision about the COI for
%               each frame of the video. The first will be the primary COI,
%               the second entry the secondary (if we meet the criteria for
%               having a secondary)
%
% Usage: coi = coiByShot(eyeTraces, numBubbles, minDistance, shotBoundaries, overallMedian)

clipLength = 30; % Length of the stimulus movie in seconds.
frameRate = 60;  % Framerate of the COI output in Hz
frameTimes = 0:(1000/frameRate):clipLength*1000;
shotBoundaries = round(shotBoundaries * 1000/24); % Convert shot boundaries from frames to ms
shotBoundaries = [0 shotBoundaries clipLength*1000]; % Make sure the beginning and end count as boundaries.
outputShotBoundaries = round(shotBoundaries / (1000/frameRate))+1;

if overallMedian
    for i = 1:(length(shotBoundaries)-1)
        tStart = shotBoundaries(i);
        tEnd = shotBoundaries(i+1);
        
        x = [];
        y = [];
        for j = 1:length(eyeTraces)
            et = eyeTraces(j).t-eyeTraces(j).t(1);
            s = find(et > tStart & et <= tEnd & ~eyeTraces(j).missing);
            x = [x eyeTraces(j).x(s)];
            y = [y eyeTraces(j).y(s)];
        end
        sStart = outputShotBoundaries(i);
        sEnd = outputShotBoundaries(i+1);
        coi.x(sStart:sEnd) = median(x);
        coi.y(sStart:sEnd) = median(y);
    end
    coi.t = frameTimes;
    coi.missing = zeros(1,length(frameTimes));
else
    coi2 = coiFromEyeTraces(eyeTraces, numBubbles, minDistance);
    for i = 1:(length(shotBoundaries)-1)
        sStart = outputShotBoundaries(i);
        sEnd = outputShotBoundaries(i+1);
        if sEnd > length(coi2(1).x)
            sEnd = length(coi2(1).x);
        end
        coi.x(sStart:sEnd) = median(coi2(1).x(sStart:sEnd));
        coi.y(sStart:sEnd) = median(coi2(1).y(sStart:sEnd));
    end
    coi.t = frameTimes;
    coi.missing = zeros(1,length(frameTimes));
end

% Make a dummy secondary COI
coi(2).t = coi(1).t;
coi(2).missing = ones(length(frameTimes),1);
