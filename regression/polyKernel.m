% Coded by Taro Tezuka since 2014.9.20
% polynomial kernel
%
function [polyKernelMat] = polyKernel(kernelMat, polyDim, tradeOff)

polyKernelMat = (kernelMat + (ones(size(kernelMat)) * tradeOff)).^polyDim;

end

