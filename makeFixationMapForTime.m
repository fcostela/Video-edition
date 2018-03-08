% Script to output and write to a file the fixation map for a particular
% time in one of the movie clips. 
%
% Usage: makeFixationMapForTime

whichvid = 20;
time = 10000;

vidNames = {'Cloud_13a',	'CORAL_14a',	'MULAN_11a',	'GERIS_a',	'SHREK_5b',	'DEEPB_5b',	'MICRO_11a',	'FOODI_2b',	'MARCH_10a',	'WINGE_21a',	'AMAZI_20a',	'APPAL_10a',	'HESJU_30a',	'JULIE_10a',	'LARS_12a',	'OCTOB_7a',	'SHAKE_20a',	'HURT_5a',	'BOOKC_15a',	'SQUID_8a'};
vidIds = [1	10	15	20	30	45	56	52	62	77	88	92	127	131	137	159	171	185	187	196];
widths =  [853	853	806	796	853	853	794	850	853	851	851	853	853	853	851	853	846	853	851	839];
heights = [480	460	480	468	368	466	480	480	480	460	472	360	360	462	472	364	372	480	478	462];

whichVideoNumber = vidIds(whichvid);
width = widths(whichvid);
height = heights(whichvid);

fixationMap = fixationMapForTime(whichVideoNumber, width, height, time);

figure; imagesc(fixationMap); axis equal; axis([0 width 0 height]);
c = colormap;
fixationMap = fixationMap / (max(max(fixationMap)));
fixationMap = fixationMap * 64;
imwrite(fixationMap,c, 'fixationMap.png','PNG')