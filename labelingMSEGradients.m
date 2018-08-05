function [cost, grad] = labelingMSEGradients(theta, X, label)
% This function calculate the gradient of the weight vector
% X=[number of training examples, cost velues]
% label=[labeles]
% theta=[weight vector/initial guess]

cost = X*theta-label;
cost = mean(mean(cost.^2) / 2);


tempo = [];

result = [];

thetas = size(theta,1);
m = length(label); % number of training examples

% cal the total cost for thetas
for t = 1:thetas
    %all the examples
    for examples = 1:m
        tempo(examples) = ((theta' * X(examples, :)') - label(examples))...
            * X(examples,t);
    end
    
    result(t) = sum(tempo);
    tempo = 0;
    
end

% gradient for each weight
for c = 1:thetas
    grad(c)=(1/m) * result(c);
end

end