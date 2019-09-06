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
function [allParamVec, logMarginalizedLikelihoodynamics, allParamVecDynamics, safeLoopCnt] = optimizeROUFAkernelByMarginalizedLikelihood(ks, multiSpikeTrainsBySampleID4optimization, depVar, origCoeffOfOneMat, elemKernelParams, origRegCoeff, sgdRandomSampleNum, learningRate, loopMax, saveIncrement)

%--------------
% set parameters
[sampleNum] = size(multiSpikeTrainsBySampleID4optimization,1);
[channelNum] = size(multiSpikeTrainsBySampleID4optimization{1},1);
disp(['sampleNum = ' num2str(sampleNum) ', channelNum = ' num2str(channelNum) ', learningRate = ' num2str(learningRate)]);
elemKernelParamNum = length(elemKernelParams);
allParamNum = elemKernelParamNum + 2;
loopCnt = 1;
logMarginalizedLikelihoodynamics = zeros(loopMax,1);
allParamVecDynamics = zeros(allParamNum, loopMax);
computeLogLikeStep = 500;
stopThresh = 10^-16;
increment = Inf;

%--------------
% initialize matrices
coeffOfOneMat = origCoeffOfOneMat;
regCoeff = origRegCoeff;
oldLogMarginalizedLikelihood = - Inf;
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
        disp(['log(diagMatCoeff + 1/channelNum) = ' num2str(coeffOfOneMat)]);
        % disp(['elemKernelParams = ' num2str(elemKernelParams')]);
        % disp(['regCoeff = ' num2str(regCoeff)]);
    end
    allParamVec = cat(1, coeffOfOneMat, elemKernelParams, regCoeff);   % log for diagMatVec
    % allParamVec = cat(1, lowRankMatVec, diagMatVec, elemKernelParams, regCoeff);   % no log for diagMatVec
    
    %-------------------
    % compute the kernel matrix
    weightMat = (exp(coeffOfOneMat) - (1/channelNum)) * ones(channelNum) + eye(channelNum);
    randOrder = randperm(sampleNum);
    randomSampleIndices = randOrder(1:sgdRandomSampleNum);
    kernelMat = kernelTensor2mixtureKernelMat(kernelTensor(randomSampleIndices,randomSampleIndices,:,:), weightMat) + (regCoeff * eye(sgdRandomSampleNum));
    depVar4sgd = depVar(randomSampleIndices);
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
        % disp('computing log likelihood');            
        logMarginalizedLikelihood = logMarginalizedLikelihoodFromKernelMat(depVar4sgd, kernelMat, invK);
        disp(['loopCnt = ' num2str(loopCnt)])
        disp([' logMarginalizedLikelihood = ' num2str(logMarginalizedLikelihood)]);
        disp([' coeffOfOneMat = ' num2str(coeffOfOneMat)]);
        % disp(['elemKernelParams = ' num2str(elemKernelParams')]);
        % disp(['regCoeff = ' num2str(regCoeff)]);
        % incrementOfLogLike = logMargLikelihood - oldLogMargLikelihood;
        % oldLogMarginalizedLikelihood = logMarginalizedLikelihood;
    end    
    logMarginalizedLikelihoodynamics(loopCnt) = logMarginalizedLikelihood;
        
    %-----
    % if logLikelihood decreases, break out of the main loop.
    if loopCnt > startCheckBreak;
        avgPastIncrease = mean(logMarginalizedLikelihoodynamics((loopCnt-6):(loopCnt-1)) - logMarginalizedLikelihoodynamics((loopCnt-7):(loopCnt-2)));
        newIncrease = logMarginalizedLikelihoodynamics(loopCnt) - logMarginalizedLikelihoodynamics(loopCnt-1);
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
        save dynamics.fa.mat allParamVec logMarginalizedLikelihoodynamics allParamVecDynamics loopCnt channelNum learningRate ks coeffOfOneMat elemKernelParams regCoeff
    end
    
    %--------------
    % get gradient tensor for the log coefficient of the identity matrix
    gradTensor4coeffOfOneMat = zeros(sgdRandomSampleNum,sgdRandomSampleNum);
    for sampleID1 = 1:sgdRandomSampleNum
        for sampleID2 = 1:sgdRandomSampleNum
            gradTensor4coeffOfOneMat(sampleID1,sampleID2) = sum(sum(kernelTensor(sampleID1,sampleID2,:,:)));
            % gradTensor4diagMatCoeff(sampleID1,sampleID2) = sum(diag(permute(kernelTensor(sampleID1,sampleID2,:,:),[3 4 1 2])));  % don't use log for diagMatVec
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
    % below is for revising the regularization coefficient
    % gradTensor4regCoeff = eye(sgdRandomSampleNum);
    % below is for not revising the regularization coefficient
    gradTensor4regCoeff = zeros(sgdRandomSampleNum);
    
    %--------------
    % compute final gradient tensor using kernelMat and gradTensor   
    gradTensor = cat(3, gradTensor4coeffOfOneMat, gradTensor4elemKernelParams, gradTensor4regCoeff);
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
    % disp(['gradient = ' num2str(gradient')]);

    %--------------
    % revise parameters
    allParamIncrement = learningRate * gradient;    
    % disp(['allParamIncrement = ' num2str(allParamIncrement')]);    
    allParamVec = allParamVec + allParamIncrement;
    coeffOfOneMat = allParamVec(1);
    coeffOfOneMat(coeffOfOneMat < - 1 / channelNum) = - 1 / channelNum;
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

