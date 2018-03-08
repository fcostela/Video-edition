function blinkless = removeBlinks(eyetrackRecord)
% A function to allow by-hand identification and interpolation across
% missing data in a particular eyetrackRecord, e.g. for use when making
% demos. Click at the horizontal coordinates on either side of the missing
% regions that you see in the plot (y coordinate doesn't matter), and when
% done, press enter.
%
% blinkless = removeBlinks(eyetrackRecord)

figure;
x = eyetrackRecord.x;
y = eyetrackRecord.y;
plot(y);
set(gca,'YLim',[0 1500]);
set(gca,'XLim',[1 length(eyetrackRecord.x)]);
set(gcf,'Position',[105         395        2432         663]);
set(gca,'Position',[0 0.1 1 0.9]);

while 1
    [a b] = ginput(2);
    if isempty(a) break; end;
    a = round(a);
    blinkstart = a(1);
    blinkend= a(2);
    if blinkstart > blinkend
        d = blinkstart;
        blinkstart = blinkend;
        blinkend = d;
    end
    y(blinkstart:blinkend) = interp1([blinkstart blinkend], [y(blinkstart) y(blinkend)], blinkstart:blinkend); 
    x(blinkstart:blinkend) = interp1([blinkstart blinkend], [x(blinkstart) x(blinkend)], blinkstart:blinkend); 
    set(get(gca,'children'),'YData',y);
    refresh
end
close
blinkless.x = x;
blinkless.y = y;
blinkless.t = eyetrackRecord.t;
blinkless.missing = zeros(1,length(x));