% A nice little test of the bubble magnification. The mouse controls the
% position (though not 1 to 1) and the arrow keys change the size and
% magnification. Clicking exits.


% moviename= '/Users/FranciscoCostela/Video magnification/JULIE_14a_c.mov'; % path to movie
% moviename= '/Volumes/pelilab/Images & Videos/Videos/TV with LV/Compressed Clips/FORGE_14a_c.mov';
moviename= '/Users/FranciscoCostela/Desktop/magnification/ClipsForNorming/MULAN_19a.mov';


% global win;

bubbleSize=45;        % starting size of bubble
maxMag=2;       % starting magnification of bubble's peak

screenid=max(Screen('Screens')); % choose highest screen # if multi-screen
Screen('Preference','SkipSyncTests',1); % skip synch tests
InitializeMatlabOpenGL(0,1); % initialize

[win , winRect] = Screen('OpenWindow', screenid, 0, [], [], []); % open screen
% HideCursor;   

movie=Screen('OpenMovie', win, moviename); % open movie and start reading fames
Screen('PlayMovie', movie, 1, 1, 1); % play at standard size and speed, with sound

KbName('UnifyKeyNames'); % same response keys across platforms
rightKey = KbName('RightArrow'); % arrow response keys adjust bubble params
leftKey = KbName('LeftArrow');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
escKey = KbName('ESCAPE'); % restore defaults

texid = Screen('GetMovieImage', win, movie); % grab 1st movie frame (to set up size parameters)
[x1 y1 sObj] = initMagnificationBubble(win,texid);

ifi = Screen('GetFlipInterval', win);% Retrieve duration of a single monitor flip interval: Needed for smooth animation.

vbl=Screen('Flip', win);% Initially sync us to the VBL:

waitframes = 2;

memoryUsage = [];

t = GetSecs;% Animation loop: Run until mouse press or one minute has elapsed...
while ((GetSecs - t) < 240)
%     memoryUsage = [memoryUsage getFreeMemory];
    [mx, my, buttons]=GetMouse(screenid); % current mouse location (or eye if gaze-contingent)
    
    [keyIsDown,timeSecs,keyCode] = KbCheck;         % check if user adjusts settings
    if keyCode(upKey); maxMag=maxMag*1.1 ;   end    % increase magnification
    if keyCode(downKey); maxMag=maxMag/1.1 ;   end  % reduce magnification
    if keyCode(leftKey); bubbleSize=bubbleSize/1.1 ;   end      % increase magnification area
    if keyCode(rightKey); bubbleSize=bubbleSize*1.1 ;   end     % reduce magnification area       
    if keyCode(escKey); bubbleSize=45; maxMag=3;  end     % restore defaults;


    FlushEvents('keyDown');
    
    texid = Screen('GetMovieImage', win, movie); % read next movie frame
    drawMagnificationBubble(win, mx, my, sObj, texid, bubbleSize, maxMag, x1,y1);

    if any(buttons)
        break;
    end
                   Screen('TextSize',win,36);
    Screen('DrawText', win, sprintf('BubbleSize = %.1f  Max mag = %.1f',bubbleSize, maxMag),1000,1320,[255 255 255]);
   
    vbl = Screen('Flip', win, vbl + (waitframes - 0.5) * ifi);
    Screen('Close',texid);
end

Screen('CloseAll');% Close onscreen window and release all other ressources:
ShowCursor;
% hold on; plot(memoryUsage);

return

