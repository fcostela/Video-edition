function drawMultiMagnificationBubble(win, x, y, sObj, texid, bubbleSize, MaxMag, x1,y1,destRect)
global GL;

GlobalScale=.0108; % scaling factor for openGL

if exist('destRect')
    srcRect = Screen(texid,'Rect');
    GlobalScale = GlobalScale * (RectWidth(destRect)/RectWidth(srcRect)); 
end

winRect = Screen(win,'Rect');

mx1=-(x(1)-(winRect(3)/2));
my1=-((winRect(4)/2)-y(1));

if exist('destRect')
    mx1 = mx1/(RectWidth(destRect)/RectWidth(srcRect));
    my1 = my1/(RectWidth(destRect)/RectWidth(srcRect));
end    

dist1=sqrt((x1-mx1).^2+(y1-my1).^2); % create bubble on mouse (eye) position)
scalar1=(1+(MaxMag-1).*exp(-(dist1.^2)./(2*bubbleSize.^2)));
mag=dist1.*scalar1;
ang1=atan2((y1-my1),(x1-mx1));
x3=mx1+(mag.*cos(ang1));
y3=my1+(mag.*sin(ang1));

%% This section draws the second bubble, if called for.
% if length(x) > 1
%     x1 = x3;
%     y1 = y3;
%     
%     mx1=-(x(2)-(winRect(3)/2));
%     my1=-((winRect(4)/2)-y(2));
%     
%     if exist('destRect')
%         mx1 = mx1/(RectWidth(destRect)/RectWidth(srcRect));
%         my1 = my1/(RectWidth(destRect)/RectWidth(srcRect));
%     end
%     
%     dist1=sqrt((x1-mx1).^2+(y1-my1).^2); % create bubble on mouse (eye) position)
%     scalar1=(1+(MaxMag-1).*exp(-(dist1.^2)./(2*bubbleSize.^2)));
%     mag=dist1.*scalar1;
%     ang1=atan2((y1-my1),(x1-mx1));
%     x3=mx1+(mag.*cos(ang1));
%     y3=my1+(mag.*sin(ang1));
%     
% end
%%

y3 = -y3;

%  figure; plot(x3,y3);

sObj.vertices=[-x3;y3]; % update triangultion vertices
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
