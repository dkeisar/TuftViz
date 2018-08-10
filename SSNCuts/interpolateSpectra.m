function S = interpolateSpectra(testPosition,supPixPosition,supPixVals)
% interpolateSpectra: interpolate spectral data according to nearby
%   superpixels
% usage: S = interpolateSpectra(testSpectra,supPixSpectra,supPixVals)
%
% arguments:
%   testPosition (Kx2) - spatial coordinates of each of K points to be 
%       interpolated
%   supPixPosition (Mx2) - 2-dimensional mean spectral values for each of M
%       superpixels
%   supPixValues (MxN) - N-dimensional values at each superpixel
%
%   S (KxN) - interpolated N-dimensional values at each of the K test
%       points
%

% author: Nathan Cahill and Selene Chew
% email: nathan.cahill@rit.edu
% date: 29 August 2015

K = size(testPosition,1);
M = size(supPixPosition,1);
N = size(supPixVals,2);

% interpolate method
S = zeros(K,N);
for i = 1:N
    F = scatteredInterpolant(supPixPosition(:,1),supPixPosition(:,2),...
        supPixVals(:,i),'natural','linear');
    S(:,i) = F(testPosition(:,1),testPosition(:,2));
end