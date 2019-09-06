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
function [RMSEs, unitNums] = changeUnitNumTestSamples(multiSpikeTrainsBySampleID4test, depVarID4test, timeLength, ksizeH, ksizeV, offDiagH, offDiagV, regCoeffH, regCoeffV, thinConditionsBy, foldNum, period, condNum, samplePointNum, subsampleTrialNum, subsampleRatio)

%-----
% set basic parameters
maxUnitNum = length(multiSpikeTrainsBySampleID4test{1});
kernelType = 'mci';
kernelSpecification = '';
ks = kernelFactory(kernelType, timeLength, kernelSpecification);
kernelParamsH = [ksizeH, 1];
kernelParamsV = [ksizeV, 1];
diagComponent = 1;

skipBy = ceil(maxUnitNum / (samplePointNum - 1)) - 1;
unitNums = 1:skipBy:maxUnitNum;

unitCntNum = length(unitNums);
RMSEs = zeros(unitCntNum, subsampleTrialNum);

increment = period / condNum;
orig_depVarTypes = 0:increment:(period - increment);
depVars = indices2valuesByCellArray(orig_depVarTypes, depVarID4test);

[multiSpikeTrainsBySampleID4testSubsampled, depVarsSubsampled] = subsampleSpikeTrains(multiSpikeTrainsBySampleID4test, depVars, subsampleTrialNum, subsampleRatio);

unitCnt = 1;
for unitNum = unitNums

    disp(['now on neuronNum = ' num2str(unitNum)]);

    for subsampleID = 1:subsampleTrialNum    
        % disp(['now subsampleID = ' num2str(subsampleID)]);

        randomizedUnits = randperm(maxUnitNum);
        % targetUnits = 1:unitNum;
        targetUnits = randomizedUnits(1:unitNum);

        spikeTrains = extractByUnits(multiSpikeTrainsBySampleID4testSubsampled{subsampleID}, targetUnits);
                
        totalKernelTensorH = getKernelTensor(spikeTrains, ks, kernelParamsH);
        totalKernelTensorV = getKernelTensor(spikeTrains, ks, kernelParamsV);
        weightMatH = ((diagComponent - offDiagH) * eye(unitNum)) + (offDiagH * ones(unitNum));
        weightMatV = ((diagComponent - offDiagV) * eye(unitNum)) + (offDiagV * ones(unitNum));
        totalKernelMatH = kernelTensor2mixtureKernelMat(totalKernelTensorH, weightMatH);
        totalKernelMatV = kernelTensor2mixtureKernelMat(totalKernelTensorV, weightMatV);
        
        [~, meanSquaredErrors, est_depVar_vec, test_depVar_vec] = crossValidateKernelWithThinning(totalKernelMatH, totalKernelMatV, depVarsSubsampled{subsampleID}, foldNum, regCoeffH, regCoeffV, period, thinConditionsBy);

        RMSEs(unitCnt, subsampleID) = sqrt(nanmean(meanSquaredErrors));

    end
    
    unitCnt = unitCnt + 1;
    save temp.RMSEs.mat RMSEs unitNums meanSquaredErrors est_depVar_vec test_depVar_vec
        
end

boxplot(RMSEs');
xlabel('number of neurons', 'FontName', 'Helvetica', 'FontSize', 18);
ylabel('RMSE', 'FontName', 'Helvetica', 'FontSize', 18);
xticks = unitNums;
labelPointNum = 4;
labelSkipBy = ceil(length(xticks) / labelPointNum);
set(gca, 'TickDir', 'out', 'XTickLabel', xticks(1:labelSkipBy:numel(xticks)), 'XTick', 1:labelSkipBy:numel(xticks), 'FontName', 'Helvetica', 'FontSize', 18)

end

