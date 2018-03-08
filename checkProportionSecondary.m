secondaryFrames = [];

m = 100:100:1000;
for j = 1:length(m)
    for i = 1:200
        [coi nsamples eyeStds] = coiForVideo(i, m(j));
        secondaryFrames(i,j) = length(find(~coi(2).missing));
        disp(secondaryFrames(i,j));
    end
end
% 
% figure; myhistc(secondaryFrames/18,0:100); 
% xlabel('Percent time secondary bubble is present')
% ylabel('Number of videos');


figure;
boxplot(secondaryFrames/18, 'labels',100:100:1000);
set(gca,'FontSize',14)
xlabel('Minimum distance of secondary COI (pixels)');
ylabel('Percentage of time secondary is present');

set(gca,'YLim',[0 100]);