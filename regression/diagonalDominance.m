% coded by Taro Tezuka since 15.4.25
% diagonal dominance
% INPUT
%   coeffMatVec: coefficient matrix
% OUTPUT
%   conditionVec: vector representing nonlinear condition c(x) >= 0
%   
function [equalityConditionVec, inequalityConditionVec] = diagonalDominance(coeffMatVec)

coeffMat = vec2symmetricMat(coeffMatVec);
unitNum = size(coeffMat,1);

equalityConditionVec = zeros(unitNum,1);
% inequalityConditionVec = zeros(unitNum,1);
inequalityConditionVec = [];
for unitID = 1:unitNum    
    equalityConditionVec(unitID) = abs(coeffMat(unitID,unitID)) - sum(abs(coeffMat(unitID,[1:unitID-1 unitID+1:unitNum])));
end

end

