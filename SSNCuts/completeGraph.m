function P = completeGraph(ind)
% construct all combinations of indices chosen two at a time

% author: Nathan Cahill and Selene Chew
% email: nathan.cahill@rit.edu
% date: 29 August 2015

n = numel(ind);

i = repmat(ind(:)',[n 1]);
j = repmat(ind(:),[1 n]);

T = triu(true(n),1);

P = [i(T) j(T)];
