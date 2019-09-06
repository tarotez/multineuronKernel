% by Taro Tezuka since 14.12.29
% finds minimum and indices 
% INPUT:
%   heightTensor: tensor, paramNum1 x paramNum2 x paramNum3
% OUTPUT:
%   minVal: minimum value
%   optParamID1: optimal parameter for for dimension 1
%   optParamID2: optimal parameter for for dimension 2
%   optParamID3: optimal parameter for for dimension 3

function [minVal, optParamID1, optParamID2, optParamID3] = indicesOfMinimum(heightTensor)

[paramNum1, paramNum2, paramNum3] = size(heightTensor);

minVal = heightTensor(1,1,1);
for paramID1 = 1:paramNum1
    for paramID2 = 1:paramNum2   
        for paramID3 = 1:paramNum3    
            if heightTensor(paramID1, paramID2, paramID3) < minVal
                minVal = heightTensor(paramID1, paramID2, paramID3);
                optParamID1 = paramID1;
                optParamID2 = paramID2;
                optParamID3 = paramID3;
            end
        end
    end    
end

end

