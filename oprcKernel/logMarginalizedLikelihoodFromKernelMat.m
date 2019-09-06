
% coded by Taro Tezuka since 16.7.6
% Rasumussen and Williams, Gaussian Processes for Machine Learning, pg.113, eq. 5-8.
% calculates log p(y|X,\theta), i.e. log-likelihood for leave-one-out analysis
% 
function [logMarginalizedLikelihood] = logMarginalizedLikelihoodFromKernelMat(depVar, R, invK)

sampleNum = length(depVar);
logDetK = 2 * sum(log(diag(R)));
logMarginalizedLikelihood = - (1/2) * (depVar' * invK * depVar + logDetK + sampleNum * log(2 * pi));

end

