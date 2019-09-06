function [totalKernelMat] = diagMatCoeff2totalKernelMat(totalKernelTensor, diagMatCoeff, channelNum)

weightMat = ones(channelNum) + (diagMatCoeff * eye(channelNum));

totalKernelMat = kernelTensor2mixtureKernelMat(totalKernelTensor, weightMat);

end

