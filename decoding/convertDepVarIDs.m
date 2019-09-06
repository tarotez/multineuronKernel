% Coded by Taro Tezuka since 14.10.21
% Converts yIDs 
% This is because if the value of the stimulus type is orientation, 0 degree and 359 degree are next to each other, 
% so it is unnatural to assume a linear relationship.
% used for CRCNS pvc-3, for example.
% 
function [converted_depVarIDs] = convertDepVarIDs(orig_depVarIDs, condNum)

converted_depVarIDs = mod(orig_depVarIDs - 1, round(condNum/2)) + 1;  % has to add one to avoid newStimVector(i) from being 0.

end

