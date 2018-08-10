function [X,XUnbiased] = biasedNCut(varargin)
% biasedNCut: compute biased normalized cut of graph given adjacency matrix
% usage: X = biasedNCut(A, k, mask)
%    or: [X,XUnbiased] = biasedNCut(A, k, mask)
%
% arguments: 
%   A (sparse nxn) - weighted adjacency matrix of graph
%   k (scalar) - number of smallest nonzero eigenvectors to use to compute
%       biased normalized cut. Default k = 25.
%   mask (logical nx1) - array that specifies vertices of the graph that we
%       want correlated with the biased normalized cut
%
%   X (nx1) - linear combination of smallest K eigenvectors from normalized
%       cuts that form the biased cut
%   XUnbiased (nx1) - second-smallest eigenvector output from normalized
%       cuts

% author: Nathan Cahill and Selene Chew
% email: nathan.cahill@rit.edu
% date: 29 August 2015

% parse input arguments
[A,k,mask] = parseInputs(varargin{:});

%% The set T corresponds to the set of vertices with true mask values
volT = full(sum(sum(A(mask,:))));
volTNot = full(sum(sum(A(~mask,:))));
volG = full(sum(A(:)));

%% Compute s_T
s_T = (sqrt(volT*volTNot/volG)/volT)*(2*double(mask)-1);

%% Compute smallest K nonzero eigenvalues of graph Laplacian
[U,~,lambda] = normalizedCut(A,k);

%% specify gamma parameter for biased normalized cuts
tau = 1;
gamma = -tau*mean(diag(lambda));

%% Compute weights for biased normalized cut
DGsT = full(sum(A,2)).*s_T(:);
w = (U'*DGsT)./(diag(lambda)-gamma);

%% Compute biased normalized cut
X = U*w;

%% Return unbiased normalized cut
XUnbiased = U(:,1);

% flip sign of XUnbiased if necessary
ind = find(mask);
XUnbiased = XUnbiased*sign(XUnbiased(ind(1)));

%% parseInputs subfunction
function [A,k,mask] = parseInputs(varargin)

% check 3 inputs
narginchk(3,3);

A = varargin{1};
n = size(A,1);
if ~ismatrix(A) || ~isequal(n,size(A,2))
    error([mfilename,':BadAdjacencyMatrix'],'A must be nxn');
end

k = varargin{2};
if isempty(k)
    k = 25;
end
if ~isscalar(k) || k<=0 || ~isequal(k,round(k))
    error([mfilename,':Badk'],'k must be positive integer');
end

mask = varargin{3};
if ~islogical(mask) || ~isequal(numel(mask),n)
    error([mfilename,':BadMask'],'mask must be nx1');
end

