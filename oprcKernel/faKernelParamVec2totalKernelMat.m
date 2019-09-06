function [totalKernelMat] = faKernelParamVec2totalKernelMat(lowRankMatVec, logDiagMatVec, totalKernelTensor, rankNum, channelNum)

diagMatVec = exp(logDiagMatVec);
lowRankMat = reshape(lowRankMatVec, channelNum, rankNum);
diagMat = diag(diagMatVec);
weightMat = lowRankMat * lowRankMat' + diagMat;

totalKernelMat = kernelTensor2mixtureKernelMat(totalKernelTensor, weightMat);

end

