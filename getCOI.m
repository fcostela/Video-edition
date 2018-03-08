function [x y missing] = getCOI(traceRecords, t)
% Compute the correct sample to use based on the time since the beginning
% of the movie (eyetracking data will typically have a different sample
% rate than a movie, so use the sample timestamps rather than assuming a certain rate)
%
% INPUT
%  traceRecords     Single record of (typically) an eye movement, with
%                   fields x,y,t, and missing.
%  t                Time in ms to retrieve the COI for.
%
% OUTPUT
%  x,y              Coordinates found at that time.
%  missing          True if no data at this point.
%
% Usage: [x y missing] = getCOI(traceRecords, t)

missing = false;
x = 0;
y = 0;

et = traceRecords.t - traceRecords.t(1);
coiIndex = find(et>t,1);
if isempty(coiIndex) || coiIndex > length(traceRecords.missing) % Ran out of cois
    % Just use the last position
    coiIndex = length(et);
    x = traceRecords.x(coiIndex);
    y = traceRecords.y(coiIndex);
else
    if traceRecords.missing(coiIndex)
        missing = true;
    else
        x = double(traceRecords.x(coiIndex));
        y = double(traceRecords.y(coiIndex));
    end
end