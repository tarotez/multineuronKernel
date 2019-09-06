% Coded by Taro Tezuka since 2015.4.26
% converts upper triangular part of a symmetric matrix to a vector
% 
% INPUT
%   symmetricMat: 
% OUTPUT
%   vectorized:
%
function vectorized = symmetricMat2vec(symmetricMat)

matDim = size(symmetricMat,1);
vectorized = zeros(matDim * (matDim + 1) / 2, 1);
cellCnt = 1;
for unitID1 = 1:matDim
    for unitID2 = unitID1:matDim       
        vectorized(cellCnt) = symmetricMat(unitID1,unitID2);
        cellCnt = cellCnt + 1;
    end
end

end

