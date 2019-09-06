function [RMSEs, cputimesMat] = evalBySubsampleSpikeTrains(spikeTrainsBySampleID4test, depVarID4test, sp)

offDiagElemH = sp.offDiagElemH;
offDiagElemV = sp.offDiagElemV;
kernelParamsH = sp.kernelParamsH;
kernelParamsV = sp.kernelParamsV;
regCoeffH = sp.regCoeffH;
regCoeffV = sp.regCoeffV;
evalTargets = sp.evalTargets;
ks = sp.ks;
condNum = sp.condNum;
rankNum = sp.rankNum;
period = sp.period;
timeLength = sp.timeLength;
visualize = sp.visualize;
binSize4poissonRegression = sp.binSize4poissonRegression;
subsampleTrialNum = sp.subsampleTrialNum;
subsampleRatio = sp.subsampleRatio;
saveSubsampleStep = sp.saveSubsampleStep;
thinConditionsBy = sp.thinConditionsBy;

disp('now starting subsampleSpikeTrains()')
[subsampledSpikeTrainsBySampleID, subsampled_sampleID2condID, randomIndicesMat] = subsampleSpikeTrains(spikeTrainsBySampleID4test, depVarID4test, subsampleTrialNum, subsampleRatio);
RMSE_popVec_orig = zeros(subsampleTrialNum,1);
RMSE_popVec_subt = zeros(subsampleTrialNum,1);
RMSE_maxLike_gaussian = zeros(subsampleTrialNum,1);
RMSE_maxLike_poisson = zeros(subsampleTrialNum,1);
RMSE_poissonRegression = zeros(subsampleTrialNum,1);
RMSE_sum_kernel = zeros(subsampleTrialNum,1);
RMSE_oprc_kernel = zeros(subsampleTrialNum,1);
RMSE_fa_kernel = zeros(subsampleTrialNum,1);
totalKernelTensorH = getKernelTensor(spikeTrainsBySampleID4test, ks, kernelParamsH);
totalKernelTensorV = getKernelTensor(spikeTrainsBySampleID4test, ks, kernelParamsV);

cputimesMat = zeros(subsampleTrialNum,6);

for subsampleTrialID = 1:subsampleTrialNum
   disp(['  now starting subsampleTrialID = ' num2str(subsampleTrialID)])
   spikeTrainsBySampleID = subsampledSpikeTrainsBySampleID{subsampleTrialID};
   sampleID2condID = subsampled_sampleID2condID{subsampleTrialID};
   subsampleIDs = randomIndicesMat(:,subsampleTrialID);
   subsampledKernelTensorH = totalKernelTensorH(subsampleIDs, subsampleIDs, :, :);
   subsampledKernelTensorV = totalKernelTensorV(subsampleIDs, subsampleIDs, :, :);   
   %{
   size_totalKernelTensorH = size(totalKernelTensorH)
   size_subsampledKernelTensorH = size(subsampledKernelTensorH)
   some_totalKernelTensorH = totalKernelTensorH(1:10,1:10,:,:)
   some_subsampledKernelTensorH = subsampledKernelTensorH(1:10,1:10,:,:)
   %}
   
   disp('now starting compareDecodingByDisplacement()')
   [mses, test_depVar, est_depVars, cputimes] = compareDecodingByDisplacement(evalTargets, spikeTrainsBySampleID, subsampledKernelTensorH, subsampledKernelTensorV, sampleID2condID, condNum, timeLength, thinConditionsBy, rankNum, offDiagElemH, offDiagElemV, regCoeffH, regCoeffV, binSize4poissonRegression, period, visualize);

    cputimesMat(subsampleTrialID,:) = cputimes;
%{
   RMSE_popVec_orig(subsampleTrialID,1) = sqrt(mean(mses.popVec_orig));
   RMSE_popVec_subt(subsampleTrialID,1) = sqrt(mean(mses.popVec_subt));
   RMSE_maxLike_gaussian(subsampleTrialID,1) = sqrt(mean(mses.maxLike_gaussian));
   RMSE_maxLike_poisson(subsampleTrialID,1) = sqrt(mean(mses.maxLike_poisson));
   RMSE_poissonRegression(subsampleTrialID,1) = sqrt(mean(mses.poissonRegression));
%}
   RMSE_sum_kernel(subsampleTrialID,1) = sqrt(mean(mses.sum_kernel));
   RMSE_oprc_kernel(subsampleTrialID,1) = sqrt(mean(mses.oprc_kernel));
%   RMSE_fa_kernel(subsampleTrialID,1) = sqrt(mean(mses.fa_kernel));
   
   %-----
   % show results so far
   disp(['subsampleTrialID = ' num2str(subsampleTrialID)])
   if visualize
    figure(200)
   end
   if sum(strcmp(evalTargets, 'sum'))
     disp(['  mean(RMSE_sum_kernel) = ' num2str(mean(RMSE_sum_kernel(1:subsampleTrialID)))])   
   end
   if sum(strcmp(evalTargets, 'oprc'))
     disp(['  mean(RMSE_oprc_kernel) = ' num2str(mean(RMSE_oprc_kernel(1:subsampleTrialID)))])
     % if visualize
     %   boxplot([RMSE_oprc_kernel(1:subsampleTrialID) - RMSE_sum_kernel(1:subsampleTrialID)])
     % end
   end
   if sum(strcmp(evalTargets, 'fa'))
     disp(['  mean(RMSE_fa_kernel) = ' num2str(mean(RMSE_fa_kernel(1:subsampleTrialID)))])
     % if visualize
     %    boxplot([RMSE_fa_kernel(1:subsampleTrialID) - RMSE_sum_kernel(1:subsampleTrialID)])
     % end
   end   
   if mod(subsampleTrialID, saveSubsampleStep) == 0
     save res.compareDecodingByDisplacement.mat randomIndicesMat mses test_depVar est_depVars
   end
end
disp(['mean(RMSE_maxLike_poisson) = ' num2str(mean(RMSE_maxLike_poisson))])
disp(['mean(RMSE_poissonRegression) = ' num2str(mean(RMSE_poissonRegression))])
disp(['mean(RMSE_sum_kernel) = ' num2str(mean(RMSE_sum_kernel))])
disp(['mean(RMSE_oprc_kernel) = ' num2str(mean(RMSE_oprc_kernel))])
disp(['mean(RMSE_fa_kernel) = ' num2str(mean(RMSE_fa_kernel))])
if visualize == 1
    figure(200)
    title('RMSE.oprc - RMSE.sum')
    boxplot(RMSE_oprc_kernel - RMSE_sum_kernel)
    ylabel('RMSE')
end

RMSEs.RMSE_popVec_orig = RMSE_popVec_orig;
RMSEs.RMSE_popVec_subt = RMSE_popVec_subt;
RMSEs.RMSE_maxLike_gaussian = RMSE_maxLike_gaussian;
RMSEs.RMSE_maxLike_poisson = RMSE_maxLike_poisson;
RMSEs.RMSE_poissonRegression = RMSE_poissonRegression;
RMSEs.RMSE_sum_kernel = RMSE_sum_kernel;
RMSEs.RMSE_oprc_kernel = RMSE_oprc_kernel;
RMSEs.RMSE_fa_kernel = RMSE_fa_kernel;

end
