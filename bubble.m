function out = bubble(img, Parameters)

%This function generates a magnification "bubble" that has a flat-top region of uniform
%magnification and an annulus surrounding the flat-top region where the magnification gradually
%falls off to 1. Both the flat-top region and the outer edge of the annulus have the shape of a
%superellipse.

%INPUTS: 
%img = grayscale or RGB image 
%Parameters = a structure whose fields are: x0,y0,a,b,q,r,Mc,k.

%The first 6 fields (x0,y0,a,b,q,r) satisfy the superellipse equation: 
%       abs((x-x0)/a).^q + abs((y-y0)/b).^r = 1
%and define the superellipse bounding the flat-top region.

%The parameter Mc >= 1 specifies the magnification within the flat-top region of the bubble, while
%k>1 is a scalar that deterines the relative size of the superellipse that defines the outer edge of
%the bubble to the superellipse that defines the edge of the flat-top region.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%rename and recast
P=Parameters; x0=P.x0; y0=P.y0; a=P.a; b=P.b; q=P.q; r=P.r; Mc=P.Mc; k=P.k;
img=cast(img,'double');

%size of output image: FI
sz=size(img); 
if length(sz)==2; sz=cat(2,sz,1); end   % *** hack to allow RGB and grayscale input
FI=zeros(sz);   

%Indexes for flat-top superellipse FT and surrounding annulus SA
[X,Y] = meshgrid(-x0+1:sz(2)-x0,-y0+1:sz(1)-y0);    %Note Matlab loves to switch x and y!
[FT,SA] = deal(0.*X + 0.*Y);
FT((abs(X)./a).^q + (abs(Y)./b).^r <= 1) = 1;
SA(((abs(X)./a).^q+(abs(Y)./b).^r)>1 & ((abs(X)./(a)).^q+(abs(Y)./(b)).^r)<=k) = 1;

%Indexes for surrounding annulus
[J,I] = find(SA==1);
MSA = SA;

%Loop through RGB or grayscale
for zz=1:sz(3)
    CI = img(:,:,zz);    %current image
    
    %Magnify flat-top portion MFT
    MFT = interp2(X,Y,CI,X./Mc,Y./Mc);
    MFT(FT~=1)=0;
    
    %Minify surrounding annulus MSA.. for now this is in a slow for-loop
    for ii=1:length(I)
     
        z=(abs(I(ii)-x0)./a).^q+(abs(J(ii)-y0)./b).^r; %z tells us equation for (ii,jj)
        zc=(z-1)/(k-1);   %this is a scalar factor measured from the inner superellipse
        sf=1/Mc + (k-1/Mc)*zc;   %scalar on x and y coordinates
        MSA(J(ii),I(ii)) = CI(min(round(sf/z*(J(ii)-y0))+y0,size(CI,1)),min(round(sf/z*(I(ii)-x0))+x0,size(CI,2)));%CI(round(sf/z*(J(ii)-y0))+y0,round(sf/z*(I(ii)-x0))+x0);    
    end
    
    %Final image
    CIF=CI;
    CIF((abs(X)./a).^q + (abs(Y)./b).^r <= k) = 0;
    FI(:,:,zz) = CIF+MFT+MSA;
end

%Output
out.original_image = img;
out.final_image = FI;
out.Parameters = Parameters;

%Plots
% figure; imagesc(cast(img,'uint8')); title('original image'); axis equal 
% if sz(3)==1; colormap(gray); end
% figure; imagesc(cast(FI,'uint8')); title('image with bubble'); axis equal
% if sz(3)==1; colormap(gray); end
