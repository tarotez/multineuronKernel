function [totalKernelMat] = coeffOfOneMat2totalKernelMat(totalKernelTensor, coeffOfOneMat, channelNum)

weightMat = (coeffOfOneMat * ones(channelNum)) + eye(channelNum);

totalKernelMat = kernelTensor2mixtureKernelMat(totalKernelTensor, weightMat);

end

