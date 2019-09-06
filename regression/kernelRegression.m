% coded by Taro Tezuka since 14.9.16
% kernel ridge regression using the mixture kernel
% kernelMat: kernel matrix
% depVar: dependent variables (each component is a sample)
% regLambda: regularization parameter
% alpha: the coefficient seeked for in kernel ridge regression
%
function [alpha] = kernelRegression(kernelMat, depVar, regCoeff)

sampleNum = size(kernelMat,1);

% more stable
% alpha = (kernelMat + (eye(sampleNum) * regLambda)) \ y;

% unstable because of using inv
% alpha = inv(kernelMat + (eye(sampleNum) * regLambda)) * y;

% revised on 1601061127
% forllowing Rasmussen and Williams, Gaussian Process for Machine Learning, pg. 19, Algorithm 2.1 

% save kernelMat.mat kernelMat

U = chol(kernelMat + (eye(sampleNum) * regCoeff));
alpha = U \ (U' \ depVar);

end
