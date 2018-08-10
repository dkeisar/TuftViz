function A = adjacencyMatrixGPbSuperpixels(varargin)
% adjacencyMatrixGPbSuperpixels - construct adjacency matrix from 
%   superpixels of an image using global probability of contour cue
% usage: A = adjacencyMatrixGBpSuperpixels(supPixPosition,gPb,rad,sigma);
%
% arguments:
%   supPixPosition (Mx2) - average row/column pixel positions for each of
%       the M superpixels.
%   gPb (numRows X numCols) - image containing global probability of
%       contour cue, as computed from Berkeley BSR code
%   rad (positive scalar) - Radius (in pixels) of circular neighborhood in
%       which to compute weights for adjacency matrix. Default rad = 2.
%   sigma (postive scalar) - standard deviation parameter for weighted 
%       metric. Default sigmaF = 1.
%
%   A (sparse MNxMN) - weighted adjacency matrix
%
% Note: for consistency, it is recommended to normalize imageData so that 
%   the norm of the vector at each pixel has an average value of 1. This 
%   function will do NO normalization, however.
%

% author: Nathan Cahill and Selene Chew
% email: nathan.cahill@rit.edu
% date: 29 August 2015

% get/check inputs
[supPixPosition,gPb,rad,sigma,M] = parseInputs(varargin{:});

% compute distance matrix between all pairs of superpixels
DMat = squareform(pdist(supPixPosition));

% create mask to indicate positions where DMat <= rad
DMask = (DMat<=rad) & (triu(DMat,1)>0);

% compute max gPb weights
[ii,jj] = find(DMask);
numPts = 100;
xPts = zeros(numel(ii),numPts);
yPts = xPts;
for k = 1:numel(ii)
    
    % get positions of start and end points
    p0 = supPixPosition(ii(k),:);
    p1 = supPixPosition(jj(k),:);
    
    % interpolation points
    xPts(k,:) = linspace(p0(2),p1(2),numPts);
    yPts(k,:) = linspace(p0(1),p1(1),numPts);
    
end
% interpolated gPb on line segments connecting superpixel centers
gPbInterp = interp2(gPb,xPts,yPts);
% compute maximum gPb on line segment
maxgPb = max(gPbInterp,[],2);
% compute weight
maxgPbWeight = exp(-maxgPb/sigma);

% construct adjacency matrix
A = spalloc(M,M,sum(DMask(:)));
A(DMask) = maxgPbWeight;
A = A + A';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction parseInputs
function [supPixPosition,gPb,rad,sigma,M,numRows,numCols] = parseInputs(varargin)

% get/check number of inputs
nargs = numel(varargin);
narginchk(2,4);

% get/check position data
supPixPosition = varargin{1};
M = size(supPixPosition,1);
if (~ismatrix(supPixPosition)) || (size(supPixPosition,2)~=2)
    error([mfilename,':parseInputs:badSupPixPosition'],'Superpixel position must be Mx2 double precision array');
end

% get/check gPb data
gPb = varargin{2};
[numRows,numCols] = size(gPb);
if ~ismatrix(gPb)
    error([mfilename,':parseInputs:badGPb'],'gPb must be 2-D double precision array');    
end

% get/check radius
if nargs>2
    rad = varargin{3};
else
    rad = [];
end
if isempty(rad)
    rad = 2;
end
if ~isscalar(rad) || (rad<1)
    error([mfilename,':parseInputs:badRadius'],'Radius must be scalar greater than or equal to one.');
end

% get/check sigma
if nargs>3
    sigma = varargin{4};
else
    sigma = [];
end
if isempty(sigma)
    sigma = 1;
end
if ~isscalar(sigma) || (sigma<=0)
    error([mfilename,':parseInputs:badSigma'],'sigma must be positive scalar');
end
