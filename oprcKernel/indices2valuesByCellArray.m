% coded by Taro Tezuka since 14.9.17
% cell array version of extractedComponents = vector(indices).
% in other words, extracts elements from cell array "cellArray" whose indices are indicated by "indices".
%
function extractedComponents  = indices2valuesByCellArray(cellArray, indices)

elemNum = size(indices,1);
extractedComponents = zeros(elemNum,1);

for elemID = 1:elemNum
    extractedComponents(elemID) = cellArray(indices(elemID));   
end

end

