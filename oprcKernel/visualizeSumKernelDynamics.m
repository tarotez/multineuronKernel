% load dynamics.sum.mat

allParamVecDynamicsCutOff = allParamVecDynamics(:,1:loopCnt);
elemKernelParams = allParamVecDynamicsCutOff(channelNum*(rankNum+1)+1:end-1,:);
regCoeff = allParamVecDynamicsCutOff(end,:);
regCoeff(regCoeff < 0) = 0;

figure
plot(logLikelihoodLOODynamics(1:loopCnt))
title('logLikelihood')
figure
plot(elemKernelParams')
title('elemKernelParam')
figure
plot(regCoeff')
title('regCoeff')
