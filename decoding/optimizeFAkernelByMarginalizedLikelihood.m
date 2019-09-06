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
function [allParamVec, logMarginalizedLikelihoodDynamics, allParamVecDynamics, safeLoopCnt] = optimizeFAkernelByMarginalizedLikelihood(ks, multiSpikeTrainsBySampleID4optimization, depVar, rankNum, coeff4lowRankMatVec, coeff4diagMatVec, elemKernelParams, regCoeff, sgdRandomSampleNum, learningRate, loopMax, saveIncrement)

%--------------
% set parameters
sampleNum = size(multiSpikeTrainsBySampleID4optimization,1);
channelNum = size(multiSpikeTrainsBySampleID4optimization{1},1);
disp(['sampleNum = ' num2str(sampleNum) ', channelNum = ' num2str(channelNum) ', rankNum = ' num2str(rankNum) ', learningRate = ' num2str(learningRate)]);
elemKernelParamNum = length(elemKernelParams);
allParamNum = channelNum * (rankNum + 1) + elemKernelParamNum + 1;
loopCnt = 1;
logMarginalizedLikelihoodDynamics = zeros(loopMax,1);
allParamVecDynamics = zeros(allParamNum, loopMax);
computeLogLikeStep = 500;

%--------------
% initialize matrices
lowRankMatVec = randn(channelNum*rankNum,1) * coeff4lowRankMatVec;
diagMatVec = abs(randn(channelNum,1)) * coeff4diagMatVec;
logMarginalizedLikelihood = - Inf;

%--------------
% kernelTensor for original elemKernelParams
kernelTensor = getKernelTensor(multiSpikeTrainsBySampleID4optimization, ks, elemKernelParams);

%--------------
% loop for optimizing the parameters

% while loopCnt < loopMax && incrementOfLogLike > stopThresh
startCheckBreak = 20;
breakCoeff = 10;
brokenFromLoop = 0;
while loopCnt <= loopMax

    %-------------------
    % show parameters
    if mod(loopCnt, computeLogLikeStep) == 0
        disp(['lowRankMatVec = ' num2str(lowRankMatVec')]);
        % disp(['diagMatVec = ' num2str(diagMatVec')]);
        disp(['sorted diagMatVec = ' num2str(sort(diagMatVec,'descend')')]);
        % disp(['elemKernelParams = ' num2str(elemKernelParams')]);
        % disp(['regCoeff = ' num2str(regCoeff)]);
    end
    % logDiagMatVec = log(diagMatVec);
    % allParamVec = cat(1, lowRankMatVec, logDiagMatVec, elemKernelParams, regCoeff);   % log for diagMatVec
    allParamVec = cat(1, lowRankMatVec, diagMatVec, elemKernelParams, regCoeff);   % no log for diagMatVec
    
    %-------------------
    % compute the kernel matrix
    lowRankMat = reshape(lowRankMatVec, channelNum, rankNum);
    diagMat = diag(diagMatVec);
    weightMat = lowRankMat * lowRankMat' + diagMat;
    randOrder = randperm(sampleNum);
    sgdRandomSampleIndices = randOrder(1:sgdRandomSampleNum);
    kernelMat = kernelTensor2mixtureKernelMat(kernelTensor(sgdRandomSampleIndices,sgdRandomSampleIndices,:,:), weightMat) + (regCoeff * eye(sgdRandomSampleNum));
    depVar4sgd = depVar(sgdRandomSampleIndices);
    % save temp.kernelMat.fa.mat kernelMat weightMat kernelTensor
    
    %-------------------
    % compute vector alpha and the inverse of kernelMat invKVec
    % disp('now computing matrix inverse and cholesky decomposition');
    R = chol(kernelMat);
    alpha = R \ (R' \ depVar4sgd);
    invK = inv(R) * inv(R');

    %------------------
    % compute log likelhiood
    if mod(loopCnt, computeLogLikeStep) == 0
        disp('computing log likelihood');
        logMarginalizedLikelihood = logMarginalizedLikelihoodFromKernelMat(depVar4sgd, kernelMat, invK);
        disp(['  loopCnt = ' num2str(loopCnt)])
        disp(['  logMarginalizedLikelihood = ' num2str(logMarginalizedLikelihood)]);
        % incrementOfLogLike = logMarginalizedLikelihood - oldLogMarginalizedLikelihood;
        % oldLogMarginalizedLikelihood = logMarginalizedLikelihood;
    end    
    logMarginalizedLikelihoodDynamics(loopCnt) = logMarginalizedLikelihood;
        
    %-----
    % if logLikelihood decreases, break out of the main loop.
    if loopCnt > startCheckBreak;
        avgPastIncrease = mean(logMarginalizedLikelihoodDynamics((loopCnt-6):(loopCnt-1)) - logMarginalizedLikelihoodDynamics((loopCnt-7):(loopCnt-2)));
        newIncrease = logMarginalizedLikelihoodDynamics(loopCnt) - logMarginalizedLikelihoodDynamics(loopCnt-1);
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
        save dynamics.fa.mat allParamVec logMarginalizedLikelihoodDynamics allParamVecDynamics loopCnt channelNum rankNum learningRate ks coeff4lowRankMatVec coeff4diagMatVec elemKernelParams regCoeff
    end
    
    %--------------
    % get gradient tensor for the low rank matrix
    gradTensor4lowRankMat = zeros(sgdRandomSampleNum,sgdRandomSampleNum,channelNum,rankNum);
    for sampleID1 = 1:sgdRandomSampleNum
        for sampleID2 = 1:sgdRandomSampleNum        
            Btemp = permute((kernelTensor(sampleID1,sampleID2,:,:) + kernelTensor(sampleID2,sampleID1,:,:)),[3 4 1 2]);
            gradTensor4lowRankMat(sampleID1,sampleID2,:,:) = Btemp * lowRankMat;
        end
    end
    gradTensor4lowRankMatVec = reshape(gradTensor4lowRankMat, [sgdRandomSampleNum sgdRandomSampleNum channelNum*rankNum]);

    %--------------
    % get gradient tensor for the diagonal matrix
    gradTensor4diagMatVec = zeros(sgdRandomSampleNum,sgdRandomSampleNum,channelNum);
    for sampleID1 = 1:sgdRandomSampleNum
        for sampleID2 = 1:sgdRandomSampleNum
            gradTensor4diagMatVec(sampleID1,sampleID2,:) = diagMatVec .* diag(permute(kernelTensor(sampleID1,sampleID2,:,:),[3 4 1 2]));   % log for diagMatVec
            % gradTensor4diagMatVec(sampleID1,sampleID2,:) = diag(permute(kernelTensor(sampleID1,sampleID2,:,:),[3 4 1 2]));  % no log for diagMatVec
        end
    end

    %--------------
    % get gradient tensor for the parameters of the elementary kernel
    gradTensor4elemKernelParams = zeros(sgdRandomSampleNum,sgdRandomSampleNum,length(elemKernelParams));
    %%%%% commented out 1606011357
    %{       
    disp('now computing the gradient tensor for the parameters of the elementary kernel')       
    for sampleID1 = 1:sgdRandomSampleNum
        for sampleID2 = 1:sgdRandomSampleNum                   
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
    %%% changed on 1606011357
    %%% gradTensor4regCoeff = eye(sgdRandomSampleNum);    
    gradTensor4regCoeff = zeros(sgdRandomSampleNum);
    
    %--------------
    % compute final gradient tensor using kernelMat and gradTensor   
    gradTensor = cat(3, gradTensor4lowRankMatVec, gradTensor4diagMatVec, gradTensor4elemKernelParams, gradTensor4regCoeff);
    gradient = zeros(allParamNum,1);
    % disp('now computing the final gradient tensor');
    diffOfGrams = (alpha * alpha') - invK;
    for paramID = 1:allParamNum
        %{
        ZMat = R \ (R' \ gradTensor(:, :, paramID));
        Zalpha = ZMat * alpha;
        invKZTransVec = diag(R \ (R' \ ZMat'));
        gradBySamples = ((alpha .* Zalpha) - ((((alpha.^2) ./ invKVec) + 1) .* invKZTransVec / 2 )) ./ invKVec;
        %}
        gradient(paramID) = sum(sum(bsxfun(@times, diffOfGrams, gradTensor(:,:,paramID)'))) / 2;
    end    

    %--------------
    % revise parameters
    allParamIncrement = learningRate * gradient;
    if mod(loopCnt, computeLogLikeStep) == 0   
        disp(['allParamIncrement = ' num2str(allParamIncrement')]);    
    end
    allParamVec = allParamVec + allParamIncrement;
    lowRankMatVec = allParamVec(1:channelNum*rankNum);
    % logDiagMatVec = allParamVec(channelNum*rankNum+1:channelNum*(rankNum+1));   % log for diagMatVec
    diagMatVec = allParamVec(channelNum*rankNum+1:channelNum*(rankNum+1));   % no log for diagMatVec    
    % diagMatVec = exp(logDiagMatVec);
    diagMatVec(diagMatVec < 0) = 0;   % when a component of diagMatVec is negative, revise it to 0.
    elemKernelParams = allParamVec(channelNum*(rankNum+1)+1:end-1);
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

