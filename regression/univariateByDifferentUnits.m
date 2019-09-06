% by Taro Tezuka since 15.1.22
% change the unit for univariate kernel regression and evaluate by RMSE
% INPUT:
%  multivariateSubtrains: multivariate spike trains. condNum -> trialNum -> unitNum
%  timeLength: length of recording
%  ksize: kernel size for linear functional kernel (mCI kernel)
%  offDiag: off diagonal entries
%  reg: regularization parameter
%  thinConditionsBy: thinning ratio
%  figID: figure ID for showing the results
% OUTPUT:
%  RMSEs: root mean squared errors
%  unitNums: vector of unit numbers
% 
function [RMSEs, unitIDs] = univariateByDifferentUnits(multivariateSubtrains, timeLength, ksize, offDiag, reg, thinConditionsBy, figID)

%-----
% set basic parameters
maxUnitNum = length(multivariateSubtrains{1}{1});
kernelType = 'mci';
kernelSpecification = '';
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
kernelParams = [ksize, 1];    
period = 360;
foldNum = 0;
diagComponent = 1;
orig_condNum = size(multivariateSubtrains,1);
orig_depVarTypes = ((360/orig_condNum):(360/orig_condNum):360) - (360/orig_condNum);
segmentNum = 1;
shorterSubtrains = divideByTimeLength(multivariateSubtrains, timeLength, segmentNum);

unitIDs = zeros(maxUnitNum,1);
RMSEs = zeros(maxUnitNum,1);

unitCnt = 1;
for unitID = 1:maxUnitNum
    disp(['now on unitID = ' num2str(unitID)]);
    targetUnits = unitID;
    reducedChannelSubtrains = extractChannels(shorterSubtrains, targetUnits);
    nonEmptySubtrains = removeEmptySamples(reducedChannelSubtrains);
    [spikeTrains, depVarByIDs] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);
    % the line below may take some time
    if ~isempty(spikeTrains)
        totalKernelTensor = getKernelTensor(spikeTrains, ks, kernelParams);
        depVars = indices2valuesByCellArray(orig_depVarTypes, depVarByIDs);
        weightMat = ((diagComponent - offDiag) * eye(unitID)) + (offDiag * ones(unitID));
        totalKernelMat = kernelTensor2mixtureKernelMat(totalKernelTensor, weightMat);
        [~, mse_kernel, ~, ~] = crossValidateKernelWithThinning(totalKernelMat, depVars, foldNum, reg, period, thinConditionsBy);        
        RMSEs(unitCnt,1) = sqrt(mean(mse_kernel));
        unitIDs(unitCnt) = unitID;
        unitCnt = unitCnt + 1;
        % save temp.RMSEs.mat RMSEs unitIDs
    end
end

disp(['RMSEs = ' num2str(RMSEs')]);

RMSEs(unitCnt:maxUnitNum) = [];
unitIDs(unitCnt:maxUnitNum) = [];

figure(figID);
plot(RMSEs);
xlabel('unit ID', 'FontName', 'Helvetica', 'FontSize', 18);
ylabel('RMSE', 'FontName', 'Helvetica', 'FontSize', 18);
xticks = unitIDs;
labelPointNum = 4;
labelSkipBy = ceil(length(xticks) / labelPointNum);
set(gca, 'TickDir', 'out', 'XTickLabel', xticks(1:labelSkipBy:numel(xticks)), 'XTick', 1:labelSkipBy:numel(xticks), 'FontName', 'Helvetica', 'FontSize', 18)

end

