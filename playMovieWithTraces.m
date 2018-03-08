function [drawingTimes frameTimes] = playMovieWithTraces(win, moviefilename, traceRecords, videoModifier, loop, writeOutMovie, aspectRatioAdjustment, outMovieName, splitFile)
% Play a movie with a modification superimposed on it, computed from
% traceRecords, which is an array of x-y traces (usually eyetracking data).
% Scroll down to the switch statement to see the different types of
% modifications. Escape to  cancel out, spacebar to toggle the modification.
% Plays it as quickly as possible (to aid with outputting movie files).
% Would require a little modification to play movie at normal speed.
%
% INPUT
%  win              A valid, open window to draw to.
%  moviefilename    The full path to the movie file to use.
%  traceRecords     An array of structs, each has an x,y,t, and missing field.
%                   Can be eyetracking records or similar data created by some
%                   other means. Most assume the COI is the last item,
%                   except for coiDot which assumes it's the second to last
%                   (and that the last is the secondary).
%  videoModifier    Struct specifying the modification method, and any
%                   parameters required for that method.
%  loop             Unused at the moment.
%  writeOutMovie    If set to true, writes out the modified film.
%  aspectRatioAdjustment  If the aspect ratio looks weird, mess with this.
%                   Usually should be either 1 or 1.185.
%  outMovieName     Full path to the file that should be created if
%                   writeOutMovie is true.
%  splitFile        If true, will create two output movies, splitting them
%                   at the 15 second mark.
%
% OUTPUT
%  drawingTimes     How long it took to draw each frame (in s)
%  frameTimes       Time of each frame, in ms starting from 0 at the
%                   beginning.
% 
% If writeOutMovie is true, then this will generate a QuickTime movie as
% output.
% 
% Usage: [drawingTimes frameTimes] = playMovieWithTraces(win, moviefilename, traceRecords, videoModifier, writeOutMovie, aspectRatioAdjustment, outMovieName)

if ~exist('loop')
    loop = 0;
end
if ~exist('writeOutMovie')
    writeOutMovie = false;
end
if ~exist('aspectRatioAdjustment')
    aspectRatioAdjustment = 2;
end
if ~exist('outMovieName')
    outMovieName = 'out.mov';
end
if ~exist('splitFile')
    splitFile = 0;
end

if ~isfield(videoModifier,'movementThreshold')
    videoModifier.movementThreshold = 0;
end

esc=KbName('ESCAPE');

% Open movie file, get a handle to the movie
[ movie t fps] = Screen('OpenMovie', win, moviefilename) 
    


timeindices = 0:(1/24):30;

% Initialization
switch videoModifier.method
    case 'scotoma'
        % DEPENDENCY: makeErfScotomaTex in artificial Scotoma folder (currently)
        scotomaTex = makeErfScotomaTex(win, round([videoModifier.scotomaPixels, videoModifier.scotomaPixels*videoModifier.scotomaRatio]), videoModifier.scotomaPixels*videoModifier.rampProportion); 
        Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);   
    case 'scotomadot'
        scotomaTex = makeErfScotomaTex(win, round([videoModifier.scotomaPixels, videoModifier.scotomaPixels*videoModifier.scotomaRatio]), videoModifier.scotomaPixels*videoModifier.rampProportion);
        Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);   
    case 'bubbleMagnify'
        [tex ] = Screen('GetMovieImage', win, movie, 1, 2 );
        [x1 y1 sObj] = initMagnificationBubble(win,tex);
end


drawingTimes = [];
frameTimes = [];
modificationOn = true;
spaceDown = false;
lastX = -1000; lastY = -1000;
x = 0;
y = 0;
screenRect = Screen('Rect', win);
tex = 0;

ti = 1;


newMovObj=VideoWriter('outTest.avi','Motion JPEG AVI');
newMovObj.FrameRate = fps;%length(movmat)/30;%movobj.NumberOfFrames;%30;
open(newMovObj);

    


while(ti<20)% length(timeindices))
%%% This code checks for memory leaks by outputting the free memory
%%% every 100 iterations - if it's going down systematically then
%%% there's a problem. Suspect there's a leak somewhere at present.
%     if mod(ti,20) == 0 
%         disp(getFreeMemory);
%     end

    % Get the next frame of the movie
    [tex ] = Screen('GetMovieImage', win, movie, 1, timeindices(ti));

    if tex<0 % Ran out of frames of the movie, so quit the loop
        break;
    end;

    if tex>0
        timeindex = timeindices(ti)*1000; 
        movieFrame = tex;
        newMovieFrame = 1;
    else
        timeindex = timeindices(ti)*1000;
        newMovieFrame = 0;
    end
    if newMovieFrame % There was a new frame available
        tic;
        frameTimes = [frameTimes timeindex];

        % Deal with zoom magnification stuff (unlike the others, it just
        % works by changing the rect from which the rect is copied)
        
        srcRect = Screen(movieFrame,'Rect')
        
        if strcmp(videoModifier.method,'zoomMagnify')
            [x2 y2 missing] = getCOI(win, traceRecords(1), timeindex);
            if ~missing 
                x = x2;
                y = y2;
            end
            srcRect = getZoomMagRect(x, y, srcRect, screenRect, videoModifier.mag);
        end
        
        % Compute the area on the screen the frame will be drawn into (as
        % big as possible)
        destRect = scaleMovieFrame(screenRect, aspectRatioAdjustment, srcRect);
        

        if writeOutMovie
            % If we haven't started writing out the movie
            if ~exist('outMovie')
                %%% This code might help with snipping off the letter box
                %%% if you are outputting the full-screen thing.
%                  outDestRect = srcRect;
%                  yLetterboxOffset = outDestRect(2);
%                  outDestRect([2 4]) = outDestRect([2 4])- yLetterboxOffset;
%                  outDestRect(3) = outDestRect(3)* aspectRatioAdjustment;
%                  width = round(RectWidth(outDestRect));
%                  height = round(RectHeight(outDestRect));
                
                % It's necessary for the width and height to be a multiple
                % of 4 for the video file format to work.
                width = round(RectWidth(destRect)/4)*4;
                height = round(RectHeight(destRect)/4)*4;
                
                % Create the movie file.
                % This returned an error. Running without 'Encoding Quality'
                % outMovie = Screen('CreateMovie', win, outMovieName, width, height, 24,'EncodingQuality=0.7');
                outMovie = Screen('CreateMovie', win, outMovieName, width, height, 24);
            elseif splitFile  % Split the output movie into two halves (assumes 30 s movie)
                if timeindex > 15000
                    Screen('FinalizeMovie', outMovie);
                    outMovieName(end-13) = '2'; % Change the part of the filename to indicate that it's part 2
                    outMovie = Screen('CreateMovie', win, outMovieName, width, height, 24,'EncodingQuality=0.7');
                    splitFile = false;
                end
            end
        end
        
        if ~strcmp(videoModifier.method,'bubbleMagnify')
            Screen('FillRect',win,[0 0 0]);
            Screen('DrawTexture', win, movieFrame, srcRect,destRect);
        end        
       
       % Draw over the frame depending on the video modifier type.
       switch videoModifier.method
            case 'none'
            % Zoom magnification. We don't have to do anything at this point.
            case 'zoomMagnify'
                
            % Draw all the traces as little yellow dots.
            case 'yellowdot'
                [x y missing] = getCOI(win, traceRecords(end), timeindex);
                if ~missing && modificationOn
                    drawYellowDot(win, x, y);
                end
                
            % Draw all the traces as black dots with white boundaries.
            case 'contrastdot'
                for i = 1:length(traceRecords)
                    [x y missing] = getCOI(win, traceRecords(i), timeindex);
                    if ~missing && modificationOn
                        drawContrastDot(win, x, y);
                    end
                end
                
            % Draw COI as a large yellow dot with red border, the secondary
            % as a smaller red and yellow dot, and all the other trace
            % records as black and white dots. The second to last item in
            % traceRecords should be the COI, and the last the secondary
            % COI, while all the others can be (e.g.) the raw eye
            % positions. 
            case 'coidot'
                for i = 1:length(traceRecords)
                    [x y missing] = getCOI(win, traceRecords(i), timeindex);
                    
                    if i < length(traceRecords)-1 && modificationOn 
                        if ~missing && modificationOn
                            drawContrastDot(win, x, y);
                        end
                    elseif i == length(traceRecords)-1 && modificationOn % The primary COI
                        if ~missing
                            drawCOIDot(win, x, y, 35);
                        end
                    else
                        if ~missing && modificationOn % The secondary COI
                            drawCOIDot(win, x, y, 25);
                        end
                    end
                end
            % This was experimental code which may not work, to draw
            % a contrast dot with trails behind it.
           case 'contrastdottrails'
               trailLength = videoModifier.trailLength;
               if trailLength >= i
                   trailLength = i-1;
               end
               
               for j = (i-trailLength):i
                   if ~missing(j) && modificationOn
                       drawContrastDot(win, drawX(j), drawY(j));
                   end
               end
                
           % Artificial scotoma (pink noise, gaussian edges). Must be
           % initialized earlier.
           case 'scotoma'
                [x y missing] = getCOI(win, traceRecords(end), timeindex);
                if ~missing && modificationOn
                    drawScotoma(win, x, y, scotomaTex);
                end
                
            % Draw artificial scotoma on the screen, and a cross at the
            % second COI that's passed int
            case 'scotomadot'
                [x y missing] = getCOI(win, traceRecords(1), timeindex);
                x = x * destRect(3)/2560;
                y = y * destRect(4)/1440;                
                if ~missing
                    offset = sqrt((x-lastX)^2 + (y-lastY)^2);
                    if offset > videoModifier.movementThreshold 
                        drawX = x;
                        drawY = y;
                        lastX = x; lastY = y;
                    end
                end
                if ~missing && modificationOn
                    drawScotoma(win, drawX, drawY, scotomaTex);
                end
                [x y missing] = getCOI(win, traceRecords(2), timeindex);
                x = x * destRect(3)/2560;
                y = y * destRect(4)/1440;                
                if ~missing && modificationOn
                    drawCross(win, x, y, 30);
                end
                
            % Magnification bubble
            case 'bubbleMagnify'
                 [x y missing] = getCOI(win, traceRecords(1), timeindex);
                  if  ~modificationOn || missing
                      x = 10000;
                      y = -1000;
                  end
                 x = x * destRect(3)/2560;
                 y = y * destRect(4)/1440;                
                 if ~isfield(videoModifier,'bubbleFlatness')
                     videoModifier.bubbleFlatness = 0;
                 end
                 
                 
                drawMagnificationBubble(win, x, y, sObj, movieFrame, videoModifier.bubbleSize, videoModifier.MaxMag, x1*aspectRatioAdjustment,y1,videoModifier.bubbleFlatness, destRect);
                
            % This was experimental code which may not work, to draw
            % multiple magnification bubbles.
            case 'bubbleMultiMagnify'
                [x y missing] = getCOI(win, traceRecords(end-1), timeindex);
                [x2 y2 missing2] = getCOI(win, traceRecords(end), timeindex);
                if ~missing2 && modificationOn
                    x = [x; x2];
                    y = [y; y2];
                    
                end
                if  ~modificationOn || videoModifier.bubbleSize == 0 || videoModifier.MaxMag == 0
                    x = -100000;
                    y = -100000;
                end
                
               % drawMultiMagnificationBubble(win, x, y, sObj, movieFrame, videoModifier.bubbleSize, videoModifier.MaxMag, x1, y1, destRect);
 
            % Draw a ring centered on the COI            
            case 'ring'
                [x y missing] = getCOI(win, traceRecords(1), timeindex);
                 x = x * destRect(3)/2560;
                y = y * destRect(4)/1440;                
                 if modificationOn
                     drawRing(win, x, y, videoModifier.diameter, videoModifier.linecolor, videoModifier.linewidth)
                 end
           % Solid circle centered on the COI            
           case 'circle'               
                for i = 1:length(traceRecords)
                    [x y missing] = getCOI(win, traceRecords(i), timeindex);
                    if ~missing && modificationOn
                        drawCircle(win, x, y, videoModifier.diameter, videoModifier.fillcolor);
                    end
                end
           % Solid square centered on the COI            
            case 'square'               
                for i = 1:length(traceRecords)
                    [x y missing] = getCOI(win, traceRecords(i), timeindex);
                    if ~missing && modificationOn
                        drawSquare(win, x, y, videoModifier.diameter, videoModifier.fillcolor);
                    end
                end
           % Solid triangle centered on the COI            
           case 'triangle'               
                for i = 1:length(traceRecords)
                    [x y missing] = getCOI(win, traceRecords(i), timeindex);
                    if ~missing && modificationOn
                        drawTriangle(win, x, y, videoModifier.diameter, videoModifier.fillcolor);
                    end
                end
               
           otherwise
                error('Unknown method.')
        end
        
        drawingTimes = [drawingTimes toc];
        %%% These lines, when uncommented, can overlay information about the movie clip
            %    Screen('TextSize',win,36);
            %    Screen('DrawText', win, 'Schepens Eye Research Institute',1000,1020,[255 255 255]);
             %   Screen('DrawText', win, sprintf('%s src: %d, %d, %d, %d dest: %d, %d, %d, %d ', moviefilename, srcRect(1), srcRect(2), srcRect(3), srcRect(4), destRect(1), destRect(2), destRect(3), destRect(4)), 20, 100, [255, 255, 255]);
        
        % FLIP
        vbl=Screen('Flip', win);
        if writeOutMovie    
            Screen('AddFrameToMovie', win,destRect, [], outMovie);
            
            thisFrame=Screen('GetImage', win, destRect);
            writeVideo(newMovObj,thisFrame);
 
        
        end
        
        % Release the memory for this frame.
        Screen('Close',movieFrame);
    end
    
    % Also stop if the escape key is pressed
    [keyIsDown,secs,keyCode]=KbCheck;
    if (keyIsDown==1 && keyCode(esc))
        Screen('CloseMovie', movie); % close movie reader
        sca;
        error('Escape pressed');
    end
   
    % Space bar can temporarily hide the modification, when not in movie
    % output mode.
    if ~writeOutMovie
        if (keyIsDown==1 && keyCode(KbName('space')))
            if ~spaceDown
                modificationOn = ~modificationOn;
                spaceDown = true;
            end
        else
            spaceDown = false;
        end
    end
    
    ti = ti+1;
end;

%disp(sprintf('Number of frames shown: %d Framerate: %.2f',f,f/(GetSecs-t)));
Screen('CloseMovie', movie); % close movie reader

% Close the movie we're writing out to.
if writeOutMovie 
    Screen('FinalizeMovie', outMovie); 
end;

    
    close(newMovObj);
    


%--------------------------------------------------------------------------

function [x y missing] = getCOI(win, traceRecords, t)
% Compute the correct sample to use based on the time since the beginning
% of the movie (eyetracking data will typically have a different sample
% rate than a movie, so use the sample timestamps rather than assuming a certain rate)

missing = false;
x = 0;
y = 0;

if isempty(traceRecords)
    % An empty traceRecords is the sign to use the mouse as input.
    [x,y] = GetMouse(win);
else
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
end

%--------------------------------------------------------------------------

function drawYellowDot(win, x, y)
% Small yellow dot.

crect = [x-20 y-20 x+20 y+20];
Screen('FillOval',win, [255 255 0], crect);

%--------------------------------------------------------------------------

function drawContrastDot(win, x, y)
% Black dot with white ring around it.

outerRadius = 12;%25;
innerRadius = 10;%20;
crect = [x-outerRadius y-outerRadius x+outerRadius y+outerRadius];
Screen('FillOval',win, [255 255 255], crect);
crect = [x-innerRadius y-innerRadius x+innerRadius y+innerRadius];
Screen('FillOval',win, [0 0 0], crect);

%--------------------------------------------------------------------------

function drawCOIDot(win, x, y, outerRadius)
% Yellow dot with red ring around it.

if ~exist('outerRadius')
    outerRadius = 15;
end

innerRadius = 0.7 * outerRadius;
crect = [x-outerRadius y-outerRadius x+outerRadius y+outerRadius];
Screen('FillOval',win, [255 0 0], crect);
crect = [x-innerRadius y-innerRadius x+innerRadius y+innerRadius];
Screen('FillOval',win, [255 255 0], crect);


%--------------------------------------------------------------------------

function drawStdCircle(win, x, y, stdRad, linecolor)
% Red circle reflecting the stdev of the spread of traces at that time

if ~exist('linecolor')
    linecolor = [255 0 0];
end
circleRect = [0 0 stdRad*2 stdRad*2];
circleRect =  CenterRectOnPoint(circleRect, x, y);
Screen('FrameOval',win, linecolor, circleRect, 10);


%--------------------------------------------------------------------------

function drawRing(win, x, y, diameter, linecolor, linewidth)
% Yellow circle of fixed diameter around the COI

if ~exist('linecolor')
    linecolor = [255 255 0];
end
if ~exist('linewidth')
    linewidth = 10;
end
circleRect = [0 0 diameter diameter];
circleRect =  CenterRectOnPoint(circleRect, x, y);
Screen('FrameOval',win, linecolor, circleRect, linewidth);

%--------------------------------------------------------------------------

function drawCross(win, x, y, crossDiameter)
if ~exist('crossDiameter')
    crossDiameter = 15;
end
colour = [255 255 0];
penwidth = 4;
Screen('Drawline',win, colour, x, y-(crossDiameter/2), x, y+(crossDiameter/2), penwidth);
Screen('Drawline',win, colour, x-(crossDiameter/2), y, x+(crossDiameter/2), y, penwidth);

%--------------------------------------------------------------------------

function drawCircle(win, x, y, diameter, colour)
radius = diameter/2;
crect = [x-radius y-radius x+radius y+radius];
Screen('FillOval',win, colour, crect);

%--------------------------------------------------------------------------

function drawSquare(win, x, y, diameter, colour)
radius = diameter/2;
crect = [x-radius y-radius x+radius y+radius];
Screen('FillRect',win, colour, crect);

%--------------------------------------------------------------------------

function drawTriangle(win, x, y, diameter, colour)
radius = diameter/2;
pointList = [x y-radius; x-0.866*radius y+0.5*radius; x+0.866*radius y+0.5*radius];
Screen('FillPoly',win, colour, pointList, 1);


