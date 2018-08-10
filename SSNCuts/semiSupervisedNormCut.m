function [Y,I,lambda] = semiSupervisedNormCut(varargin)
% semiSupervisedNormCut: performs clustering into k clusters by normalized 
%   cut algorithm, incorporating data that certain points must be linked or
%   cannot be linked.
% usage: [Y,I] = semiSupervisedNormCut(A,k,Pml,gml,Pcl,gcl);
%    or: [Y,I,lambda] = semiSupervisedNormCut(A,k,Pml,gml,Pcl,gcl);
%    or: [Y,I,lambda] = semiSupervisedNormCut(A,k,Pml,gml,Pcl,gcl,seedKmeansFlag,constrInd);
% 
% arguments:
%   A - sparse adjacency matrix
%   k - desired number of clusters (default k = 2)
%   Pml - mx2 matrix containing indices of m must-link constrained points
%       If no must-link constraints, set Pml = []
%   gml - scalar or mx1 vector of weights for the must-link constraints
%       Default gml = 1
%   Pcl - nx2 matrix containing indices of n cannot-link constrained points
%       If no cannot-link constraints, set Pcl = []
%   gcl - scalar or nx1 vector of weights for the cannot-link constraints
%       Default gml = 1
%   seedKmeansFlag (logical scalar) - true if kmeans algorithm should be
%       seeded with cluster centers from manually provided constraints. false
%       if kmeans should be seeded randomly. Default seedKmeansFlag =
%       false.
%   constrInd (size(A,1) x 1) - vector containing class labels for the
%       manually labeled vertices. Class labels are values from 1:k. A zero
%       value in constrInd indicates that no information was manually provided
%       about the corresponding vertex.
%
%   Y - array containing smallest k-1 generalized eigenvectors of graph
%       Laplacian
%   I - index vector containing class labels
%   lambda - corresponding eigenvalues
%

% author: Nathan Cahill and Selene Chew
% email: nathan.cahill@rit.edu
% date: 29 August 2015

%% parse input arguments
[A,k,Pml,gml,Pcl,gcl,constrFlag,seedKmeansFlag,constrInd] = parseInputs(varargin{:});

%% construct must-link constraint matrix and weight matrix
U = sparse(repmat((1:size(Pml,1))',[1 2]),Pml,...
    [ones(size(Pml,1),1),-ones(size(Pml,1),1)],...
    size(Pml,1),size(A,1));
% Yu-Shi constraint propagation trick: multiply by P', where P = inv(D)*A
Dinv = spdiags(1./sum(A,2),0,size(A,1),size(A,1));
U = U*Dinv*A; 
if constrFlag(1)
    Gamma = spdiags(gml,0,size(Pml,1),size(Pml,1));
else
    Gamma = sparse([]);
end
    
%% construct cannot-link constraint matrix and weight matrix
UCap = sparse(repmat((1:size(Pcl,1))',[1 2]),Pcl,...
    ones(size(Pcl,1),2),size(Pcl,1),size(A,1));
% Yu-Shi constraint propagation trick: multiply by P', where P = inv(D)*A
UCap = UCap*Dinv*A; 
if constrFlag(2)
    GammaCap = spdiags(gcl,0,size(Pcl,1),size(Pcl,1));
else
    GammaCap = sparse([]);
end

%% solve for generalized eigenvectors
if k == 2
    numEigs = 1;
else
    numEigs = k;
end

switch constrFlag(2) % true if cannot-link constraints are provided
    case true
        [Y,lambda] = ssncEigenmap(A,U,Gamma,UCap,GammaCap,numEigs);
    otherwise
        L = spdiags(sum(A,2),0,size(A,1),size(A,1)) - A;
        [Y,lambda] = schroedingerEigenmap(L,U'*Gamma*U,1,numEigs);
end

%% perform k-means algorithm to cluster points in the eigenvector basis
kmeansFlag = true;
if kmeansFlag && seedKmeansFlag
    kmeansCentroids = zeros(k,k-1);
    for i = 1:k
        kmeansCentroids(i,:) = median(Y(constrInd==i,:),1);
    end
end
while kmeansFlag
    try
        if seedKmeansFlag
            I = kmeans(Y,k,'start',kmeansCentroids);
        else
            I = kmeans(Y,k);
        end
        kmeansFlag = false;
    catch
        disp('kmeans failed; recomputing');
    end
end

%% subfunction parseInputs
function [A,k,Pml,gml,Pcl,gcl,constrFlag,seedKmeansFlag,constrInd] = parseInputs(varargin)

% initialize constrFlag to assume we have both sets of constraints
constrFlag = [true true];

nargs = numel(varargin);
narginchk(1,8);

% get/check adjacency matrix
A = varargin{1};
if ~issparse(A)
    error([mfilename,':ANotSparse'],'Adjacency matrix must be sparse.');
end

% get/check k
if nargs<2
    k = [];
else
    k = varargin{2};
end
if isempty(k)
    k = 1; % default
end
if (numel(k)>1) || (k<1) || (~isequal(k,round(k)))
    error([mfilename,':InvalidClusterNumber'],...
        'Number of clusters k must be positive integer.');
end

% get/check Pml
if nargs<3
    Pml = [];
else
    Pml = varargin{3};
end
if isempty(Pml)
    constrFlag(1) = false;
elseif ~isequal(size(Pml,2),2) || ~ismatrix(Pml) || ...
        min(Pml(:))<1 || max(Pml(:))>size(A,1) || ...
        any(~isequal(Pml(:),round(Pml(:))))
    error([mfilename,':InvalidMustLinkConstraints'],...
        'Must-link constraints must be mx2 array of indices into rows of A.');
end

% get/check gml
if nargs<4
    gml = [];
else
    gml = varargin{4};
end
if isempty(gml)
    gml = 1;
end
if isscalar(gml)
    gml = repmat(gml,[size(Pml,1),1]);
end
if ~isequal(size(Pml,1),numel(gml)) || ~isvector(gml) || any(gml(:)<0)
    error([mfilename,':InvalidGml'],...
        'Weights for must-link constraints must be scalar or mx1 array of nonnegative real numbers.');
end

% get/check Pcl
if nargs<5
    Pcl = [];
else
    Pcl = varargin{5};
end
if isempty(Pcl)
    constrFlag(2) = false;
elseif ~isequal(size(Pcl,2),2) || ~ismatrix(Pcl) || ...
        min(Pcl(:))<1 || max(Pcl(:))>size(A,1) || ...
        any(~isequal(Pcl(:),round(Pcl(:))))
    error([mfilename,':InvalidCannotLinkConstraints'],...
        'Cannot-link constraints must be nx2 array of indices into rows of A.');
end

% get/check gcl
if nargs<6
    gcl = [];
else
    gcl = varargin{6};
end
if isempty(gcl)
    gcl = 1;
end
if isscalar(gcl)
    gcl = repmat(gcl,[size(Pcl,1),1]);
end
if ~isequal(size(Pcl,1),numel(gcl)) || ~isvector(gcl) || any(gcl(:)<0)
    error([mfilename,':InvalidGcl'],...
        'Weights for cannot-link constraints must be scalar or mx1 array of nonnegative real numbers.');
end

% get/check seedKmeansFlag
if nargs<7
    seedKmeansFlag = [];
else
    seedKmeansFlag = varargin{7};
end
if isempty(seedKmeansFlag)
    seedKmeansFlag = false;
end
if ~isscalar(seedKmeansFlag) || ~islogical(seedKmeansFlag)
    error([mfilename,':BadseedKmeansFlag'],'seedKmeansFlag must be logical scalar.');
end

% get/check constrInd
if nargs<8
    constrInd = [];
else
    constrInd = varargin{8};
end
if seedKmeansFlag && ~isequal(numel(constrInd),size(A,1)) && any(constrInd<0) && any(constrInd>k) && any(~isequal(constrInd,round(constrInd)))
    error([mfilename,':BadconstrInd'],'consrInd must be a size(A,1) x 1 array of integers from 0 to k.');
end
