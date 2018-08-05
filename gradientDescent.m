function [theta, J_history] = gradientDescentMulti(X, y, theta, alpha, num_iters)

m = length(y); % number of training examples
J_history = zeros(num_iters, 1);
thetas = size(theta,1);
features = size(X,2)

mu = mean(X);
sigma = std(X);
mu_size = size(mu);
sigma_size = size(sigma);

%for all iterations
for iter = 1:num_iters

tempo = [];

result = [];

theta_temp = [];

%for all the thetas    
E = X * theta - y;
for t = 1:thetas
    result(t) = sum(E.*X(:,t));
end

%theta temp, store the temp 
for c = 1:thetas

theta = theta - alpha * (1/m) * result';
end

%simultaneous update
for j = 1:thetas

    theta(j) = theta_temp(j)

end

% Save the cost J in every iteration    
J_history(iter) = computeCostMulti(X, y, theta);

end

theta
end