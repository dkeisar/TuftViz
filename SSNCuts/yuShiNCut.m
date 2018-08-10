function [X,I,lambda] = yuShiNCut(varargin)
% yuShiNCut: compute Yu-Shi constrained normalized cut of graph given 
%   adjacency matrix
% usage: X = yuShiNCut(A, k, CMask);
%    or: [X,I] = yuShiNCut(A, k, CMask);
%
% arguments: 
%   A (sparse nxn) - weighted adjacency matrix of graph
%   k (scalar) - number of smallest nonzero eigenvectors to use to compute
%       normalized cut. Default k = size(CMask,2).
%   CMask (logical nxp) - array whose ith column indicates vertices of the
%       graph that should be constrained to end up in the ith class
%
%   X (nxk) - eigenvectors corresponding to the k largest eigenvalues
%   I (nx1) - index vector containing class labels
%

% author: Nathan Cahill and Selene Chew
% email: nathan.cahill@rit.edu
% date: 29 August 2015

% parse input arguments
[A,k,CMask,n] = parseInputs(varargin{:});

%% construct matrix U of must-link constraints from CMask

% list of pairs of indices forming must-link constraints
numClasses = size(CMask,2);
MLIndPerClass = cell(1,numClasses);
for i = 1:numClasses
    f = find(CMask(:,i));
    MLIndPerClass{i} = [repmat(f(1),[numel(f)-1,1]) f(2:end)];
end
MLInd = cat(1,MLIndPerClass{:});

% U matrix
numConstraints = size(MLInd,1);
U = sparse(MLInd,repmat((1:numConstraints)',[1 2]),...
    ones(numConstraints,1)*[1 -1],size(A,2),numConstraints);

% multiply P'*U to smooth out constraints
Dinv = spdiags(1./sum(A,2),0,n,n);
PtU = A*Dinv*U; % assumes A is symmetric - if not, change to A'

%% construct Pbar, Ubar, H from step 4 of Yu-Shi algorithm
DinvSqrt = spdiags(sqrt(spdiags(Dinv,0)),0,n,n);

Pbar = DinvSqrt*A*DinvSqrt;
Ubar = DinvSqrt*PtU;
H = inv(double(Ubar'*Ubar));

%% compute eigenvectors of Qbar*Pbar*Qbar
% construct anonymous function
myfun = @(x) computeIter(x,Pbar,Ubar,H);
[V,lambda] = eigs(myfun,n,speye([n n]),max(k,10),'LM');

% only return vector of eigenvalues
lambda = diag(lambda);

% sort columns of V so that the eigenvalues are decreasing in magnitude
%[~,ind] = sort(lambda,1,'descend');
ind = 1:numel(lambda);
V = V(:,ind(1:k));
lambda = lambda(ind(1:k));

%% transform results
X = DinvSqrt*V;

% flip sign of X if necessary
ind = find(CMask(:,1));
for i = 1:size(X,2)
    X(:,i) = X(:,i)*sign(X(ind(1),i));
end

%% perform k-means algorithm to cluster points in the eigenvector basis
kmeansFlag = true;
while kmeansFlag
    try
        I = kmeans(X,max(k,2));
        kmeansFlag = false;
    catch
        disp('kmeans failed; recomputing');
    end
end

%% parseInputs subfunction
function [A,k,CMask,n] = parseInputs(varargin)

% check 3 inputs
narginchk(3,3);

A = varargin{1};
n = size(A,1);
if ~ismatrix(A) || ~isequal(n,size(A,2))
    error([mfilename,':BadAdjacencyMatrix'],'A must be nxn');
end

CMask = varargin{3};
if ~islogical(CMask) || ~isequal(size(CMask,1),n) || ~ismatrix(CMask)
    error([mfilename,':BadMask'],'mask must be nx1');
end

k = varargin{2};
if isempty(k)
    k = size(CMask,2);
end
if ~isscalar(k) || k<=0 || ~isequal(k,round(k))
    error([mfilename,':Badk'],'k must be positive integer');
end

%% subfunction for computing Qbar*Pbar*Qbar*x for eigs
function y = computeIter(x,Pbar,Ubar,H)

z = x - Ubar*(H*(Ubar'*x));
w = Pbar*z;
y = w - Ubar*(H*(Ubar'*w));
