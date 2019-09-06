% Coded by Taro Tezuka since 2014.9.20
% calculates mixture kernel from channel-wise kernel matrix
%
function [kernelMat] = kernelTensor2mixtureKernelMat(kernelTensor, weightMat)

% calculate mixture kernel by multiplication with the weight matrix
sampleNum = size(kernelTensor,1);

kernelMat = sum(sum(bsxfun(@times, kernelTensor, repmat(permute(weightMat,[3,4,1,2]),sampleNum,sampleNum)),3),4);
% kernelMat = (kernelMat + kernelMat') / 2;

%{
channelNum = size(weightMat,1);
kernelMatByComponents = zeros(sampleNum);
for channelID1 = 1:channelNum
    for channelID2 = 1:channelNum
        kernelMatByComponents = kernelMatByComponents + (weightMat(channelID1, channelID2) * kernelTensor(:,:,channelID1,channelID2));
    end   
end
kernelMat = kernelMatByComponents;
%}
% save kernelMat.mat kernelMat weightMat kernelTensor
% disp(['sum(sum(abs(kernelMat - kernelMatByComponents))) = ' num2str(sum(sum(abs(kernelMat - kernelMatByComponents))))]);


end

