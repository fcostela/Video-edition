function coi = showCoiForVideo2(whichVideoNumber, modifyMode, coiMode, writeOutMovie, width, height, eyetrackPath, moviePath)
% Play one of the 200 video clips fullscreen with the requested
% modifications, potentially writing out the result as well. Escape to
% cancel out, spacebar to toggle the modification.
% 
% INPUT
% whichVideoNumber: A number from 1 to 200 corresponding to the
%                  segmentIds, for the video to play
% modifyMode:      A number indicating what kind of modification to apply.
%  Values at the moment are as follows:
%   1 = bubble magnification
%   2 = zoom magnification
%   3 = coi dot. The computed coi in red and yellow, and all the raw in black and white. 
%   4 = scotoma overlay
%   5 = Scotoma + cross (used to generate that lag demo video)
%
% coiMode:          A number indicating the method used to compute the coi
%                   used for the magnification from the eyetracking data.
%   Values are as follows:
%    1 = Regular COI, computing median at each time point and then smoothing
%    2 = A single position for the entire video (the median across viewers and frames)
%    3 = Static COI for each shot, taking the median over all
%    4 = Static COI for each shot, taking the median of all the cois at particular positions.
%    5 = Regular COI, computing median at each time point and then smoothing, except with only 1 bubble.
%    6 = First eyetrace only
%
% writeOutMovie:    If set to true, writes it out as out.mov.
% width, height:    If specified, opens the movie in a window of that size,
%                   which will then be the output size of the movie (handy if you want to
%                   generate files of the same dimensions as the input movies, not scaled to
%                   the screen size.)
%
% OUTPUT
% coi:              The coi that was computed for this movie and used in
%                   the modification for the playback.
%
% Usage: coi = showCoiForVideo(whichVideoNumber, modifyMode, coiMode, writeOutMovie, width, height)

if ~exist('modifyMode')
    modifyMode = 3;
end
if ~exist('coiMode')
    coiMode = 1;
end
if ~exist('writeOutMovie')
    writeOutMovie = false;
end

% Screen setup stuff
AssertOpenGL;% Is the script running in OpenGL Psychtoolbox?

%oldEnableFlag=Screen('Preference', 'EmulateOldPTB', 0);

Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'Verbosity', 2);
KbName('UnifyKeyNames');

% Do some prep for the graphics window.
whichScreen=max(Screen('Screens'));
InitializeMatlabOpenGL(0,1); 


% If we are using per-shot mode, we need to load the shot boundaries for
% this clip from a file.
if coiMode == 3
    load('Target shot boundaries.mat');
    a = find(whichVideoNumber == shotBoundaries(:,1));
    if isempty(a)
        error('No shot boundary information for that video.');
    end
    boundaries = shotBoundaries(a,2:end);
    boundaries = boundaries(1:nnz(boundaries));
else
    boundaries = [];
end


eyetrackPath='/Users/FranciscoCostela/Desktop/magnification/Videoclipeyetrackingdata';
moviePath='/Users/FranciscoCostela/Desktop/magnification/ClipsForNorming';
% Compute the coi (x and y coords for each frame of the clip) from the raw
% eyetracking data for the video (which it finds and loads).
coi = coiForVideo2(whichVideoNumber,0,coiMode,boundaries,eyetrackPath);

% Depending on the modifyMode, initialize the parameters of the
% modification. We have to load in the raw eyetracking data again because
% some of them want to display that as well, not just the computed COI.
%eyetrackDir = '/Users/danielsaunders/Free norm - eyetrack data';
%eyetrackDir ='/Users/John/Documents/Video clip eyetracking data';


[eyeTraces movieFileName] = loadTracesForVideo(whichVideoNumber, eyetrackPath);


videoModifier.movementThreshold = 0;
if modifyMode == 1
    videoModifier.method = 'bubbleMagnify';
    videoModifier.bubbleSize = 85;
    videoModifier.MaxMag = 2.5;   
    % videoModifier.eyeStds = eyeStds;
    videoModifier.stdevCircle = 0;
    eyeTraces = coi;
    % If there's a secondary COI, get rid of it.
    if length(eyeTraces) > 1
        eyeTraces = eyeTraces(1);
    end
elseif modifyMode == 2 % Zoom magnify
    videoModifier.method = 'zoomMagnify';
    videoModifier.mag = 2;
    eyeTraces = coi;
    % If there's a secondary COI, get rid of it.
    if length(eyeTraces) > 1
        eyeTraces = eyeTraces(1);
    end
elseif modifyMode == 3
    eyeTraces = [eyeTraces coi]; 
    videoModifier.method = 'ring' %contrastdot'%'coidot';
    videoModifier.diameter = 300;
    videoModifier.linecolor = [ 1 0 0 ];
    videoModifier.linewidth = 2;
    videoModifier.fillcolor = [ 0 0 0];
elseif modifyMode == 4   % scotoma 
    eyeTraces = coi;
    % If there's a secondary COI, get rid of it.
    if length(eyeTraces) > 1
        eyeTraces = eyeTraces(1);
    end
    screenDistance = 95; % Distance from eyes to monitor n cm
    pixelsPerCm = 43.5; % Obtained by checkPixelSize
    scotomaDegrees = 12; % size of scotoma in degrees of visual angle, including the ramps
%     scotomaDegrees = 20; % size of scotoma in degrees of visual angle, including the ramps
    videoModifier.scotomaPixels = visualAngleToCm(scotomaDegrees,screenDistance) * pixelsPerCm;
    videoModifier.rampProportion = 0.3;  % the width of one blurry edge (ramp from transparency) as a proportion of the total width or height (it will scale to both)
    videoModifier.scotomaRatio = 1.22; % Ratio of the width to the height
    videoModifier.movementThreshold = 00;
    videoModifier.method = 'scotoma';
else  % Scotoma + cross
    % If there's a secondary COI, get rid of it.
    if length(coi) > 1
        coi = coi(1);
    end
    coi2 = coi;
    coi2.t(2:end) = coi2.t(2:end)-35;
    coi = simulateRefreshDiscretization(coi, 60);
    eyeTraces = coi;
    eyeTraces(2) = coi2;
    screenDistance = 95; % Distance from eyes to monitor n cm
    pixelsPerCm = 43.5; % Obtained by checkPixelSize
    scotomaDegrees = 5; % size of scotoma in degrees of visual angle, including the ramps
%     scotomaDegrees = 20; % size of scotoma in degrees of visual angle, including the ramps
    videoModifier.scotomaPixels = visualAngleToCm(scotomaDegrees,screenDistance) * pixelsPerCm;
    videoModifier.rampProportion = 0.3;  % the width of one blurry edge (ramp from transparency) as a proportion of the total width or height (it will scale to both)
    videoModifier.scotomaRatio = 1.22; % Ratio of the width to the height
    videoModifier.movementThreshold = 50;
    videoModifier.method = 'scotomadot';

end    

% This is needed because of the way these movie files are stored. If the
% aspect ratio looks weird, you might need to adjust this (usually changing
% it between 1.185 and 1).
aspectRatioAdjustment = 1.185;

% Whether to play the movie repeatedly. Obviously doesn't work with writing
% it out.
loop = 0;

%eyeTraces = [eyeTraces coi]; 

% Figure out the actual movie name.
[pathstr name ext] = fileparts(movieFileName);
name = strrep(name, '_c 2','');
name = strrep(name, '_c','');
% movieFileName = fullfile('/Users/danielsaunders/Free norm - video clips/',[name ext]);
movieFileName = fullfile([moviePath filesep name ext])

Screen('CloseAll')
% Open the onscreen window.
if exist('width') && ~isempty(width)
    win = Screen('OpenWindow', whichScreen, 0, [200 200 width+200 height+200], []);
else
   win = Screen('OpenWindow', whichScreen,0, [], []);
end
HideCursor;

% Do the actual movie playing.

[drawingTimes frameTimes] = playMovieWithTraces(win, movieFileName, eyeTraces, videoModifier, loop, writeOutMovie, aspectRatioAdjustment,'out.mov');

ShowCursor;
sca;

%--------------------------------------------------------------------------


function newcoi = simulateRefreshDiscretization(coi, frameRate)
% This little function helps to create the demo of eye movement vs updating
% of scotoma movement, used in the Scotoma + cross modificationMode.

interframeInterval = 1000/frameRate;
t = coi.t(1);
sampleToUse = 1;
for i = 1:length(coi.t)
    if (coi.t(i) - t) > interframeInterval
        t = coi.t(i);
        sampleToUse = i;
    end
    newcoi.x(i) = coi.x(sampleToUse);
    newcoi.y(i) = coi.y(sampleToUse);
    newcoi.missing(i) = coi.missing(sampleToUse);
    newcoi.t(i) = coi.t(i);
end