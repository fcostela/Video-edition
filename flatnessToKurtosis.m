function k = flatnessToKurtosis(f)
% Takes an intuitive measure of "flatness", that I made up, which ranges
% from 0 to 1, corresponding to normal distribution and uniform
% distribution respectively, and converts it to a kurtosis value that can
% be used with a pearson distribution to produce fatter or slimmer versions
% of normal functions.
%
% INPUT
%  f  flatness. Ranges from 0 to 1.
%
% OUTPUT
%  k  kurtosis value, defined in the usual way.

% Usage: k = flatnessToKurtosis(f)

k = exp(-4*f+1)/exp(1)*1.2+1.8;