function edgeOverlayIm = enhanceImageBipolarEdges(rgbIm, sigma, thresh)
% Modify an image stored as an RGB array. 
% Add bipolar (black and white) edges to the scene. 

if exist('sigma') ~= 1 sigma=2.0;  end % standard deviation of Laplacian of gaussian filter - "line thicknes"
if exist('thresh') ~= 1 thresh=0.5;  end % threshold for edge cut-off - "# lines"

if sigma == 0 || thresh == 0
    edgeOverlayIm = rgbIm;
    return;
end

%------------Filter image
grayIm=double(rgb2gray(rgbIm)); % grayscale image for filtering
H=fspecial('log', ceil([6*sigma 6*sigma]), sigma);   % create LoG filter kernel
filtIm=imfilter(grayIm, -H, 'replicate');            % use wrapped pixel values at edges
%------stretch histogram
workingIm=(filtIm); % assign filtered image to temporary image
workingIm(filtIm>2*std(filtIm(:)))=std(filtIm(:)); % clip extreme pixels (>2 standard thudeviations)
workingIm(filtIm<-2*std(filtIm(:)))=-std(filtIm(:));
filtIm=workingIm; % reassign clipped image

%--------Pull out edges
workingIm=zeros(size(filtIm)); % blank working image
workingIm(filtIm<(-thresh*std(filtIm(:))))=-1; % pixels below threshold set to -1
workingIm(filtIm>( thresh*std(filtIm(:))))=1; % pixels above threshold set to 1
%--------Build edge overlay image
edgeOverlayIm=rgbIm; % assign to source RGB image
for rgbIndex=1:3 % work through 3 RGB layers
    tmpArray=edgeOverlayIm(:,:,rgbIndex); % pull out rgb layer
    tmpArray(workingIm==1)=255; % assign white for positive edges
    tmpArray(workingIm==-1)=0; % assign black for negative edges
    edgeOverlayIm(:,:,rgbIndex)=tmpArray; % replace edge overlaid image into RGB enhanced image
end
