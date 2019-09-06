% coded 1601080947
% generates Y = X * beta + noise, i.e. samples following the linear model

function [Y, X, beta, noise] = linearModel(sampleNum, attrNum, noiseRatio)

X = randn(sampleNum,attrNum);
beta = randn(attrNum,1);
noise = randn(sampleNum,1) * noiseRatio;
Y = X * beta + noise;

end

