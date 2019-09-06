% Rasumussen and Williams, Gaussian Processes for Machine Learning, pg.117, eq. 5-12.
% calculates L_{LOO}(X,y,\theta), i.e. log-likelihood for leave-one-out analysis
% INPUT:
%   depVar: dependent variable
%   alpha: parameter vector for kernel regression
%   invKVec: diagonal entries of the inverse of kernel matrix
% OUTPPUT:
%   logLikelihoodLOO: leave-one-out predictive log likelihood

function [logLikelihoodLOO] = logLikelihoodFromKernelMat(depVar, alpha, invKVec)

mu = depVar - (alpha ./ invKVec);
sigmaSq = 1 ./ invKVec;
sampleNum = length(depVar);

logLikelihoodLOO = - (sum(log(sigmaSq) + ((depVar - mu).^2 ./ sigmaSq),1) + log(2 * pi) * sampleNum) / 2;

end

