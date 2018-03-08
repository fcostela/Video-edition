function contrastEnhancedIm = enhanceImageLocalMaxContrast(rgbIm, contrastStd, contrastFloor)
% Modify an image stored as an RGB array. 
% Local contrast enhancement.

if ~exist('contrastStd')
    contrastStd = 32;
end
if ~exist('contrastFloor')
    contrastFloor = 0;
end

if contrastStd == 0
    contrastEnhancedIm = rgbIm;
    return;
end

t = GetSecs;

rgbIm = maximizeSaturation(rgbIm);  t = [t GetSecs]; %1
contrastEnhancedIm=rgb2yuv(rgbIm);  t = [t GetSecs]; %2

% contrastEnhancedIm=rgb2hsv(rgbIm);

lumIm=contrastEnhancedIm(:,:,1); t = [t GetSecs]; %3 % extract lum (Y)
lumImSize=size(lumIm); t = [t GetSecs]; %4

[rmsIm meanIm]=localRMS(lumIm, contrastStd); t = [t GetSecs]; %5 % luminance and contrast distribution

% Adjustment to avoid the "wall texture" problem, by not recognizing
% contrasts that are below a certain level, and so not overadjusting them. 
rmsIm(find(rmsIm < contrastFloor)) = contrastFloor;

enhancedLumIm=lumIm-meanIm; % zero mean
% enhancedLumIm=lumIm;
enhancedLumIm=enhancedLumIm./rmsIm; t = [t GetSecs]; %6 % uniform RMS

[src1Vals src1Order]=sort(enhancedLumIm(:)); % sort pixels into ascending luminance order
enhancedLumIm(src1Order)=linspace(0,255,lumImSize(1)*lumImSize(2)); % prepare uniform distribution
enhancedLumIm=reshape(enhancedLumIm, lumImSize); t = [t GetSecs]; %7% convert image back to square

contrastEnhancedIm(:,:,1)=enhancedLumIm; % put flat contrast image back into color image
contrastEnhancedIm=yuv2rgb(contrastEnhancedIm); % convert colorspace image into RGB

t = [t GetSecs]; %8
t2 = diff(t);
% figure; bar(t2)