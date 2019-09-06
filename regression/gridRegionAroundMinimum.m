% by Taro Tezuka since 14.12.30
% for hierarchical grid-search (brute force optimization), finds the new region based on minimum

function [newParams1, newParams2, newParams3] = gridRegionAroundMinimum(optParamID1, optParamID2, optParamID3, params1, params2, params3, gridNum, scale1, scale2, scale3)

paramsCell = {params1, params2, params3};
optParamIDs = [optParamID1; optParamID2; optParamID3];
scaleCell = {scale1, scale2, scale3};
newParamsCell = cell(3,1);
for cellID = 1:3
    newParamsCell{cellID} = searchRegion(paramsCell{cellID}, optParamIDs(cellID,1), gridNum, scaleCell{cellID});
end
newParams1 = newParamsCell{1};
newParams2 = newParamsCell{2};
newParams3 = newParamsCell{3};

end

function newParams = searchRegion(params, optParamID, gridNum, scale)

if optParamID < 2
    if strcmp(scale,'log')
        startPoint = params(1) / (params(2) / params(1));
    else
        startPoint = params(1) - (params(2) - params(1));
    end
else
    startPoint = params(optParamID-1);
end

if optParamID >= length(params)
    if strcmp(scale,'log')
        endPoint = params(end) * (params(end) / params(end-1));
    else
        endPoint = params(end) + (params(end) - params(end-1));
    end
else
    endPoint = params(optParamID+1);    
end

if strcmp(scale,'log')
    newParams = power(2, linspace(log(startPoint)/log(2), log(endPoint)/log(2), gridNum));
else
    newParams = linspace(startPoint, endPoint, gridNum);
end

% below is commented out, because although border values may already been checked, combinations with non-border values are not checked yet.
% newParams(1) = [];
% newParams(end) = [];

end

