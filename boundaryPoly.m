function g = boundaryPoly(meshx, meshy, centerx, centery, scalingFactor)
boundary = [min(meshx) min(meshy) max(meshx) max(meshy)];




 x  = meshx - centerx;
 y  = meshy - centery;
 
 
if ~exist('scalingFactor')
    scalingFactor = 1;
end

aspectRatio = max(meshx) / max(meshy);

mystd = 20;
% a = 1 / (2*pi*std^2);

g =  exp(-0.5*((x.^2)/(mystd^2)+(y.^2)/(mystd^2)));
% figure; surf(g)

% Top left
std1 = [0.5*(centerx-min(meshx))/aspectRatio 0.5*(max(meshy)-centery)]* scalingFactor;
g1 =  exp(-0.5*((x.^2)/(std1(1)^2)+(y.^2)/(std1(2)^2)));

% Top right
std2 = [0.5*(max(meshx)-centerx)/aspectRatio 0.5*(max(meshy)-centery)]* scalingFactor;
g2 =  exp(-0.5*((x.^2)/(std2(1)^2)+(y.^2)/(std2(2)^2)));

% Bottom left
std3 = [0.5*(centerx-min(meshx))/aspectRatio 0.5*(centery - min(meshy))]*scalingFactor;
g3 =  exp(-0.5*((x.^2)/(std3(1)^2)+(y.^2)/(std3(2)^2)));

% Bottom right
std4 = [0.5*(max(meshx)-centerx)/aspectRatio 0.5*(centery - min(meshy))]*scalingFactor;
g4 =  exp(-0.5*((x.^2)/(std4(1)^2)+(y.^2)/(std4(2)^2)));

g(x < 0 & y > 0) = g1(x < 0 & y > 0);
g(x > 0 & y > 0) = g2(x > 0 & y > 0);
g(x < 0 & y < 0) = g3(x < 0 & y < 0);
g(x > 0 & y < 0) = g4(x > 0 & y < 0);
