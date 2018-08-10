function [Y,I,lambda] = erikssonNCut(varargin)
% erikssonNCut: performs clustering into k clusters by Eriksson's normalized 
%   cut algorithm, incorporating data that certain points must be linked or
%   cannot be linked.
% usage: [Y,I] = erikssonNCut(A,k,Pml,Pcl);
%    or: [Y,I,lambda] = erikssonNCut(A,k,Pml,Pcl);
%    or: [Y,I,lambda] = erikssonNCut(A,k,Pml,Pcl,seedKmeansFlag,constrInd);
% 
% arguments:
%   A - sparse adjacency matrix
%   k - desired number of clusters (default k = 2)
%   Pml - mx2 matrix containing indices of m must-link constrained points
%       If no must-link constraints, set Pml = []
%   Pcl - nx2 matrix containing indices of n cannot-link constrained points
%       If no cannot-link constraints, set Pcl = []
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
[A,k,Pml,Pcl,seedKmeansFlag,constrInd] = parseInputs(varargin{:});

%% construct must-link constraint matrix and weight matrix
U = sparse(repmat((1:size(Pml,1))',[1 2]),Pml,...
    [ones(size(Pml,1),1),-ones(size(Pml,1),1)],...
    size(Pml,1),size(A,1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If constraint propagation (Yu-Shi trick) is desired, uncomment this code:
% Dinv = spdiags(1./sum(A,2),0,size(A,1),size(A,1));
% U = U*Dinv*A; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%% construct cannot-link constraint matrix and weight matrix
UCap = sparse(repmat((1:size(Pcl,1))',[1 2]),Pcl,...
    ones(size(Pcl,1),2),size(Pcl,1),size(A,1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If constraint propagation (Yu-Shi trick) is desired, uncomment this code:
% UCap = UCap*Dinv*A; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% find basis for null space of constraint matrix
N = null(full([U;UCap]));

%% compute other matrices necessary for generalized eigenvector problem
D = spdiags(sum(A,2),0,size(A,1),size(A,1));
DHalf = spdiags(spdiags(D,0).^(1/2),0,size(A,1),size(A,1));
q = spdiags(DHalf,0)./norm(spdiags(DHalf,0));

L = D-A;
M = DHalf*(speye(size(A,1))-q*q')*DHalf;

Lc = N'*L*N;
Mc = N'*M*N;

%% ensure symmetric
Lc = (Lc + Lc')/2;
Mc = (Mc + Mc')/2;

%% solve for generalized eigenvectors
if k == 2
    numEigs = 1;
else
    numEigs = k;
end

[X,lambda] = eigs(Lc,Mc,round(1.5*(numEigs+1)),'SA');

% don't return first eigenvector/eigenvalue
X = X(:,2:numEigs+1);
lambda = lambda(2:numEigs+1,2:numEigs+1);

% take linear combination of null-space vectors
Y = N*X;

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
function [A,k,Pml,Pcl,seedKmeansFlag,constrInd] = parseInputs(varargin)

nargs = numel(varargin);
narginchk(1,6);

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
if ~isempty(Pml)
    if ~isequal(size(Pml,2),2) || ~ismatrix(Pml) || ...
            min(Pml(:))<1 || max(Pml(:))>size(A,1) || ...
            any(~isequal(Pml(:),round(Pml(:))))
        error([mfilename,':InvalidMustLinkConstraints'],...
            'Must-link constraints must be mx2 array of indices into rows of A.');
    end
end

% get/check Pcl
if nargs<4
    Pcl = [];
else
    Pcl = varargin{4};
end
if ~isempty(Pcl)
    if ~isequal(size(Pcl,2),2) || ~ismatrix(Pcl) || ...
            min(Pcl(:))<1 || max(Pcl(:))>size(A,1) || ...
            any(~isequal(Pcl(:),round(Pcl(:))))
        error([mfilename,':InvalidCannotLinkConstraints'],...
            'Cannot-link constraints must be nx2 array of indices into rows of A.');
    end
end

% get/check seedKmeansFlag
if nargs<5
    seedKmeansFlag = [];
else
    seedKmeansFlag = varargin{5};
end
if isempty(seedKmeansFlag)
    seedKmeansFlag = false;
end
if ~isscalar(seedKmeansFlag) || ~islogical(seedKmeansFlag)
    error([mfilename,':BadseedKmeansFlag'],'seedKmeansFlag must be logical scalar.');
end

% get/check constrInd
if nargs<6
    constrInd = [];
else
    constrInd = varargin{6};
end
if seedKmeansFlag && ~isequal(numel(constrInd),size(A,1)) && any(constrInd<0) && any(constrInd>k) && any(~isequal(constrInd,round(constrInd)))
    error([mfilename,':BadconstrInd'],'consrInd must be a size(A,1) x 1 array of integers from 0 to k.');
end
