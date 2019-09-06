% Coded by Taro Tezuka since 2015.4.26
% convert totalKernelTensor to totalMixtureKernelMat
%
% INPUT
%   totalKernelTensor: total kernel tensor
% OUTPUT
%   totalMixtureKernelMat: total kernel matrix using identity matrix as the coefficient matrix.
%
function totalMixtureKernelMat = totalKernelTensor2totalMixtureKernelMatByIdentityCoeff(totalKernelTensor)

%---------
% calculate the kernel matrix for the mixture kernel when the mixing coefficient matrix is the identity matrix
sampleNum = size(totalKernelTensor,1);
unitNum = size(totalKernelTensor,3);
totalMixtureKernelMat = zeros(sampleNum,sampleNum);
for unitID = 1:unitNum       
    totalMixtureKernelMat = totalMixtureKernelMat + totalKernelTensor(:,:,unitID,unitID);
end

end

