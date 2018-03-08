function outputEnhancedMovie(moviename, width, height, outputFileName, enhanceParams, singleImageOutput)
%
% INPUT
%  moviename        Full path of the movie to apply it to.
%  width, height    Dimensions of the movie
%  outputFileName   Filename to output to.
%  enhanceParams    A struct specifying the enhancement type and
%                   parameters. See the switch statement for types.
%  singleImageOutput If true, just apply to the first frame and output as a
%                   png, then quit.
%  
% Usage: outputEnhancedMovie(moviename, width, height, outputFileName, enhanceParams, singleImageOutput)


if ~exist('singleImageOutput') 
    singleImageOutput = 1;     
end
    
InitializeMatlabOpenGL([], [], 1); % set up PTB openGL
 
whichScreen=max(Screen('Screens')); % display on experimental screen
Screen('Preference','SkipSyncTests', 1); % don't worry about PTB warnings etc.
Screen('Preference','VisualDebugLevel', 1);
oldLevel = Screen('Preference', 'Verbosity', 0);

% Open a double-buffered full-screen window on the main displays screen.
PsychImaging('PrepareConfiguration'); % set up PTB image processing
Screen('Preference', 'VisualDebugLevel', 0);
[window winRect] = PsychImaging('OpenWindow', whichScreen,127,[200 200 width+200 height+200],32,2, [], [], kPsychNeedFastBackingStore); % open fast buffered window


% Set up blurring
if isfield(enhanceParams,'blurSD') && enhanceParams.blurSD > 0
    windowWidth = (floor((enhanceParams.blurSD*3)/2)*2)+1;
    filtKernel=fspecial('gaussian',[windowWidth windowWidth],enhanceParams.blurSD); % set up blurring filter
    % filtKernel=fspecial('log',[7 7],.5); % alternative band-pass filters
    % filtKernel = fspecial('unsharp', 1); % alternativ sharp filter
    convoperator = CreateGLOperator(window, kPsychNeed32BPCFloat); % enable convolution on graphic card
    Add2DConvolutionToGLOperator(convoperator, filtKernel); % imolement our filter
    glFinish; % done setting up openGL
end


outMovie = Screen('CreateMovie', window, outputFileName, width, height, 24,'EncodingQuality=0.7');
% outMovie = Screen('CreateMovie', window, outputFileName, width, height, 24,':CodecFOURCC=H264');

vbl = Screen('Flip', window); % switch to buffer and start frame synching

movie=Screen('OpenMovie', window, moviename); % Open movie file, get a handle to the movie
Screen('PlayMovie', movie, 0, 0, 1); % start playback


texid = Screen('GetMovieImage', window, movie); % get first movie frame
[xSize ySize] = Screen('WindowSize', texid);  % size of each frame for screen playback

offScreenRect=SetRect(0,0,xSize,ySize); % size of frame from movie
onScreenRect=winRect; %CenterRect(offScreenRect,winRect); % here you can change on screen size etc.
xtex = 0; % dummy start
% Run playback loop until key pressed:
g = 0;
while (1)
    texid = Screen('GetMovieImage', window, movie); % get next movie frame
    if texid<=0; break; end;% Could not grab frame - abort
    
    imageArray=Screen('GetImage', texid); 
    % Enhance this frame
    switch enhanceParams.type
        case 'messedUp'
            imageArray = messedUpImage(imageArray);
        case 'bipolar'
            imageArray = enhanceImageBipolarEdges(imageArray, enhanceParams.sigma, enhanceParams.thresh);
        case 'localContrast'
            imageArray = enhanceImageLocalMaxContrast(imageArray, enhanceParams.contrastSD, enhanceParams.contrastFloor);
        case 'brighten'
            imageArray = brightenImage(imageArray);
    end
        
    Screen('PutImage', texid, imageArray); 
    
    if isfield(enhanceParams,'blurSD') && enhanceParams.blurSD > 0
        texid = Screen('TransformTexture', texid, convoperator);
    end
    
    if singleImageOutput
        imageArray = Screen('GetImage', texid); 
        imwrite(imageArray,outputFileName,'PNG');
    else
        Screen('DrawTexture', window, texid, offScreenRect, onScreenRect);
        vbl = Screen('Flip', window, vbl); % switch to next image
        Screen('AddFrameToMovie', window);
    end
    Screen('Close', texid); % close this texture, ready for next
%     if KbCheck; break; end;% Abort on keypress
    g = g+1;

    if singleImageOutput
        break;
    end
    
end

Screen('CloseMovie', movie); % close movie reader
Screen('FinalizeMovie', outMovie);
Screen('CloseAll'); % close screen