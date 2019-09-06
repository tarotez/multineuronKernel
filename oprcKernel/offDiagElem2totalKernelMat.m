function [totalKernelMat] = offDiagElem2totalKernelMat(totalKernelTensor, offDiagElem, channelNum)

weightMat = (offDiagElem * ones(channelNum)) + ((1 - offDiagElem) * eye(channelNum));

totalKernelMat = kernelTensor2mixtureKernelMat(totalKernelTensor, weightMat);

end

