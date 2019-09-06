% load dynamics.fa.mat

allParamVecDynamicsCutOff = allParamVecDynamics(:,1:loopCnt);
lowRankMatParamNum = rankNum * channelNum;
lowRankMatVec = allParamVecDynamicsCutOff(1:channelNum*rankNum,:);
logDiagMatVec = allParamVecDynamicsCutOff(channelNum*rankNum+1:channelNum*(rankNum+1),:);
diagMatVec = exp(logDiagMatVec);
diagMatVec(diagMatVec < 0) = 0;   % when a component of diagMatVec is negative, revise it to 0.
elemKernelParams = allParamVecDynamicsCutOff(channelNum*(rankNum+1)+1:end-1,:);
regCoeff = allParamVecDynamicsCutOff(end,:);
regCoeff(regCoeff < 0) = 0;

figure
plot(logLikelihoodLOODynamics(1:loopCnt))
title('logLikelihood')
figure
plot(lowRankMatVec')
title('lowRankMat')
figure
plot(diagMatVec')
title('diagMatVec')
figure
plot(elemKernelParams')
title('elemKernelParam')
figure
plot(regCoeff')
title('regCoeff')
