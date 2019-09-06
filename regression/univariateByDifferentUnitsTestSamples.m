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
function [RMSEs, unitIDs] = univariateByDifferentUnitsTestSamples(multiSpikeTrainsBySampleID4test, depVarID4test, timeLength, ksizeH, ksizeV, offDiagH, offDiagV, regCoeffH, regCoeffV, thinConditionsBy, period, condNum)

%-----
% set basic parameters
maxUnitNum = length(multiSpikeTrainsBySampleID4test{1});
kernelType = 'mci';
kernelSpecification = '';
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
kernelParamsH = [ksizeH, 1];
kernelParamsV = [ksizeV, 1];
foldNum = 0;
diagComponent = 1;

unitIDs = zeros(maxUnitNum,1);
RMSEs = zeros(maxUnitNum,1);

increment = period / condNum;
orig_depVarTypes = 0:increment:(period - increment);
depVars = indices2valuesByCellArray(orig_depVarTypes, depVarID4test);

unitCnt = 1;
for unitID = 1:maxUnitNum
    disp(['now on neuronID = ' num2str(unitID)]);
    targetUnits = unitID;
    
    spikeTrains = extractByUnits(multiSpikeTrainsBySampleID4test, targetUnits);
               
    % the line below may take some time
    if ~isempty(spikeTrains)
        totalKernelTensorH = getKernelTensor(spikeTrains, ks, kernelParamsH);
        totalKernelTensorV = getKernelTensor(spikeTrains, ks, kernelParamsV);
                
        weightMatH = ((diagComponent - offDiagH) * eye(unitID)) + (offDiagH * ones(unitID));
        weightMatV = ((diagComponent - offDiagV) * eye(unitID)) + (offDiagV * ones(unitID));

        totalKernelMatH = kernelTensor2mixtureKernelMat(totalKernelTensorH, weightMatH);
        totalKernelMatV = kernelTensor2mixtureKernelMat(totalKernelTensorV, weightMatV);
        
        [~, meanSquaredErrors, ~, ~] = crossValidateKernelWithThinning(totalKernelMatH, totalKernelMatV, depVars, foldNum, regCoeffH, regCoeffV, period, thinConditionsBy);
        
        RMSEs(unitCnt,1) = sqrt(nanmean(meanSquaredErrors));
        unitIDs(unitCnt) = unitID;
        unitCnt = unitCnt + 1;
        % save temp.RMSEs.mat RMSEs unitIDs
    end
end

disp(['RMSEs = ' num2str(RMSEs')]);

RMSEs(unitCnt:maxUnitNum) = [];
unitIDs(unitCnt:maxUnitNum) = [];

figure;
plot(RMSEs);
xlabel('neuron ID', 'FontName', 'Helvetica', 'FontSize', 18);
ylabel('RMSE', 'FontName', 'Helvetica', 'FontSize', 18);
xticks = unitIDs;
labelPointNum = 4;
labelSkipBy = ceil(length(xticks) / labelPointNum);
set(gca, 'TickDir', 'out', 'XTickLabel', xticks(1:labelSkipBy:numel(xticks)), 'XTick', 1:labelSkipBy:numel(xticks), 'FontName', 'Helvetica', 'FontSize', 18)

end

