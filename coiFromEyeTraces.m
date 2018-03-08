function [coi nsamples eyeStds] = coiFromEyeTraces(eyeTraces, numCOIs, minDistance)
% Using multiple eyetracking records for the same stimulus, compute a
% "democratic center of interest" that captures the location that appeared
% to be the most salient at each point in time. If numCOIs is 2, also
% computes a secondary center of interest, when there is evidence of a
% substantial secondary center of interest at that point in time, and it is
% at least minDistance pixels from the first one.
%
% INPUT
% eyeTraces     An array of structs, each has an x,y,t, and missing field.
%               Can be eyetracking records or similar data created by some
%               other means.
% numCOIs       Can be either 1 or 2. If 2 then function computes and
%               returns two COIs.
% minDistance   If in 2 COI mode, the centers of the COIs must be at least
%               this many pixels apart for the second COI to be active.
%
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
% Usage: [coi nsamples eyeStds] = coiFromEyeTraces(eyeTraces, numCOIs, minDistance)

if ~exist('numCOIs')
    numCOIs = 1;
end
if ~exist('minDistance')
    minDistance = 0;
end

clipLength = 30; % Length of the stimulus movie in seconds.
frameRate = 24;  %60  % Framerate of the COI output in Hz
frameTimes = 0:(1000/frameRate):clipLength*1000;
screenRect = [0 0 2560 1440]; % Rect of the screen in pixels.
minGazePoints = 3;  % Number of points there must be before we declare a secondary COI
smoothingWindow = 35; % Moving average window to apply to the COI. In units of video frames.
secondaryExistenceSmoothing = 35; % A factor to reduce little islands of secondary COI.

ms = zeros(length(frameTimes), length(eyeTraces));
xs = zeros(length(frameTimes), length(eyeTraces));
ys = zeros(length(frameTimes), length(eyeTraces));

% For each frame of the video, collect all the samples that fell in that
% time range, for each trace. 
for i = 1:length(frameTimes)
    timeRange = [frameTimes(i)-500/frameRate  frameTimes(i)+500/frameRate];
    for j = 1:length(eyeTraces)
        t = eyeTraces(j).t - eyeTraces(j).t(1);
        traceRange = find(t > timeRange(1) & t <= timeRange(2));
        if isempty(traceRange)
            ms(i,j) = 1;
            continue;
        end
        missing = logical(eyeTraces(j).missing(traceRange)); 
        if all(missing)
            ms(i,j) = 1;
            continue;
        end
        
        % Remove the samples that are outside of the range of the screen
        missing(eyeTraces(j).x(traceRange) < screenRect(1)) = 1;
        missing(eyeTraces(j).y(traceRange) < screenRect(2)) = 1;
        missing(eyeTraces(j).x(traceRange) > screenRect(3)) = 1;
        missing(eyeTraces(j).y(traceRange) > screenRect(4)) = 1;
        if all(missing)
            ms(i,j) = 1;
            continue;
        end
        traceRange(missing) = [];  % Remove the samples with data marked as missing

        % Since traces can have more than one sample that corresponds to a
        % movie frame, take the mean of them.
        x = eyeTraces(j).x(traceRange);
        y = eyeTraces(j).y(traceRange);
        xs(i,j) = mean(x);
        ys(i,j) = mean(y);
    end
end

% xs and ys now contain one value for each eye trace at each output time
% point (so we have downsampled from the higher eyetracker sample rate). 
% Compute a democratic center of interest from these multiple traces at
% each time point.
for i = 1:length(frameTimes)
    % If there are no traces with a timepoint here then we have to mark
    % this point as missing
    if all(ms(i,:)) 
        for j = 1:numCOIs
            coi(j).missing(i) = 1;
            coi(j).x(i) = -1;
            coi(j).y(i) = -1;
            eyeStds(i,j) = 0;
            nsamples(i,j) = 0;
        end
    else
        coords = [xs(i,~ms(i,:)); ys(i,~ms(i,:))]';  % All the gaze locations at this timepoint, that aren't missing
        
        % If we are allowing multiple COIs (only 2 are possible at this
        % point)
        if numCOIs > 1
            % Use kmeans cluster analysis as the first step to check for
            % evidence of a secondary COI.
            if size(coords,1) == 1   % This bit is necessary because of a bug in kmeans when it receives a 1x2 matrix, of outputting a two element matrix.
                clusters = 1;
            else
                clusters = kmeans(coords, numCOIs);
            end
            
            % Swap the 1s and 2s if necessary so that 1 is always the cluster with the
            % most gaze points
            if length(coords(clusters == 1,1)) < length(coords(clusters == 2,1))
                clusters = 3 - clusters;  
            end
            
            % To have a secondary COI, there must be a certain number of points
            % in that cluster, and the center of the cluster must be a certain
            % distance from the center of the other cluster (making the bubbles
            % not overlap)
            if (length(find(clusters==2)) < minGazePoints)  ...
                    %             clusters(:) = 1;  % Use all the gaze points to compute the primary COI
                secondCOI(i) = 0;
            else
                secondCOI(i) = 1;
            end
            
            %%% An alternate approach to using the second cluster: if it's
            %%% too close, pool all the points together to compute a single COI for that frame.
            % clusterDistance(i) = norm([median(coords(clusters == 1,1))-median(coords(clusters == 2,1)), ...
            %    median(coords(clusters == 1,2))-median(coords(clusters == 2,2))]);
            %         if (clusterDistance(i) < minDistance)
            %             clusters(:) = 1;  % Use all the gaze points to compute the primary COI
            %             secondCOI(i) = 0;
            %         end
        else
            clusters = ones(1, size(coords,1));
            secondCOI(i) = 0;
        end

        % Now actually compute the x and y coordinates, using the median of the
        % eye traces.
        for j = 1:numCOIs
            if ~any(clusters == j)   % This code handles the case when there isn't a secondary coi (but we have allowed for the option)
                coi(j).missing(i) = 1;
                coi(j).x(i) = -1;
                coi(j).y(i) = -1;
                eyeStds(i,j) = 0;
                nsamples(i,j) = 0;
            else
                coi(j).x(i) = median(coords(clusters == j,1));
                coi(j).y(i) = median(coords(clusters == j,2));
                coi(j).missing(i) = 0;
                % Compute the variability of the positions used to compute
                % this point of the COI, actually an average of x and y
                % stds.
                eyeStds(i,j) = norm([std(coords(clusters == j,1)), std(coords(clusters == j,2))]); 
                nsamples(i,j) = length(find(clusters==j));
            end
        end
    end
end

% Set the timestamps for each COI entry, so we can match it with the video
% on playback.
for j = 1:numCOIs
    coi(j).t = frameTimes;
end


% Smooth the COI coordinates with a simple running average window.
coi(1).x = smooth(coi(1).x, smoothingWindow);   
coi(1).y = smooth(coi(1).y, smoothingWindow);

secondCOI = round(smooth(secondCOI, secondaryExistenceSmoothing)); % This ensures long durations of having a second COI or not

% If there are any instances of secondary COIs, use a few tricks to reduce
% flickering secondary COIs.
if any(secondCOI) && any(~coi(2).missing) 
    % Fill in the areas where there isn't a COI with the primary COI (this
    % helps with both the interpolation and the smoothing)
    coi(2).x(~secondCOI) = coi(1).x(~secondCOI); 
    coi(2).y(~secondCOI) = coi(1).y(~secondCOI);
    

    % Simple linear interpolation to fill in all the holes.
    numSamples = length(coi(2).missing);
    nonMissingForInterpolation = find(~coi(2).missing);
    if nonMissingForInterpolation(1) > 1
        nonMissingForInterpolation = [1 nonMissingForInterpolation];
    end
    if nonMissingForInterpolation(end) < numSamples
        nonMissingForInterpolation = [nonMissingForInterpolation numSamples];
    end
    coi(2).x = interp1(nonMissingForInterpolation, coi(2).x(nonMissingForInterpolation), 1:numSamples);  
    coi(2).y = interp1(nonMissingForInterpolation, coi(2).y(nonMissingForInterpolation), 1:numSamples);
            
    % Smooth the secondary COI.
    coi(2).x = smooth(coi(2).x, smoothingWindow);
    coi(2).y = smooth(coi(2).y, smoothingWindow);
    
    % Eliminate the secondary COI if it is too close to the first.
    coiDistance = sqrt((coi(1).x-coi(2).x).^2 + (coi(1).y-coi(2).y).^2);
    secondCOI(find(coiDistance < minDistance)) = 0; 

    % Set those places where there isn't a second COI to be "missing" in
    % the output COI.
    coi(2).missing = ~secondCOI;  
    coi(2).x(coi(2).missing) = -1;
    coi(2).y(coi(2).missing) = -1;
end


% 
% % Experimental code to  eliminate "islands" of nonmissing 2nd COI data, that is, islands
% % that are too small.
% inIsland = false;
% islandStart = 1;
% for i = 1:length(frameTimes)
%     if inIsland
%         if coi(2).missing(i) || i == length(frameTimes)  % At the end of an island
%             if (i - islandStart)+1 < min2ndCOIFrames
%                 coi(2).missing(islandStart:i) = true;
%             end
%             inIsland = false;
%         end
%     else
%         if ~coi(2).missing(i)
%             inIsland = true;
%             islandStart = i;
%         end
%     end 
% end

