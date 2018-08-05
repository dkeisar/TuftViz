function [theta_changed] = gradientDescentMulti(X, label, theta, alpha, num_iters_mult)
% This function apply gradient descent on to the weight vector
% X=[number of training examples, cost velues]
% label=[labeles]
% theta=[weight vector/initial guess]
% alpha=[step size multiplier]
% num_iters_mult=[No of iteration multiplyer] - Real No of iteration is 
% num_iters_mult*length(label)


m = length(label); % number of training examples
%J_history = zeros(num_iters, 1);
thetas = size(theta,1);
%features = size(X,2)

%mu = mean(X);
%sigma = std(X);
%mu_size = size(mu);
%sigma_size = size(sigma);

%for all iterations
for iter = 1:num_iters_mult*length(label)
    
    tempo = [];
    
    result = [];
    
    theta_temp = [];
    
    %for all the thetas
    %for all the thetas
    for t = 1:thetas
        %all the examples
        for examples = 1:m
            tempo(examples) = ((theta' * X(examples, :)') - label(examples))...
                * X(examples,t);
        end
        
        result(t) = sum(tempo);
        tempo = 0;
        
    end
    %theta temp, store the temp
    for c = 1:thetas
        
        theta_temp(c) = theta(c) - alpha * (1/m) * result(c);
    end
    
    %simultaneous update
    for j = 1:thetas
        
        theta(j) = theta_temp(j);
        
    end
    
    
    % Save the cost J in every iteration
    %J_history(iter) = computeCostMulti(X, y, theta);
    
end
theta_changed=theta;
end