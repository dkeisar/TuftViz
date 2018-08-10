function varargout = ssncEigs(W,U,Gamma,UCap,GammaCap,varargin)
% ssncEigs: computes eigenvectors of really complicated matrix
% usage: [vec,val] = ssncEigs(W,U,Gamma,UCap,GammaCap,...);
%
% arguments:
%   W (sparse nxn) - weighted adjacency matrix of the graph
%   U (sparse mxN) - matrix of must-link constraints
%   Gamma (sparse mxm) - diagonal matrix of weights
%   UCap (sparse nxN) - matrix of cannot-link constraints
%   GammaCap (sparse nxn) - diagonal matrix of weights
%   other inputs - subsequent inputs to "eigs" function
%

% author: Nathan Cahill and Selene Chew
% email: nathan.cahill@rit.edu
% date: 29 August 2015

% number of graph vertices
n = size(W,1);

% "potential" matrix of cannot-link constraints
BCap = UCap'*GammaCap*UCap;

% row sums of potential matrix
BCapRowSums = sum(BCap,2);

% permutation matrix that swaps rows 1 and row containing max row sum of
% potential matrix
[~,iMax] = max(BCapRowSums);
% P = speye(n,n);
% P([1,iMax(1)],:) = P([iMax(1),1],:);

% matrix M so that x = P*M*z
pVec = BCapRowSums;
pVec([1;iMax(1)]) = pVec([iMax(1),1]);
M = [pVec(2:n)';-pVec(1)*speye(n-1,n-1)];

% degree matrix and sqrt matrix
d = sum(W,2);
D = spdiags(d,0,n,n);
dHalf = sqrt(d);
DHalf = spdiags(dHalf,0,n,n);

% P*M and DHalf*P*M
PM = M; 
PM([1,iMax(1)],:) = PM([iMax(1),1],:);
DHalfPM = DHalf*PM;

% unit vector in the direction of sqrt(D)*1
q = dHalf/norm(dHalf);

% matrix M'*P*(D-W+U'*Gamma*U+UCap'*GammaCap*UCap)*P*M
A = PM'*(D - W + U'*Gamma*U + BCap)*PM;

% construct anonymous function
myfun = @(x) computeIter(x,A,DHalfPM,q);

% compute generalized eigenvectors
varargout = cell(1,nargout);
[varargout{:}] = eigs(myfun,n-1,varargin{:});

% transform eigenvectors by PM
if nargout>1
    varargout{1} = PM*varargout{1};
end

%% subfunction for computing A\x for eigs
function y = computeIter(x,A,DHalfPM,q)

qtilde = q(2:end);

% right hand side product
t1 = DHalfPM*x;
t2 = sum(qtilde.*t1(2:end));
t3 = [q(1)*t2; (q(1)-(q(1)^2)*t2).*qtilde];
t4 = t1 - q.*(sum(q.*t1)) - t3;
t5 = (t4'*DHalfPM)';

% inverse of left hand side
y = A\t5;
