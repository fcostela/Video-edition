function eyetrackRecord = replayInhouse(subject, trial, method, aspectRatioAdjustment, overrideEyetrackRecord, writeOutMovie)
% Play back an eyetracking trial of a particular subject. Can also be used
% to play back an arbitrary single eyetracking record (with overrideEyetrackRecord), and to create output
% files (with writeOutMovie).
%
% INPUT
%  subject      The subject id, a string like e.g. '2851ye'
%  trial        Which trial by that subject, an integer in order that they
%               did the trials.
%  method       A string describing how to display the eyetracking data.
%               See the switch statement below for options.
%  aspectRatioAdjustment  Change this if the aspect ratio looks off -
%               usually will be either 1 or 1.185.
%  overrideEyetrackRecord An alternative eyetracking record overriding the
%               one generated during this trial, to use instead with this video.
%  writeOutMovie If true, will create an output movie file at the same time, 'out.mov'.
%
% OUTPUT
%  eyetrackRecord The eyetracking record that was actually used.
%
% Usage: eyetrackRecord = replayInhouse(subject, trial, method, aspectRatioAdjustment, overrideEyetrackRecord, writeOutMovie)
addpath('/Users/danielsaunders/Dropbox/Artificial scotoma/');
HideCursor;
AssertOpenGL;% Is the script running in OpenGL Psychtoolbox?
InitializeMatlabOpenGL(0,1); % initialize
if ~exist('writeOutMovie')
    writeOutMovie = false;
end
if ~exist('aspectRatioAdjustment')
    aspectRatioAdjustment = 1.185;
end

eyetrackDir = '/Users/danielsaunders/Free norm - eyetrack data/';
a = dir(sprintf('%s*%s*',eyetrackDir,subject));

Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'Verbosity', 2);
KbName('UnifyKeyNames');

% Open a graphics window on the main screen
whichScreen=max(Screen('Screens'));
InitializeMatlabOpenGL(0,1); % initialize


% PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible'); % request 32 bit per pixel for high res contrast
% win = PsychImaging('OpenWindow', whichScreen, meanLum);
win = Screen('OpenWindow', whichScreen, 0, [], []);
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

a = open([eyetrackDir a(trial).name]);
if exist('overrideEyetrackRecord') && ~isempty(overrideEyetrackRecord)
    eyetrackRecord = overrideEyetrackRecord;
else
    eyetrackRecord = a.eyetrackRecord;
end

if exist('method')
    videoModifier.method = method;
else
    videoModifier.method = 'yellowdot';
end

% Do the setup for the method that was chosen.
switch videoModifier.method
    case 'yellowdot'
    case 'bubbleMagnify'
        videoModifier.method = 'bubbleMagnify';
        videoModifier.bubbleSize = 85;
        videoModifier.MaxMag = 2.5;
    case 'scotoma'
        screenDistance = 95; % Distance from eyes to monitor n cm
        pixelsPerCm = 43.5; % Obtained by checkPixelSize
        % scotomaDegrees = 12; % size of scotoma in degrees of visual angle, including the ramps
        scotomaDegrees = 15; % size of scotoma in degrees of visual angle, including the ramps
        videoModifier.scotomaPixels = visualAngleToCm(scotomaDegrees,screenDistance) * pixelsPerCm;
        videoModifier.rampProportion = 0.3;  % the width of one blurry edge (ramp from transparency) as a proportion of the total width or height (it will scale to both)
                       % Note that a lot of the ramp will still look pretty
                       % opaque or transparent (the width is the distance
                       % from 0.01 to 0.99 opacity), so it may not look as
                       % wide as you expect.
                       
        videoModifier.scotomaRatio = 1.22; % Ratio of the width to the height
        videoModifier.movementThreshold = 0; %50 
     otherwise
         error('Unknown method.')
end


[pathstr name ext] = fileparts(a.movieFileName);
name = strrep(name, '_c 2','');
name = strrep(name, '_c','');
movieFileName = fullfile('/Users/danielsaunders/Free norm - video clips/',[name ext]);


loop = 0;
[drawingTimes frameTimes] = playMovieWithTraces(win, movieFileName, eyetrackRecord, videoModifier, loop, writeOutMovie, aspectRatioAdjustment);
% disp(frameTimes');
ShowCursor;
sca;
