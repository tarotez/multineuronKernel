
% sampleNum = 4;
% channelNum = 3;
% rankNum = 2;
% randTensor = randn(sampleNum, sampleNum, channelNum, channelNum);
% kernelTensor = zeros(sampleNum, sampleNum, channelNum, channelNum);
% for sampleID1 = 1:sampleNum
%    for sampleID2 = 1:sampleNum  
%        randMat = permute(randTensor(sampleID1, sampleID2, :, :), [3 4 1 2]);
%        kernelTensor(sampleID1, sampleID2, :, :) = permute(randMat + randMat', [3 4 1 2]);
%    end
% end

load temp.kernelMat.mat
sampleNum = size(kernelTensor,1);
channelNum = size(kernelTensor,3);
rankNum = 4;
lowRankMat = randn(channelNum, rankNum);

gradTensor = zeros(sampleNum,sampleNum,channelNum,rankNum);
for sampleID1 = 1:sampleNum
    for sampleID2 = 1:sampleNum        
        Btemp = permute((kernelTensor(sampleID1,sampleID2,:,:) + kernelTensor(sampleID2,sampleID1,:,:)),[3 4 1 2]);
        gradTensor(sampleID1,sampleID2,:,:) = Btemp * lowRankMat;
        disp(['sum(sum(Btemp - Btemp'')) = ' num2str(sum(sum(Btemp - Btemp')))]);
    end
end
gradTensorVec = reshape(gradTensor, [sampleNum sampleNum channelNum*rankNum]);

