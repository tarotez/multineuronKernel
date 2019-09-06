% coded by Taro Tezuka on 16.1.7
% optimize hyperparameters of factor analysis kernel by leave-one-out analysis likelihood
% Rasmussen and Williams, Gaussian Processes for Machine Learning, pg. 112 Section 5.4.1
% kernelTensor: sampleNum * sampleNum * channelNum * channelNum
% depVar: sampleNum
% lowRankMat: sampleNum * rankNum
% diagonalMatVec: sampleNum
% multivarSpikeTrains: {sampleNum}{channelNum}
% elemKernelParams: elemKernelParamNum
% mixture matrix: P = AA' + D;
% 
function [allParamVec, logLikelihoodDynamics, allParamVecDynamics, safeLoopCnt] = optimizeSumKernelByLeaveOneOut(ks, multiSpikeTrainsBySampleID4optimization, depVar, elemKernelParams, regCoeff, learningRate, loopMax, saveIncrement)

%--------------
% set parameters
[sampleNum] = size(multiSpikeTrainsBySampleID4optimization,1);
[channelNum] = size(multiSpikeTrainsBySampleID4optimization{1},1);
disp(['sampleNum = ' num2str(sampleNum) ', channelNum = ' num2str(channelNum) ', learningRate = ' num2str(learningRate)]);
elemKernelParamNum = length(elemKernelParams);
allParamNum = elemKernelParamNum + 1;
loopCnt = 1;
logLikelihoodDynamics = zeros(loopMax,1);
allParamVecDynamics = zeros(allParamNum, loopMax);
computeLogLikeStep = 5;
stopThresh = 10^-16;
increment = Inf;

%--------------
% initialize matrices
oldLogLikelihood = - Inf;
logLikelihood = - Inf;

%--------------
% loop for optimizing the parameters

% while loopCnt < loopMax && incrementOfLogLike > stopThresh
startCheckBreak = 20;
breakCoeff = 10;
brokenFromLoop = 0;
while loopCnt <= loopMax

    %-------------------
    % show parameters
    % if mod(loopCnt, computeLogLikeStep) == 0
        % disp(['elemKernelParams = ' num2str(elemKernelParams')]);        
        % disp(['regCoeff = ' num2str(regCoeff)]);
    % end
    allParamVec = cat(1, elemKernelParams, regCoeff);
    % allParamVec = cat(1, lowRankMatVec, diagMatVec, elemKernelParams, regCoeff);   % no log for diagMatVec
    
    %-------------------
    % compute the kernel matrix
    weightMat = eye(channelNum);
    kernelTensor = getKernelTensor(multiSpikeTrainsBySampleID4optimization, ks, elemKernelParams);
    kernelMat = kernelTensor2mixtureKernelMat(kernelTensor, weightMat) + (regCoeff * eye(sampleNum));
    % save temp.kernelMat.sum.mat kernelMat weightMat kernelTensor
    
    %-------------------
    % compute vector alpha and the inverse of kernelMat invKVec
    % disp('now computing matrix inverse and cholesky decomposition');
    R = chol(kernelMat);
    alpha = R \ (R' \ depVar);
    % invKVec = diag(inv(kernelMat));
    invKVec = diag(inv(R) * inv(R'));
   
    %------------------
    % compute log likelhiood
    if mod(loopCnt, computeLogLikeStep) == 0
        % disp('computing log likelihood');
        logLikelihood = logLeaveOneOutLikelihoodFromKernelMat(depVar, alpha, invKVec);
        disp(['loopCnt = ' num2str(loopCnt)])
        disp([' logLikelihood = ' num2str(logLikelihood)]);
        % disp([' elemKernelParams = ' num2str(elemKernelParams')]);
        % disp([' regCoeff = ' num2str(regCoeff)]);
        % incrementOfLogLike = logLikelihood - oldLogLikelihood;
        % oldLogLikelihood = logLikelihood;
    end    
    logLikelihoodDynamics(loopCnt) = logLikelihood;

    %-----
    % if logLikelihood decreases, break out of the main loop.
    if loopCnt > startCheckBreak;
        avgPastIncrease = mean(logLikelihoodDynamics((loopCnt-6):(loopCnt-1)) - logLikelihoodDynamics((loopCnt-7):(loopCnt-2)));
        newIncrease = logLikelihoodDynamics(loopCnt) - logLikelihoodDynamics(loopCnt-1);
        if newIncrease < (- breakCoeff) * avgPastIncrease
            safeLoopCnt = loopCnt - 10;
            brokenFromLoop = 1;
            break
        end
    end
    
    %--------------
    % save data
    allParamVecDynamics(:,loopCnt) = allParamVec;
    if mod(loopCnt, saveIncrement) == 0
        save dynamics.sum.mat allParamVec logLikelihoodDynamics allParamVecDynamics loopCnt channelNum learningRate ks elemKernelParams regCoeff
    end
    
    %--------------
    % get gradient tensor for the parameters of the elementary kernel
    % disp('now computing the gradient tensor for the parameters of the elementary kernel')
    gradTensor4elemKernelParams = zeros(sampleNum,sampleNum,length(elemKernelParams));
    for sampleID1 = 1:sampleNum
        % disp(['now at sampleID1 = ' num2str(sampleID1) ' out of sampleNum = ' num2str(sampleNum)])
        for sampleID2 = 1:sampleNum                   
            sumOfDerivs = 0;
            for channelID = 1:channelNum                    
                sumOfDerivs = sumOfDerivs + ks.dkernel(ks, multiSpikeTrainsBySampleID4optimization{sampleID1}{channelID}, multiSpikeTrainsBySampleID4optimization{sampleID2}{channelID}, elemKernelParams);
            end
            gradTensor4elemKernelParams(sampleID1,sampleID2,:) = sumOfDerivs;
        end
    end
    
    %--------------
    % get gradient tensor for the regularization coefficient
    % below is for revising the regularization coefficient
    %%% gradTensor4regCoeff = eye(sampleNum);
    % below is for not revising the regularization coefficient
    gradTensor4regCoeff = zeros(sampleNum);

    %--------------
    % compute final gradient tensor using kernelMat and gradTensor   
    gradTensor = cat(3, gradTensor4elemKernelParams, gradTensor4regCoeff);
    gradient = zeros(allParamNum,1);
    % disp('now computing the final gradient tensor');
    % diffOfGrams = (alpha * alpha') - invK;
    for paramID = 1:allParamNum        
        ZMat = R \ (R' \ gradTensor(:, :, paramID));
        Zalpha = ZMat * alpha;
        invKZTransVec = diag(R \ (R' \ ZMat'));
        gradBySamples = ((alpha .* Zalpha) - ((((alpha.^2) ./ invKVec) + 1) .* invKZTransVec / 2 )) ./ invKVec;
        gradient(paramID) = sum(gradBySamples);        
        % gradient(paramID) = sum(sum(bsxfun(@times, diffOfGrams, gradTensor(:,:,paramID)'))) / 2;
    end
    % disp(['gradient = ' num2str(gradient')]);

    %--------------
    % revise parameters
    allParamIncrement = learningRate * gradient;
    disp(['allParamIncrement = ' num2str(allParamIncrement')]);    
    allParamVec = allParamVec + allParamIncrement;
    elemKernelParams = allParamVec(1:end-1);
    regCoeff = allParamVec(end);
    regCoeff(regCoeff < 0) = 0;
    
    %------------------------
    % increment loopCnt
    loopCnt = loopCnt + 1;
    
end

if ~brokenFromLoop
    safeLoopCnt = loopMax;
end

end