% Coded by Taro Tezuka since 2016.1.8
% calculates factor analysis kernel for spike trains
% x1, x2 : cell array of spike trains (multichannel spike trains)
% lowRankMat:
% diagonalMat:
% ks : kernel structure, defined in spiketrainlib
% param : parameter for ks
%
function kernelMat  = FAkernelFromKernelTensor(kernelTensor, lowRankMat, diagonalMat)

%----
% calculate mixture kernel by simple summing with weight matrix
weightMat = lowRankMat * lowRankMat' + diagonalMat;

sampleNum = length(kernelTensor);
channelNum = size(weightMat,1);
kernelMat = zeros(sampleNum, sampleNum);
for channelID1 = 1:channelNum
    for channelID2 = 1:channelNum
        kernelMat = kernelMat + weightMat(channelID1, channelID2) * kernelTensor(:,:,channelID1,channelID2);
    end
end

end
