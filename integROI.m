function [croi variance maxi stdi]=integROI(etdata,destdims,sigma,mag)

%% get the kde
[kde dfield] =myKDE2(etdata,destdims,sigma);

% varFilterFunction = @(theBlockStructure) var(double(theBlockStructure.data(:)));
% blockyImagevar = blockproc(kde(:), blockSize, varFilterFunction);
% varianceImage=blockyImagevar(:);
% display(varianceImage);
variance = var(kde(:));
maxi = max(kde(:));
stdi = std(kde(:));

% define grid for the kde
[kdeh kdev]=meshgrid(1:destdims(1),1:destdims(2)); % destdims = [horz vert]

%define centers of magnification box (down and to right for even size mbox)
mbsz=([destdims(2) destdims(2)]/2); %[1440 1440]
kcnt=mbsz; 
magrect=[0 0 destdims(1)-mbsz(1) mbsz(2)];
[h v]=meshgrid(1:destdims(1),1:destdims(2));
hind=h(h(:)>=(ceil(mbsz(1)/2)+(1-mod(mbsz(1)/2,2))) & h(:)<=(destdims(1)-ceil(mbsz(1)/2)));
vind=v(v(:)>=(ceil(mbsz(2)/2)+(1-mod(mbsz(2)/2,2))) & v(:)<=(destdims(2)-ceil(mbsz(2)/2)));

minlength = min(length(hind), length(vind));
cntrs=[vind(1:minlength) hind(1:minlength)];
%cntrs=[vind hind];
 vind(minlength:end) = [];
 hind(minlength:end) = [];

%% integrate 
[croi val]=fminsearchbnd(@(cntrs) desum(kde,kdeh,kdev,magrect,mbsz,hind,vind,cntrs),...
                        kcnt,[min(hind) min(vind)],[max(hind) max(vind)]);
croi=round(croi);

b = kde';
[a c] = max(b(:));
maxy = c/destdims(1);

[a c] = max(kde(:));
maxx = c/destdims(2);

croi = [(croi(1,1)+maxx)/2 (croi(1,2)+maxy)/2 ];

function s=desum(kde,kdeh,kdev,magrect,mbsz,hind,vind,cntr)
% center the magnification rect ( rect = [horzUP vertUP horzDN vertDN]


cntmrect=CenterRectOnPoint(magrect,cntr(1),cntr(2)); % cntr = [horz vert]

% add one if even dims
cntmrect=round(cntmrect+[(1-mod(mbsz(1)/2,2)) (1-mod(mbsz(2)/2,2)) 0 0]);


cntmrect(find(~cntmrect)) =1;
cntmrect(cntmrect>size(kdeh,2))=size(kdeh,2);
cntmrect(cntmrect<0) =1;

s=-sum(sum(kde(cntmrect(2):cntmrect(4),cntmrect(1):cntmrect(3))));
