% by Taro Tezuka since 15.1.16
% change the number of units for kernel regression and evaluate by RMSE
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
function [RMSEs, unitNums] = changeUnitNum(multivariateSubtrains, timeLength, ksize, offDiag, reg, thinConditionsBy, samplePointNum, figID)

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

skipBy = ceil(maxUnitNum / (samplePointNum - 1)) - 1;
unitNums = 1:skipBy:maxUnitNum;

unitCntNum = length(unitNums);
RMSEs = zeros(unitCntNum,1);

unitCnt = 1;
for unitNum = unitNums
    disp(['now on unitNum = ' num2str(unitNum)]);
    targetChannels = 1:unitNum;    
    reducedChannelSubtrains = extractChannels(shorterSubtrains, targetChannels);
    nonEmptySubtrains = removeEmptySamples(reducedChannelSubtrains);
    [spikeTrains, depVarByIDs] = condIDbyTrialID2globalSampleID(nonEmptySubtrains);
    % the line below may take some time
    totalKernelTensor = getKernelTensor(spikeTrains, ks, kernelParams);
    depVars = indices2valuesByCellArray(orig_depVarTypes, depVarByIDs);
    weightMat = ((diagComponent - offDiag) * eye(unitNum)) + (offDiag * ones(unitNum));
    totalKernelMat = kernelTensor2mixtureKernelMat(totalKernelTensor, weightMat);
    [~, mse_kernel, ~, ~] = crossValidateKernelWithThinning(totalKernelMat, depVars, foldNum, reg, period, thinConditionsBy);        
    RMSEs(unitCnt,1) = sqrt(mean(mse_kernel));
    unitCnt = unitCnt + 1;
    save temp.RMSEs.mat RMSEs unitNums
end

figure(figID);
plot(RMSEs);
xlabel('number of units', 'FontName', 'Helvetica', 'FontSize', 18);
ylabel('RMSE', 'FontName', 'Helvetica', 'FontSize', 18);
xticks = unitNums;
labelPointNum = 4;
labelSkipBy = ceil(length(xticks) / labelPointNum);
set(gca, 'TickDir', 'out', 'XTickLabel', xticks(1:labelSkipBy:numel(xticks)), 'XTick', 1:labelSkipBy:numel(xticks), 'FontName', 'Helvetica', 'FontSize', 18)

end

