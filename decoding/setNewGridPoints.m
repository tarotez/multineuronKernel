
function [newGridPoints, optimalParamValue] = setNewGridPoints(evalGridType, paramVec, costVec, gridDivideNum)

    paramNum = length(paramVec);
    if strcmp(evalGridType, 'RMSE')
        [~,optIdx] = min(costVec);
    elseif strcmp(evalGridType, 'leaveOneOut') || strcmp(evalGridType, 'marginalized')
        [~,optIdx] = max(costVec);
    end
    optimalParamValue = paramVec(optIdx);
    if optIdx == 1
        % minEnd = paramVec(1) - ((gridDivideNum - 2) * (paramVec(end) - paramVec(1)));
        % minEnd = paramVec(1) - (paramVec(end) - paramVec(1));
        minEnd = paramVec(1);
        maxEnd = paramVec(2);
    else
        minEnd = paramVec(optIdx - 1);        
        if optIdx == paramNum                        
            % maxEnd = paramVec(end) + ((gridDivideNum - 2) * (paramVec(end) - paramVec(1)));            
            % maxEnd = paramVec(end) + (paramVec(end) - paramVec(1));
            maxEnd = paramVec(end);
        else
            maxEnd = paramVec(optIdx + 1);
        end            
    end
               
    newGridPoints = linspace(minEnd, maxEnd, gridDivideNum);
        
end

