% coded by Taro Tezuka since 1601121231
% Rasumussen and Williams, Gaussian Processes for Machine Learning, pg.117, eq. 5-12.
% calculates L_{LOO}(X,y,\theta), i.e. log-likelihood for leave-one-out analysis
function [logLikelihoodLOO] = logLeaveOneOutLikelihoodFromKernelMat(depVar, alpha, invKVec)

mu = depVar - (alpha ./ invKVec);
sigmaSq = 1 ./ invKVec;
sampleNum = length(depVar);

logLikelihoodLOO = - (sum(log(sigmaSq) + ((depVar - mu).^2 ./ sigmaSq),1) + log(2 * pi) * sampleNum) / 2;

end

