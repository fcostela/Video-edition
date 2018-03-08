function rgbIm = messedUpImage(rgbIm)
% Modify an image stored as an RGB array. 
% Just for fun, mess up all the colours.

hsvIm = rgb2hsv(rgbIm);
hsvIm(:,:,2) = 1;
% hsvIm(:,:,1) = rand; %(size(hsvIm,1),size(hsvIm,2));
rgbIm = uint8(hsv2rgb(hsvIm)*255);
