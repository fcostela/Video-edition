% An example of how you can use coi workshop routines (eventually calling
% on playMovieWithTraces and outputEnhancedVideo) to process videos. This
% computes a center of interest datastream for each video, and then outputs
% it magnified around that coi and then blurred (in separate files).

Screen('Preference', 'SkipSyncTests', 1);

p = genpath('/Users/danielsaunders/COI workshop');
addpath(p);

oldLevel = Screen('Preference', 'Verbosity', 0);   
vidNames = {'Cloud_20a',	'CORAL_8a',	'Shrek_13b',	'SIMPS_17a',	'DEEPB_5a',	'FOODI_6a',	'MARCH_14a',	'WINGE_15a',	'ADVEN_18a',	'APPAL_2a',	'BURY_15a',	'EASTE_2a',	'FREED_8a',	'JULIE_18a',	'MARGO_4b',	'NANN_6a',	'PAYIT_3a',	'SHAKE_8c',	'STARD_7a',	'SQUID_4a'};
vidIds = [4    14    24    34    44    54    64    74    84    94   104   114   124   134   144   154 164   174   184   194];
width =  [852 852	852	852 852	   852      852     852     852	852	852 840     852	852	852	852	852	844	852	840];
height = [480 460	368	354 466	   480      480     460     468	360	480 460     480	462	480	354	480	372	356	462];

eyetrackDir = '/Users/danielsaunders/Free norm - eyetrack data/';
videoDir = '/Users/danielsaunders/Free norm - video clips/';
zoomoutdir = '';
bluroutdir = '';


%%% Zoom enhancement parameters

numSteps = 1;
minMag = 2;
maxMax = 2;
mags = linspace(minMag, maxMax, numSteps);

%%% Blur parameters

blurLevels = [ 20];

for j = 1:length(vidNames)
    t = GetSecs;
    [coi nsamples eyeStds] = coiForVideo(vidIds(j));
    vidfile = vidNames{j};
    save temp.mat;
    
    for i = 1:length(mags)
        % Create the zoomed video
        
        zoomoutname = sprintf('%s%s_%d.mov', zoomoutdir, vidfile, mags(i)*10);
        moviefilename = sprintf('%s%s.mov', videoDir, vidfile);
        
        outputZoomVideo(moviefilename, coi, mags(i), width(j), height(j), zoomoutname)
        disp(sprintf('%s.mov\t%d\t%d', vidfile, width(j), height(j)));
        
%         % Blur the video
        
        bluroutname = sprintf('%s%s_%d_b.mov', bluroutdir, vidfile, mags(i)*10);
        
        outputBlurredVideo(blurLevels(1), zoomoutname, width(j), height(j), bluroutname);
        clear all;
        load temp.mat
    end
    fprintf('Time for processing video: %.1f s',GetSecs - t);
end
sca;
