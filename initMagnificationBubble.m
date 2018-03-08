function [x1 y1 sObj] = initMagnificationBubble(win,texid)
% Do all the setup for the magnification bubble. Should be called after the
% window is created.
%
% INPUT
%  win      An open window to write to.
%  texid    Just some dummy movie frame, I guess the first one, to get the
%           dimensions etc
%
% OUTPUT
%  x1,y1,sObj  Persistent variables that are used later to draw the bubble.
%
% Usage:   [x1 y1 sObj] = initMagnificationBubble(win,texid)

global GL;

winRect = Screen(win,'Rect');

CellStep=8;    % grain of tesselation
[m n] = Screen('WindowSize', win) % size of source movie frame in pixels
 
[gltexid gltextarget] = Screen('GetOpenGLTexture', win, texid); %operate on texture in video graphics

[X Y]=meshgrid([0:CellStep:m],[0:CellStep:n]); % create mesh for magnification surface
xC=X(:); % convert to vectors
yC=Y(:);
xA3=-(xC'-m/2) ;
yA3=yC'-n/2 ;
tri = delaunay(xA3,yA3); % generate triangular mesh for magnification suface
objs{1}.texcoords = [xC(:)'; yC(:)']; % parameters of magnification surface
objs{1}.quadfaces=[];
objs{1}.normals=[];
objs{1}.vertices=[xA3; yA3];
objs{1}.vertices = [objs{1}.vertices; zeros(1,size(objs{1}.vertices,2))];
objs{1}.faces=tri'-1;  

x1=objs{1}.vertices(1,:); % source vertices for image projection
y1=objs{1}.vertices(2,:);

sObj=objs{1}; % create source and destination objects
objs{2}=objs{1};

Screen('BeginOpenGL', win);
glBindTexture(gltextarget, gltexid);% Setup texture mapping for our face texture:
glEnable(gltextarget);
glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);    % Choose texture application function: It shall modulate the light reflection properties of the the objects surface:


 clear moglmorpher
% 
 moglmorpher('reset');% Reset moglmorpher:
 moglmorpher('ForceGPUMorphingEnabled', 1);
% 
for i=1:size(objs,2);% Add the OBJS to moglmorpher for use as morph-shapes:
    meshid(i) = moglmorpher('addMesh', objs{i});
end

ar=winRect(4)/winRect(3);% Get the aspect ratio of the screen, we need to correct for non-square pixels if we want undistorted displays of 3D objects:

glEnable(GL.LIGHT0);% Enable the first local light source GL.LIGHT_0. Each OpenGL implementation is guaranteed to support at least 8 light sources. 
glEnable(GL.LIGHTING);

glMatrixMode(GL.PROJECTION);% Set projection matrix: This defines a perspective projection,corresponding to the model of a pin-hole camera - which is a goodapproximation of the human eye and of standard real world cameras -- well, the best aproximation one can do with 3 lines of code ;-)

gluPerspective(25.0,1/ar,0.1,200.0);% Field of view is +/- 25 degrees from line of sight. Objects close than 0.1 distance units or farther away than 200 distance units get clipped away, aspect ratio is adapted to the monitors aspect ratio:

glMatrixMode(GL.MODELVIEW);% Setup modelview matrix: This defines the position, orientation and looking direction of the virtual camera:

glLoadIdentity;

glPointSize(1.0);% Set size of points for drawing of reference dots
glColor3f(0,0,0);
glLineWidth(1.0);% Set thickness of reference lines:

glPolygonOffset(0, -5);% Add z-offset to reference lines, so they do not get occluded by surface
glEnable(GL.POLYGON_OFFSET_LINE);

Screen('EndOpenGL', win);% Finish OpenGL setup and check for OpenGL errors:

