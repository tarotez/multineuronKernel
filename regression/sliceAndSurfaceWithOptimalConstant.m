% by Taro Tezuka since 14.12.29
% slice RMSEs tensor and visualize
% INPUT:
%   RMSEs: paramNum1 x paramNum2 x paramNum3 x sampleNum
%   optParamID1: optimal parameter 1

function sliceAndSurfaceWithOptimalConstant(RMSEs, targetDim, xlabelStr, ylabelStr, subplotTitle, params1, params2, params3, positionVector)

%----
% 2D plot for offDiags_regs
subplot('position', positionVector);
if targetDim == 1
    heightMat = permute(RMSEs,[2 3 1]);
    xticks = params3;
    yticks = params2;
else if targetDim == 2    
        heightMat = permute(RMSEs,[1 3 2]);
        xticks = params3;
        yticks = params1;
    else 
        heightMat = RMSEs;
        xticks = params2;
        yticks = params1;
    end
end
zlabelStr = 'RMSE';

plotSurface4optimization(heightMat, xlabelStr, ylabelStr, zlabelStr, xticks, yticks, subplotTitle)

end

