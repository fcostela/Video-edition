cd('/Users/FranciscoCostela/Desktop/magnification')

vidNum=30;
etPath='/Users/FranciscoCostela/Desktop/magnification/Video clip eyetracking data';
movPath='/Users/FranciscoCostela/Desktop/magnification/ClipsForNorming';

load 'video number lookup.mat'

% get ET data for all subjects that viewed this clip
subs4Vid = find(videoNumbers == vidNum);
for i = 1:length(subs4Vid)
    load([etPath filesep eyetrackFiles{subs4Vid(i)}]);
    temp.x = eyetrackRecord.x;
    temp.y = eyetrackRecord.y;
    temp.t = eyetrackRecord.t;
    temp.missing = eyetrackRecord.missing;
    etData(i) = temp;
end

% get movie file name
[pathstr name ext] = fileparts(movieFileName);
name = strrep(name, '_c 2','');
name = strrep(name, '_c','');
movFile = fullfile([movPath filesep name ext]);


%% read each frame of clip to matrix
 [movmat movobj]=doReadMovie(movFile);

%% get all eye positions from all subjects for each frame
subind=[1:length(etData)];
frametime=1000*linspace(0,30,length(movmat));
etAll=cell(length(frametime)-1,1);
sdims=[2560 1440]; % hor x vert
for sub=1:length(etData) % each subject
    % sort coords and time data
    etxy=[etData(sub).x' etData(sub).y'];
    ettime=etData(sub).t';
    % trim coords that are outside of screen
    indx=etxy(:,1)>=0 & etxy(:,1)<=sdims(1);
    indy=etxy(:,2)>=0 & etxy(:,2)<=sdims(2);
    etxy=etxy((indx+indy)>=2,:);
    % trim time indices
    ettime=ettime((indx+indy)>=2,:);
    % get time elapsed since beginning of clip
    % for each recorded eye position
    eltime=ettime-ettime(1);
    eltime=eltime(1:end-1);
    % detect and replace saccades
    [etxy_new sacind]=detectSaccades(etxy,eltime);
    for i=1:length(frametime)-1 % each frame
        etind=find(eltime>=frametime(i) & eltime<frametime(i+1));
        etAll{i}=vertcat(etAll{i},[etxy_new(etind,1) etxy_new(etind,2)]);
    end
end

%% integrate the kdes over each frame
t0=clock;
destdims=sdims;
sigma=400;
mag=2;
croi=zeros(length(etAll),2);
for i=1:length(etAll)
    [croi(i,:) val]=integROI(etAll{i},destdims,sigma,mag);
end
tend2=etime(clock,t0)
%% save the centers
save(['cROIs_' num2str(vidNum) '_sig' num2str(sigma)],'croi')