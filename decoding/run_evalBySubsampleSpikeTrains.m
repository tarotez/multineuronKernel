[subsampledSpikeTrainsBySampleID, subsampled_sampleID2condID, randomIndicesMat] = subsampleSpikeTrains(spikeTrainsBySampleID4bootstrap, depVarID4bootstrap, subsampleTrialNum, subsampleRatio);
RMSE_popVec_orig = zeros(subsampleTrialNum,1);
RMSE_popVec_subt = zeros(subsampleTrialNum,1);
RMSE_maxLike_gaussian = zeros(subsampleTrialNum,1);
RMSE_maxLike_poisson = zeros(subsampleTrialNum,1);
RMSE_poissonRegression = zeros(subsampleTrialNum,1);
RMSE_sum_kernel = zeros(subsampleTrialNum,1);
RMSE_roufa_kernel = zeros(subsampleTrialNum,1);
RMSE_fa_kernel = zeros(subsampleTrialNum,1);
totalKernelTensorH = getKernelTensor(spikeTrainsBySampleID4bootstrap, ks, kernelParamsH);
totalKernelTensorV = getKernelTensor(spikeTrainsBySampleID4bootstrap, ks, kernelParamsV);
for subsampleTrialID = 1:subsampleTrialNum
   disp(['now starting subsampleTrialID = ' num2str(subsampleTrialID)])
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
   
[mse_popVec_orig, mse_popVec_subt, mse_maxLike_gaussian, mse_maxLike_poisson, mse_poissonRegression, mse_sum_kernel, mse_roufa_kernel, mse_fa_kernel, test_depVar, est_depVar_popVec_orig, est_depVar_popVec_subt, est_depVar_maxLike_gaussian, est_depVar_maxLike_poisson, est_depVar_poissonRegression, est_depVar_sum_kernel, est_depVar_roufa_kernel, est_depVar_fa_kernel] = compareDecodingByDisplacement(evalTargets, spikeTrainsBySampleID, subsampledKernelTensorH, subsampledKernelTensorV, sampleID2condID, condNum, timeLength, thinConditionsBy, rankNum, offDiagElemH, offDiagElemV, regCoeffH, regCoeffV, binSize4poissonRegression, period, visualize);
   RMSE_popVec_orig(subsampleTrialID,1) = sqrt(mean(mse_popVec_orig));
   RMSE_popVec_subt(subsampleTrialID,1) = sqrt(mean(mse_popVec_subt));
   RMSE_maxLike_gaussian(subsampleTrialID,1) = sqrt(mean(mse_maxLike_gaussian));
   RMSE_maxLike_poisson(subsampleTrialID,1) = sqrt(mean(mse_maxLike_poisson));
   RMSE_poissonRegression(subsampleTrialID,1) = sqrt(mean(mse_poissonRegression));
   RMSE_sum_kernel(subsampleTrialID,1) = sqrt(mean(mse_sum_kernel));
   RMSE_roufa_kernel(subsampleTrialID,1) = sqrt(mean(mse_roufa_kernel));
   RMSE_fa_kernel(subsampleTrialID,1) = sqrt(mean(mse_fa_kernel));
   
   %-----
   % show results so far
   disp(['subsampleTrialID = ' num2str(subsampleTrialID)])
   if visualize
    figure(200)
   end
   if sum(strcmp(evalTargets, 'sum'))
     disp(['  mean(RMSE_sum_kernel) = ' num2str(mean(RMSE_sum_kernel(1:subsampleTrialID)))])   
   end
   if sum(strcmp(evalTargets, 'roufa'))
     disp(['  mean(RMSE_roufa_kernel) = ' num2str(mean(RMSE_roufa_kernel(1:subsampleTrialID)))])
     if visualize
        boxplot([RMSE_roufa_kernel(1:subsampleTrialID) - RMSE_sum_kernel(1:subsampleTrialID)])
     end
   end
   if sum(strcmp(evalTargets, 'fa'))
     disp(['  mean(RMSE_fa_kernel) = ' num2str(mean(RMSE_fa_kernel(1:subsampleTrialID)))])
     if visualize
        boxplot([RMSE_fa_kernel(1:subsampleTrialID) - RMSE_sum_kernel(1:subsampleTrialID)])
     end
   end
   
   if mod(subsampleTrialID, saveSubsampleStep) == 0
     save res.compareDecodingByDisplacement.mat randomIndicesMat RMSE_popVec_orig RMSE_popVec_subt RMSE_maxLike_gaussian RMSE_maxLike_poisson RMSE_poissonRegression RMSE_sum_kernel RMSE_roufa_kernel RMSE_fa_kernel mse_popVec_orig mse_popVec_subt mse_maxLike_gaussian mse_maxLike_poisson mse_poissonRegression mse_sum_kernel mse_fa_kernel mse_roufa_kernel test_depVar est_depVar_popVec_orig est_depVar_popVec_subt est_depVar_maxLike_gaussian est_depVar_maxLike_poisson est_depVar_poissonRegression est_depVar_sum_kernel est_depVar_roufa_kernel est_depVar_fa_kernel offDiagElemH offDiagElemV ksize_H ksize_V regCoeffH regCoeffV binSize4poissonRegression timeLength thinConditionsBy
   end
end
disp(['mean(RMSE_maxLike_poisson) = ' num2str(mean(RMSE_maxLike_poisson))])
disp(['mean(RMSE_poissonRegression) = ' num2str(mean(RMSE_poissonRegression))])
disp(['mean(RMSE_sum_kernel) = ' num2str(mean(RMSE_sum_kernel))])
disp(['mean(RMSE_roufa_kernel) = ' num2str(mean(RMSE_roufa_kernel))])
disp(['mean(RMSE_fa_kernel) = ' num2str(mean(RMSE_fa_kernel))])
if visualize
    figure(200)
    title('RMSE.roufa - RMSE.sum')
    ylabel('RMSE')
end
