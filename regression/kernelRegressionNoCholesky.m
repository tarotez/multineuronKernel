% coded by Taro Tezuka since 14.9.16
% kernel ridge regression using the mixture kernel
% kernelMat: kernel matrix
% y: independent variables (each component is a sample)
% regLambda: regularization parameter
% alpha: the coefficient seeked for in kernel ridge regression
%
function [alpha] = kernelRegressionNoCholesky(kernelMat, y, regCoeff)

sampleNum = size(kernelMat,1);

% more stable
alpha = (kernelMat + (eye(sampleNum) * regCoeff)) \ y;

% unstable because of using inv
% alpha = inv(kernelMat + (eye(sampleNum) * regLambda)) * y;

end
