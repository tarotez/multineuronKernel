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
function [allParamVec, logLikelihoodLOODynamics, allParamVecDynamics, safeLoopCnt] = optimizeOPRCkernelByLeaveOneOut(ks, multiSpikeTrains, depVar, origOffDiagElem, elemKernelParams, origRegCoeff, learningRate, loopMax, saveIncrement)

%--------------
% set parameters
[sampleNum] = size(multiSpikeTrains,1);
[channelNum] = size(multiSpikeTrains{1},1);
disp(['sampleNum = ' num2str(sampleNum) ', channelNum = ' num2str(channelNum) ', learningRate = ' num2str(learningRate)]);
elemKernelParamNum = length(elemKernelParams);
allParamNum = elemKernelParamNum + 2;
loopCnt = 1;
logLikelihoodLOODynamics = zeros(loopMax,1);
allParamVecDynamics = zeros(allParamNum, loopMax);
computeLogLikeStep = 20;
stopThresh = 10^-16;
increment = Inf;

%--------------
% initialize matrices
offDiagElem = origOffDiagElem;
regCoeff = origRegCoeff;
oldLogLikelihoodLOO = - Inf;
logLikelihoodLOO = - Inf;

%--------------
% kernelTensor for original elemKernelParams
kernelTensor = getKernelTensor(multiSpikeTrains, ks, elemKernelParams);

%--------------
% loop for optimizing the parameters

% while loopCnt < loopMax && incrementOfLogLike > stopThresh
startCheckBreak = 20;
breakCoeff = 10;
brokenFromLoop = 0;
while loopCnt <= loopMax

    %-------------------
    % show parameters
    % disp(['logDiagMatCoeff = ' num2str(logDiagMatCoeff)]);
    % disp(['elemKernelParams = ' num2str(elemKernelParams')]);
    % disp(['regCoeff = ' num2str(regCoeff)]);
    allParamVec = cat(1, offDiagElem, elemKernelParams, regCoeff);   % log for diagMatVec
    % allParamVec = cat(1, lowRankMatVec, diagMatVec, elemKernelParams, regCoeff);   % no log for diagMatVec
    
    %-------------------
    % compute the kernel matrix
    % weightMat = (exp(logCoeffOfOneMatPlusInverseChannelNum) - (1/channelNum)) * ones(channelNum) + eye(channelNum);
    weightMat = (offDiagElem * ones(channelNum)) + ((1 - offDiagElem) * eye(channelNum));
    %%% commented out on 1606011357
    %%% kernelTensor = getKernelTensor(multiSpikeTrains, ks, elemKernelParams);
    kernelMat = kernelTensor2mixtureKernelMat(kernelTensor, weightMat) + (regCoeff * eye(sampleNum));
    % save temp.kernelMat.fa.mat kernelMat weightMat kernelTensor
    
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
        logLikelihoodLOO = logLikelihoodFromKernelMat(depVar, alpha, invKVec);
        disp(['loopCnt = ' num2str(loopCnt)])
        disp([' logLikelihoodLOO = ' num2str(logLikelihoodLOO)]);
        disp([' coffDiagElem = ' num2str(offDiagElem)]);
        % disp(['elemKernelParams = ' num2str(elemKernelParams')]);
        % disp(['regCoeff = ' num2str(regCoeff)]);
        % incrementOfLogLike = logLikelihoodLOO - oldLogLikelihoodLOO;
        % oldLogLikelihoodLOO = logLikelihoodLOO;
    end    
    logLikelihoodLOODynamics(loopCnt) = logLikelihoodLOO;
        
    %-----
    % if logLikelihood decreases, break out of the main loop.
    if loopCnt > startCheckBreak
        avgPastIncrease = mean(logLikelihoodLOODynamics((loopCnt-6):(loopCnt-1)) - logLikelihoodLOODynamics((loopCnt-7):(loopCnt-2)));
        newIncrease = logLikelihoodLOODynamics(loopCnt) - logLikelihoodLOODynamics(loopCnt-1);
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
        save dynamics.fa.mat allParamVec logLikelihoodLOODynamics allParamVecDynamics loopCnt channelNum learningRate ks offDiagElem elemKernelParams regCoeff
    end
    
    %--------------
    % get gradient tensor for off diagonal elements (gamma)
    gradTensor4offDiagElem = zeros(sampleNum,sampleNum);
    for sampleID1 = 1:sampleNum
        for sampleID2 = 1:sampleNum
            gradTensor4offDiagElem(sampleID1,sampleID2) = sum(sum(kernelTensor(sampleID1,sampleID2,:,:))) - sum(diag(permute(kernelTensor(sampleID1,sampleID2,:,:),[3 4 1 2])));   % use log for diagMatVec
            % gradTensor4diagMatCoeff(sampleID1,sampleID2) = sum(diag(permute(kernelTensor(sampleID1,sampleID2,:,:),[3 4 1 2])));  % don't use log for diagMatVec
        end
    end

    %--------------
    % get gradient tensor for the parameters of the elementary kernel
    gradTensor4elemKernelParams = zeros(sampleNum,sampleNum,length(elemKernelParams));
    %%%%% commented out 1606011357
    %{
    disp('now computing the gradient tensor for the parameters of the elementary kernel')  
    for sampleID1 = 1:sampleNum
        for sampleID2 = 1:sampleNum                   
            sumOfDerivs = 0;
            for channelID1 = 1:channelNum
                for channelID2 = 1:channelNum
                    sumOfDerivs = sumOfDerivs + ks.dkernel(ks, multiSpikeTrains{sampleID1}{channelID1}, multiSpikeTrains{sampleID2}{channelID2}, elemKernelParams) * weightMat(channelID1,channelID2);
                end
            end
            gradTensor4elemKernelParams(sampleID1,sampleID2,:) = sumOfDerivs;
        end
    end
    %}
    
    %--------------
    % get gradient tensor for the regularization coefficient
    % below is for revising the regularization coefficient
    % gradTensor4regCoeff = eye(sampleNum);
    % below is for not revising the regularization coefficient
    gradTensor4regCoeff = zeros(sampleNum);
    
    %--------------
    % compute final gradient tensor using kernelMat and gradTensor   
    gradTensor = cat(3, gradTensor4offDiagElem, gradTensor4elemKernelParams, gradTensor4regCoeff);
    gradient = zeros(allParamNum,1);
    % disp('now computing the final gradient tensor');
    for paramID = 1:allParamNum    
        ZMat = R \ (R' \ gradTensor(:, :, paramID));
        Zalpha = ZMat * alpha;
        invKZTransVec = diag(R \ (R' \ ZMat'));
        gradBySamples = ((alpha .* Zalpha) - ((((alpha.^2) ./ invKVec) + 1) .* invKZTransVec / 2 )) ./ invKVec;
        gradient(paramID) = sum(gradBySamples);
    end
    % disp(['gradient = ' num2str(gradient')]);

    %--------------
    % revise parameters
    allParamIncrement = learningRate * gradient;    
    % disp(['allParamIncrement = ' num2str(allParamIncrement')]);    
    allParamVec = allParamVec + allParamIncrement;
    offDiagElem = allParamVec(1);
    if offDiagElem < - 1 / (channelNum - 1)
        offDiagElem = - 1 / (channelNum - 1);
    end
    elemKernelParams = allParamVec(2:end-1);
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

