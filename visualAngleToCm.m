function size = visualAngleToCm(angle,distanceFromMonitor)
if nargin < 2
    distanceFromMonitor = 65;
end
% size is in cm

angle = angle / (180/pi);
angle = angle / 2; 
size = 2 * (tan(angle) * distanceFromMonitor);