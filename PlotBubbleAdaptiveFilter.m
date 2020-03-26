%NEWPLOT Bubble adaptive filter
% script to apply dynamic bubble or zoom magnification based on kernel of
% gazes from viewers with normal vision
% 
% Francisco Costela 2020
% clear all

etPath='/Users/FranciscoCostela/Desktop/magnification/Videoclipeyetrackingdata';
movPath='/Users/FranciscoCostela/Desktop/magnification/ClipsForNorming/';
load 'video number lookup.mat'

% clip ids
clips = [13,23,25,33,35,43,45,53,55,63,65,73,75,83,85,93,95,103,105,115,123,125,135,145,155,165,175,185,195,199];


for c = 1:length(clips)
    
    vidNum = clips(c);
    disp(vidNum);
    
    % get ET data for all subjects that viewed this clip
    subs4Vid = find(videoNumbers == vidNum);
    load([etPath filesep eyetrackFiles{subs4Vid(1)}]);
    
    % get movie file name
    [pathstr name ext] = fileparts(movieFileName);
    name = strrep(name, '_c 2','');
    name = strrep(name, '_c','');
    movFile = fullfile([movPath filesep name '.mov']);
    
    
    %% read each frame of clip to matrix    
    if exist([ '/Users/FranciscoCostela/Desktop/bubble/' num2str(vidNum) '.mat'])
        load([ '/Users/FranciscoCostela/Desktop/bubble/' num2str(vidNum) '.mat']);
    else
        [movmat movobj]=doReadMovie(movFile);
        save([ '/Users/FranciscoCostela/Desktop/bubble/' num2str(vidNum) '.mat'], 'movmat', 'movobj');
    end
       
    
    %% Load CROI inferred from gaussian kernels
    load ([ '/Users/FranciscoCostela/Desktop/magnification/croisMedian/' num2str(vidNum) '.mat'] ); %123.mat' ;%187.mat';
   
    % Apply a low pass filter to smooth the data (it does not look so jittery)
    % n = 50; Wn = 0.01; b = fir1(n,Wn);
    % filter_croi_x = filter(b,1,xy(:,1));
    % filter_croi_y = filter(b,1,xy(:,2));    
    % croi(:,1) = filter_croi_x;
    % croi(:,2) = filter_croi_y;
    %
    % disp('Smoothing');
    smoothingWindow = 25;
    croi(:,1) = round(smooth(croi(:,1), smoothingWindow));
    croi(:,2) = round(smooth(croi(:,2), smoothingWindow));
    
    % Define final resolution
    destdims=[2560 1440];
    orig_destdims = [ size(movmat(1).cdata,2) size(movmat(1).cdata,1)];
    
    %% plot kde to video frame
    %screenRect = Screen('Rect', win);
    P.x0 = 20;
    P.y0 = 100;
    P.a = 160;% this is the size of the bubble
    P.b = 160;
    P.q = 10; %3.5; < looks more triangular; > looks more squarely
    P.r = 2.5;
    P.Mc = 2; % < less focus; > more magnification 2,3
    P.k = 2; < border more edgy ; > 2 not change mu
    
    % 1 or 2 feature edition (1==size, 2== magnification inside)
    for m=1:2
       
        if m ==1
            bubblecase = 'SizeVaried';
        else
            bubblecase = 'MagniVaried';
        end
        
        % Create video
        newMovObj=VideoWriter(['/Users/FranciscoCostela/Desktop/bubble/clips/' num2str(vidNum') '_bubbleFilter' bubblecase ]);
        newMovObj.FrameRate = length(movmat)/30; %movobj.FrameRate;
        open(newMovObj);
        %t0=clock;
        magni = [];
        sizei = [];
        
        % Obtain local values in first iteration related to the maximum
        for i=1:length(movmat)-2
            
            switch(m)
                case 1
                    % size is a function depending of the proportion with
                    % the maximum
                      sizei(i) = 180 * maxi(i)/max(maxi);                    
                      magni(i) = 2; 
                case 2
                   
                      % Magnification is a function depending of the
                      % proportion with the maximum
                      sizei(i) = 170;                     
                      magni(i) = 2.5 *  maxi(i)/max(maxi); 
                      if magni(i) < 1
                          magni(i) = 1;
                      end                          
            end            
        end
        
        % Need to smooth the signal (otherwise is too jittery)
        sizei = sgolayfilt(sizei,3,41);
        magni = sgolayfilt(magni,3,41);

        
        for i=1:length(movmat)-2
            
            switch(m)
                case 1
                    P.a = sizei(i);
                    P.b = sizei(i);
                    P.Mc = 2.5;
                   
                case 2
                    P.a = 170;
                    P.b = 170;
                    P.Mc = magni(i); 
                    if P.Mc < 1
                        P.Mc = 1;
                    end                          
            end
            
            % Coordinates are based on the location of the CROI
            P.x0 = round( orig_destdims(1) * ( croi(i,1)/destdims(1)) );
            P.y0 = round( orig_destdims(2) * ( croi(i,2)/destdims(2)) );
           
            % Grab frame 
            frame=movmat(i).cdata;
            frame=cast(frame,'double');
           
            % Create the bubble with the parameters calculated on the
            % current frame
            MBim=bubble(frame,P);            
          
            % Write video frame
            frobj.cdata=uint8(round(MBim.final_image));
            frobj.colormap=[];
            writeVideo(newMovObj,frobj);
        end
    end
    close(newMovObj);
    
end
