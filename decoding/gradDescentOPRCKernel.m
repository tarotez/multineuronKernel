% coded by Taro Tezuka on 16.9.10
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
function [offDiag, logLikelihoodDynamics, offDiagDynamics, safeLoopCnt] = gradDescentOPRCKernel(likelihoodType, ks, multiSpikeTrainsBySampleID, depVar, elemKernelParams, regCoeff, learningRate, loopMax, saveIncrement)

%--------------
% set parameters
[sampleNum] = size(multiSpikeTrainsBySampleID,1);
[channelNum] = size(multiSpikeTrainsBySampleID{1},1);
disp(['sampleNum = ' num2str(sampleNum) ', channelNum = ' num2str(channelNum) ', learningRate = ' num2str(learningRate)]);
loopCnt = 1;
logLikelihoodDynamics = zeros(loopMax,1);
allParamNum = 1;
offDiagDynamics = zeros(allParamNum, loopMax);
computeLogLikeStep = 5;

%--------------
% initialize matrices
logLikelihood = - Inf;
    
kernelTensor = getKernelTensor(multiSpikeTrainsBySampleID, ks, elemKernelParams);
offDiag = 0;   % initialize offDiag

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
        % disp(['log(diagMatCoeff + 1/channelNum) = ' num2str(coeffOfOneMat)]);
        % disp(['elemKernelParams = ' num2str(elemKernelParams')]);        
        % disp(['regCoeff = ' num2str(regCoeff)]);
    % end
    % allParamVec = cat(1, lowRankMatVec, diagMatVec, elemKernelParams, regCoeff);   % no log for diagMatVec

    %-------------------
    % compute the kernel matrix
    weightMat = ((1 - offDiag) * eye(channelNum)) + (offDiag * ones(channelNum));
    kernelMat = kernelTensor2mixtureKernelMat(kernelTensor, weightMat) + (regCoeff * eye(sampleNum));
    % save temp.kernelMat.sum.mat kernelMat weightMat kernelTensor
    
    %-------------------
    % compute alpha (coefficient vector) and invKVec (the inverse of kernelMat)
    % disp('now computing matrix inverse and cholesky decomposition');

    %------------------
    % R and alpha must be computed here for later use in computing the
    % gradient
    R = chol(kernelMat);
    alpha = R \ (R' \ depVar);
    if strcmp(likelihoodType, 'marginalized')    
        invK = inv(R) * inv(R');
    elseif strcmp(likelihoodType, 'leaveOneOut')                                   
        % invKVec = diag(inv(kernelMat));            
        invKVec = diag(inv(R) * inv(R'));
    end
    
    %------------------
    % compute log likelhiood
    if mod(loopCnt, computeLogLikeStep) == 0
        % disp('computing log likelihood');
        if strcmp(likelihoodType, 'marginalized')
            logLikelihood = logMarginalizedLikelihoodFromKernelMat(depVar, kernelMat, invK);
        elseif strcmp(likelihoodType, 'leaveOneOut')                       
            logLikelihood = logLeaveOneOutLikelihoodFromKernelMat(depVar, alpha, invKVec);
        end
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
    offDiagDynamics(:,loopCnt) = offDiag;
    if mod(loopCnt, saveIncrement) == 0
        save dynamics.sum.mat offDiag logLikelihoodDynamics offDiagDynamics loopCnt channelNum learningRate ks elemKernelParams regCoeff
    end
        
    %--------------
    % get gradient tensor for the off diagonal component
    gradTensor4offDiag = zeros(sampleNum,sampleNum);
    for sampleID1 = 1:sampleNum
        for sampleID2 = 1:sampleNum
            gradTensor4offDiag(sampleID1,sampleID2) = sum(sum(kernelTensor(sampleID1,sampleID2,:,:))) - sum(diag(permute(kernelTensor(sampleID1,sampleID2,:,:),[3,4,1,2])));     % use log for diagMatVec
            % gradTensor4offDiag(sampleID1,sampleID2) = sum(diag(permute(kernelTensor(sampleID1,sampleID2,:,:),[3 4 1 2])));  % don't use log for diagMatVec
        end
    end
    
    %--------------
    % compute final gradient tensor using kernelMat and gradTensor   
    gradTensor = gradTensor4offDiag;
    gradient = zeros(allParamNum,1);
    % disp('now computing the final gradient tensor');
    if strcmp(likelihoodType, 'marginalized')
        diffOfGrams = (alpha * alpha') - invK;
        gradient = sum(sum(bsxfun(@times, diffOfGrams, gradTensor(:,:)'))) / 2;    
    elseif strcmp(likelihoodType, 'leaveOneOut')        
        ZMat = R \ (R' \ gradTensor(:, :, paramID));
        Zalpha = ZMat * alpha;
        invKZTransVec = diag(R \ (R' \ ZMat'));
        gradBySamples = ((alpha .* Zalpha) - ((((alpha.^2) ./ invKVec) + 1) .* invKZTransVec / 2 )) ./ invKVec;
        gradient = sum(gradBySamples);    
    end
    % disp(['gradient = ' num2str(gradient')]);

    %--------------
    % revise parameters
    offDiagIncrement = learningRate * gradient;
    disp(['offDiagIncrement = ' num2str(offDiagIncrement')]);    
    offDiag = offDiag + offDiagIncrement;
    if offDiag < - 1 / channelNum    
        offDiag = - 1 / channelNum; 
    elseif offDiag > 1    
        offDiag = 1;
    end    
    
    %------------------------
    % increment loopCnt
    loopCnt = loopCnt + 1;
    
end

if ~brokenFromLoop
    safeLoopCnt = loopMax;
end

end