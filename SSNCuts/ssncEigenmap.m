function [X,lambda] = ssncEigenmap(W,U,Gamma,Ucap,GammaCap,numEigs)
% ssncEigenmap - compute Schroedinger eigenmap
% usage: [X,lambda] = ssncEigenmap(W,U,Gamma,Ucap,GammaCap,numEigs);
%
% arguments:
%   W (sparse NxN) - weighted adjacency matrix
%   U (sparse mxN) - matrix of must-link constraints
%   Gamma (sparse mxm) - diagonal matrix of weights
%   UCap (sparse nxN) - matrix of cannot-link constraints
%   GammaCap (sparse nxn) - diagonal matrix of weights
%   numEigs (scalar) - number of eigenvectors to return
%
%   XS (N x (numEigs+1)) - eigenvectors 
%   lambda ((numEigs+1) x (numEigs+1)) - corresponding eigenvalues
%

% author: Nathan Cahill and Selene Chew
% email: nathan.cahill@rit.edu
% date: 29 August 2015

% compute more eigenvectors than necessary due to convergence of eigs
[Y,lambda,flag] = ssncEigs(W,U,Gamma,Ucap,GammaCap,round(1.5*(numEigs+1)),'SM');

% see if any of second through numEigs+1 eigenvalues are nonzero
maxFactor = 10;
currentFactor = 2;
while any(diag(lambda(2:numEigs+1,2:numEigs+1))==0) && (currentFactor<=maxFactor)
    [Y,lambda,flag] = ssncEigs(W,U,Gamma,Ucap,GammaCap,round(currentFactor*(numEigs+1)),'SM');
    currentFactor = currentFactor + 1;
end
if currentFactor>maxFactor
    warning('Eigenvalues failed to converge.');
end

% return eigenvectors
X = Y(:,1:numEigs);
lambda = lambda(1:numEigs,1:numEigs);
