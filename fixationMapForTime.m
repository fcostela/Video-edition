function fixationMap = fixationMapForTime(whichVideoNumber, width, height, time)
% Returns a fixation map for all the fixations for a particular video.
%
% INPUT
%  whichVideoNumber     The number 1-200 of the video clip.
%  width, height        Dimensions of the video clip
%  time                 The time to draw the fixations from. in ms.
% 
% OUTPUT
%  fixationMap          2D array, with 1 entry per pixel of the movie,
%                       giving the unscaled fixation map (so e.g. if 8
%                       fixations by different individuals land in the same
%                       spot, the peak will be 8 units high).
%
% Usage: fixationMap = fixationMapForTime(whichVideoNumber, width, height, time)

fixationSD = 25; % Standard deviation of the gaussian that should be added around fixation, in pixels.
eyetrackDir = '/Users/danielsaunders/Free norm - eyetrack data';

[eyeTraces movieFileName] = loadTracesForVideo(whichVideoNumber, eyetrackDir);
t = eyeTraces(1).t-eyeTraces(1).t(1);
coiIndex = find(t>time,1);
if isempty(coiIndex)
    coiIndex = 1;
end

fixationMap = zeros(height, width);
for j = 1:length(eyeTraces)
    if coiIndex > length(eyeTraces(j).x)
        continue;
    end
        
    x = eyeTraces(j).x(coiIndex);
    x = x * (width / 2560);
    y = eyeTraces(j).y(coiIndex);
    y = y * (height / 1440);
    fixationMap = fixationMap + makeGaussianInRect(x,y,fixationSD,[0 0 width height]);
end

