% by Taro Tezuka since 14.12.29
% slice RMSEs tensor and visualize
% INPUT:
%   RMSEs: paramNum1 x paramNum2 x paramNum3 x sampleNum
%   optParamID1: optimal parameter 1

function [RMSEs_offDiags_regs, RMSEs_ksizes_regs, RMSEs_ksizes_offDiags] = sliceAndSurface(RMSEs, optParamID1, optParamID2, optParamID3, params1, params2, params3)

RMSEs_offDiags_regs = RMSEs(optParamID1,:,:);
RMSEs_ksizes_regs = RMSEs(:,optParamID2,:);
RMSEs_ksizes_offDiags = RMSEs(:,:,optParamID3);
figure
positionVector1 = [0.1, 0.15, 0.2, 0.7];
positionVector2 = [0.4, 0.15, 0.2, 0.7];
positionVector3 = [0.7, 0.15, 0.2, 0.7];

%----
% 2D plot for offDiags_regs
subplot('position', positionVector1);
heightMat = permute(RMSEs_offDiags_regs,[2 3 1]);
% xlabelStr = 'regularization parameter \rho';
% ylabelStr = 'off-diagonal entries \gamma';
xlabelStr = '\rho';
ylabelStr = '\gamma';
zlabelStr = 'RMSE';
subplotTitle =['\sigma = ' num2str(params1(optParamID1))];
xticks = params3;
yticks = params2;
plotSurface4optimization(heightMat, xlabelStr, ylabelStr, zlabelStr, xticks, yticks, subplotTitle)
%----
% 2D plot for ksizes_regs
subplot('position', positionVector2);
heightMat = permute(RMSEs_ksizes_regs,[1 3 2]);
% xlabelStr = 'regularization parameter \rho';
% ylabelStr = 'smoothing parameter \sigma';
xlabelStr = '\rho';
ylabelStr = '\sigma';
zlabelStr = 'RMSE';
subplotTitle = ['\gamma = ' num2str(params2(optParamID2))];
xticks = params3;
yticks = params1;
plotSurface4optimization(heightMat, xlabelStr, ylabelStr, zlabelStr, xticks, yticks, subplotTitle)
%----
% 2D plot for ksizes_offDiags
subplot('position', positionVector3);
heightMat = RMSEs_ksizes_offDiags;
% xlabelStr = 'off-diagonal entries \gamma';
% ylabelStr = 'smoothing parameter \sigma';
xlabelStr = '\gamma';
ylabelStr = '\sigma';
zlabelStr = 'RMSE';
subplotTitle = ['\rho = ' num2str(params3(optParamID3))];
xticks = params2;
yticks = params1;
plotSurface4optimization(heightMat, xlabelStr, ylabelStr, zlabelStr, xticks, yticks, subplotTitle)
%----

end

