clear all; % clear open variables
% moviename='/Users/peterbex/Documents/movies/Inglorious/3.mp4'; % path to your movie here...
moviename='movie.mov'; % path to your movie here...

AssertOpenGL; % enable openGL
whichScreen=max(Screen('Screens')); % display on experimental screen 
Screen('Preference','SkipSyncTests', 1); % don't worry about PTB warnings etc.
Screen('Preference','VisualDebugLevel', 1);

% Open a double-buffered full-screen window on the main displays screen.
PsychImaging('PrepareConfiguration'); % set up PTB image processing
[window winRect] = PsychImaging('OpenWindow',whichScreen,127,[200 200 740 500],32,2, [], [], kPsychNeedFastBackingStore); % open fast buffered window

InitializeMatlabOpenGL([], [], 1); % set up PTB openGL

filtKernel=fspecial('gaussian',[21 21],25); % set up blurring filter
% filtKernel=fspecial('log',[7 7],.5); % alternative band-pass filters
% filtKernel = fspecial('unsharp', 1); % alternativ sharp filter
convoperator = CreateGLOperator(window, kPsychNeed32BPCFloat); % enable convolution on graphic card
Add2DConvolutionToGLOperator(convoperator, filtKernel); % imolement our filter
glFinish; % done setting up openGL

vbl = Screen('Flip', window); % switch to buffer and start frame synching

movie=Screen('OpenMovie', window, moviename); % Open movie file, get a handle to the movie
Screen('PlayMovie', movie, 1, 0, 1); % start playback

texid = Screen('GetMovieImage', window, movie); % get first movie frame
[xSize ySize] = Screen('WindowSize', texid); % size of each frame for screen playback

offScreenRect=SetRect(0,0,xSize,ySize); % size of frame from movie
onScreenRect=CenterRect(offScreenRect,winRect); % here you can change on screen size etc.
xtex = 0; % dummy start
% Run playback loop until key pressed:
while (1)
    texid = Screen('GetMovieImage', window, movie); % get next movie frame
    if texid<=0; break; end;% Could not grab frame - abort  
    xtex = Screen('TransformTexture', texid, convoperator, [], xtex); % convolve frame (as texture) with filter
    Screen('DrawTexture', window, xtex, offScreenRect, onScreenRect); % draw convolved image to screen
    vbl = Screen('Flip', window, vbl); % switch to next image
    Screen('Close', texid); % close this texture, ready for next
    if KbCheck; break; end;% Abort on keypress
end

Screen('CloseMovie', movie); % close movie reader
Screen('CloseAll'); % close screen