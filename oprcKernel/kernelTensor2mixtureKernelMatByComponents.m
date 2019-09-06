% Coded by Taro Tezuka since 2014.9.20
% calculates mixture kernel from channel-wise kernel matrix
%
function [kernelMat] = kernelTensor2mixtureKernelMat(kernelTensor, weightMat)

% calculate mixture kernel by simple summing with weight matrix
sampleNum = size(kernelTensor,1);
channelNum = size(weightMat,1);
kernelMat = zeros(sampleNum);
for channelID1 = 1:channelNum
    for channelID2 = 1:channelNum         
        kernelMat = kernelMat + (weightMat(channelID1, channelID2) * kernelTensor(:,:,channelID1,channelID2));
    end
end

end

