function [kdenorm dfield]=myKDE2(data,dims,sigma)
% kdenorm=myKDE2(data,dims,sigma)
% Creates estimate of the pdf for 2D data set
% by convolution with a bivariate Gaussian kernel
% data = Nx2 matrix of coordinates for each data point
% dims = 1x2 vec ([vert horz]) with dimensions of data set
% sigma = SD of the kernel

% create 2D data array 
dfield=zeros([dims(2) dims(1)]);
% get indices for data within the array
data=round(data); % round to the nearest 'pixel'
data(~data)=1;
dataind=sub2ind(size(dfield),data(:,2),data(:,1)); % data = [horz vert]
% get frequency of data at each point
% (tried hist3, this is faster)
for i=1:length(dataind)
    dfield(dataind(i))=dfield(dataind(i))+1;
end

% define grid for the kernel
[gridh gridv]=zeroCentGrid(dims(1),dims(2));
% covariance matrix for the kernel
C=sigma^2*eye(length(dims));
% make the kernel using the multivariate normal probabilty density function
krn=2*pi*sigma*mvnpdf([gridv(:) gridh(:)],[0 0],C);
krn=reshape(krn,size(gridh));

% do the kde -- fast fourier transform
kde=real(fftshift(ifft2(fft2(dfield).*fft2(krn))));

% get differential for integrating
% (assumes grid with equal horz and vert steps)
deltx=gridv(2,1)-gridv(1,1); 
% integrate the kde
kde_int=deltx^2*sum(kde(:)); 
% normalize to get pdf
normalizing_c=1./kde_int; 
%normalizing_c=1; %...or don't normalize
kdenorm=normalizing_c*kde;
