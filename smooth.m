function r=smooth(v,a)
% r=smooth(v,a) smoothes vector v with kernel of ones(a,1) (moving average
% window of width a).

% Author: Niko Troje
% Date 22.10.2003
% Version 1.0

if a-2*floor(a/2)==0
	error('use only odd kernel');
	return;
	end
k=ones(1,a)/a;
h=conv(v,k);
r=h(length(k):(length(h)-length(k)+1));
n=(length(v)-length(r))/2;
s=size(r);
if s(1) > s(2)
	r=[r(1)+[-n:-1]*(r(n+1)-r(1))/n; r; r(end)+[1:n]*(r(end)-r(end-n))/n];
	else
	r=[r(1)+[-n:-1]*(r(n+1)-r(1))/n r r(end)+[1:n]*(r(end)-r(end-n))/n];
end;

