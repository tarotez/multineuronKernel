[resampledSpikeTrainsBySampleID, resampled_sampleID2condID, randomIndicesMat] = resampleSpikeTrains(spikeTrainsBySampleID4bootstrap, depVarID4bootstrap, resampleTrialNum);
RMSE_popVec_orig = zeros(resampleTrialNum,1);
RMSE_popVec_subt = zeros(resampleTrialNum,1);
RMSE_maxLike_gaussian = zeros(resampleTrialNum,1);
RMSE_maxLike_poisson = zeros(resampleTrialNum,1);
RMSE_poissonRegression = zeros(resampleTrialNum,1);
RMSE_sum_kernel = zeros(resampleTrialNum,1);
RMSE_roufa_kernel = zeros(resampleTrialNum,1);
RMSE_fa_kernel = zeros(resampleTrialNum,1);
saveResampleStep = 10;
for resampleTrialID = 1:resampleTrialNum
   disp(['now starting resampleTrialID = ' num2str(resampleTrialID)])
   spikeTrainsBySampleID = resampledSpikeTrainsBySampleID{resampleTrialID};
   sampleID2condID = resampled_sampleID2condID{resampleTrialID};
   [mse_popVec_orig, mse_popVec_subt, mse_maxLike_gaussian, mse_maxLike_poisson, mse_poissonRegression, mse_sum_kernel, mse_roufa_kernel, mse_fa_kernel, test_depVar, est_depVar_popVec_orig, est_depVar_popVec_subt, est_depVar_maxLike_gaussian, est_depVar_maxLike_poisson, est_depVar_poissonRegression, est_depVar_sum_kernel, est_depVar_roufa_kernel, est_depVar_fa_kernel] = compareDecodingByDisplacement(evalTargets, spikeTrainsBySampleID, sampleID2condID, condNum, timeLength, thinConditionsBy, ksize_sum_kernel, ksize_fa_kernel, rankNum, allParamVecH, allParamVecV, regCoeff, binSize4poissonRegression, period);
   RMSE_popVec_orig(resampleTrialID,1) = sqrt(mean(mse_popVec_orig));
   RMSE_popVec_subt(resampleTrialID,1) = sqrt(mean(mse_popVec_subt));
   RMSE_maxLike_gaussian(resampleTrialID,1) = sqrt(mean(mse_maxLike_gaussian));
   RMSE_maxLike_poisson(resampleTrialID,1) = sqrt(mean(mse_maxLike_poisson));
   RMSE_poissonRegression(resampleTrialID,1) = sqrt(mean(mse_poissonRegression));
   RMSE_sum_kernel(resampleTrialID,1) = sqrt(mean(mse_sum_kernel));
   RMSE_roufa_kernel(resampleTrialID,1) = sqrt(mean(mse_roufa_kernel));
   RMSE_fa_kernel(resampleTrialID,1) = sqrt(mean(mse_fa_kernel));
   
   %-----
   % show results so far
   disp(['resampleTrialID = ' num2str(resampleTrialID)])
   figure(200)
   if sum(strcmp(evalTargets, 'sum'))
     disp(['  mean(RMSE_sum_kernel) = ' num2str(mean(RMSE_sum_kernel(1:resampleTrialID)))])   
   end
   if sum(strcmp(evalTargets, 'roufa'))
     disp(['  mean(RMSE_roufa_kernel) = ' num2str(mean(RMSE_roufa_kernel(1:resampleTrialID)))])
     boxplot([RMSE_roufa_kernel(1:resampleTrialID) - RMSE_sum_kernel(1:resampleTrialID)])
   end
   if sum(strcmp(evalTargets, 'fa'))
     disp(['  mean(RMSE_fa_kernel) = ' num2str(mean(RMSE_fa_kernel(1:resampleTrialID)))])
     boxplot([RMSE_fa_kernel(1:resampleTrialID) - RMSE_sum_kernel(1:resampleTrialID)])
   end
   
   if mod(resampleTrialID, saveResampleStep) == 0
     save res.compareDecodingByDisplacement.mat randomIndicesMat RMSE_popVec_orig RMSE_popVec_subt RMSE_maxLike_gaussian RMSE_maxLike_poisson RMSE_poissonRegression RMSE_sum_kernel RMSE_roufa_kernel RMSE_fa_kernel mse_popVec_orig mse_popVec_subt mse_maxLike_gaussian mse_maxLike_poisson mse_poissonRegression mse_sum_kernel mse_fa_kernel mse_roufa_kernel test_depVar est_depVar_popVec_orig est_depVar_popVec_subt est_depVar_maxLike_gaussian est_depVar_maxLike_poisson est_depVar_poissonRegression est_depVar_sum_kernel est_depVar_roufa_kernel est_depVar_fa_kernel ksize_sum_kernel ksize_fa_kernel regCoeff binSize4poissonRegression timeLength thinConditionsBy
   end
end
disp(['mean(RMSE_maxLike_poisson) = ' num2str(mean(RMSE_maxLike_poisson))])
disp(['mean(RMSE_poissonRegression) = ' num2str(mean(RMSE_poissonRegression))])
disp(['mean(RMSE_sum_kernel) = ' num2str(mean(RMSE_sum_kernel))])
disp(['mean(RMSE_roufa_kernel) = ' num2str(mean(RMSE_roufa_kernel))])
disp(['mean(RMSE_fa_kernel) = ' num2str(mean(RMSE_fa_kernel))])