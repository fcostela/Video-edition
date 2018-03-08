% A little demo showing how getCOI turns eyetracking data into a COI,
% including smoothing and picking which of two possible locii to focus on,
% over the course of one entire movie frame. You can use this to see the
% effect that tweaking the algorithm has. Blue crosses are eyelink sample,
% black line is computed COI.
%
% Usage: coiExampleVisualization

eyetrackDir = '/Users/danielsaunders/Free norm - eyetrack data';
whichVideoNumber = 194;

eyeTraces = loadTracesForVideo(whichVideoNumber, eyetrackDir);

frameRate = 24;
duration = 30;


frameInterval = 1000/frameRate;
frameTimes = 0:frameInterval:(duration*1000);


coi = coiForVideo(whichVideoNumber, 0, 1);
for i = 1:length(frameTimes)
    t = frameTimes(i);
    for j = 1:length(eyeTraces)
        [x(j,i) y(j,i) missing(j,i)] = getCOI(eyeTraces(j), t);
    end
    [cx(1,i) cy(1,i) cmissing(1,i)] = getCOI(coi(1), t);    
end


figure; subplot(2,1,1);
plot(x','+b','MarkerSize',4);
set(gca,'YLim',[20 2560]);
set(gca,'YTick',0:640:2560);
ylabel('X position');
hold on;
plot(cx(1,:),'k','LineWidth',3);
% plot(cx(2,:),'r','LineWidth',3);
% plot(cx(3,:),'c','LineWidth',3);
grid on;
set(gca,'XLim',[2 length(frameTimes)]);
title(sprintf('Video id = %d', whichVideoNumber));

subplot(2,1,2);
plot(y','+b','MarkerSize',4);
set(gca,'YLim',[20 1440]);
set(gca,'XLim',[2 length(frameTimes)]);
ylabel('Y position');
hold on;
plot(cy(1,:),'k','LineWidth',3);
% plot(cy(2,:),'r','LineWidth',3);
% plot(cy(3,:),'c','LineWidth',3);
set(gca,'YTick',0:360:1440);
grid on;

set(gcf, 'Position',[242         681        2089         684]);
xlabel('Movie frame');