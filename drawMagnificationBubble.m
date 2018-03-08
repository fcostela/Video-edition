function drawMagnificationBubble(win, x, y, sObj, texid, bubbleSize, MaxMag, x1,y1, bubbleFlatness, destRect)
% Actually draw the bubble magnified image on the screen buffer (still needs a flip).
%                 drawMagnificationBubble(win, x, y, sObj, movieFrame, videoModifier.bubbleSize, videoModifier.MaxMag, x1*aspectRatioAdjustment,y1,videoModifier.bubbleFlatness, destRect);

% INPUT
%  win      An open window we can draw to.
%  x,y      Coordinates to draw the bubble on, in pixels.
%  sObj     Persistent stuff that is initialized in initMagnificationBubble
%  texid    The image to apply the bubble magnification to. A texture map.
%  bubbleSize Standard deviation of the bubble, in pixels
%  MaxMag   Magnification of the bubble at the peak.
%  x1, y1   More persistent stuff that is set up (the basic grid)
%  bubbleFlatness   Number from 0 to 1 to make the bubble flatter on top (0
%                   is the normal gaussian shape)
%  destRect The size of the window we're drawing it in. 
%
% Usage: drawMagnificationBubble(win, x, y, sObj, texid, bubbleSize, MaxMag, x1,y1, bubbleFlatness, destRect)
global GL;
if ~exist('bubbleFlatness')
    bubbleFlatness = 0;
end

GlobalScale= 3;%.0308; % scaling factor for openGL



if exist('destRect')
    srcRect = Screen(texid,'Rect');
    %GlobalScale = GlobalScale * (RectWidth(destRect)/RectWidth(srcRect)); 
end

winRect = Screen(win,'Rect');
mx1=-(x-(winRect(3)/2));
my1=-((winRect(4)/2)-y);



if RectHeight(winRect) < 400
    GlobalScale = GlobalScale * 1.4;
else
    GlobalScale = GlobalScale * 1.05;
end

if exist('destRect')
    mx1 = mx1/(RectWidth(destRect)/RectWidth(srcRect));
    my1 = my1/(RectHeight(destRect)/RectHeight(srcRect));
end    

 
[x3 y3] = applyBubbleToMesh(x1, y1, mx1, my1, MaxMag, bubbleSize,bubbleFlatness);
%[x3 y3] = applyBoundaryMagToMesh(x1, y1, mx1, my1, MaxMag, 0.7);
y3 = -y3;

% figure; plot(x3,y3);

sObj.vertices=[-x3;y3]; % update triangultion vertices
sObj.vertices=  [sObj.vertices; zeros(1,size(sObj.vertices,2))];
meshid(2) = moglmorpher('addMesh', sObj);

[gltexid gltextarget] = Screen('GetOpenGLTexture', win, texid);

Screen('BeginOpenGL', win);
glBindTexture(gltextarget, gltexid);
glEnable(gltextarget);
glScalef(GlobalScale,GlobalScale,GlobalScale);
moglmorpher('render');
glLoadIdentity;
gluLookAt(-0, 0, 35, 0, 0, 0, 0, 1, 0);
glClear(GL.DEPTH_BUFFER_BIT);
Screen('EndOpenGL', win);

Screen('DrawingFinished', win);
moglmorpher('computeMorph', [1 0]);
