% Coded by Taro Tezuka since 2015.4.26
% converts upper triangular part of a symmetric matrix to a vector
% 
% INPUT
%   vectorized: 
% OUTPUT
%   symmetricMat:
%
function symmetricMat = vec2symmetricMat(vectorized)

vecDim = size(vectorized,1);
matDim = floor(sqrt(vecDim * 2));
upperTriangularMat = zeros(matDim,matDim);
cellCnt= 1;
for unitID1 = 1:matDim
    for unitID2 = unitID1:matDim
        upperTriangularMat(unitID1,unitID2) = vectorized(cellCnt);
        cellCnt = cellCnt + 1;
    end
end

symmetricMat = upperTriangularMat + upperTriangularMat' - diag(diag(upperTriangularMat));

end

