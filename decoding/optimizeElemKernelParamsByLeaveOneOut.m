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
function [allParamVec, logLikelihoodLOODynamics, allParamVecDynamics] = optimizeElemKernelParamsByLeaveOneOut(ks, multiSpikeTrains, depVar, rankNum, lowRankMatVec, diagMatVec, elemKernelParams, regCoeff, learningRate)

%--------------
% set parameters
[sampleNum] = size(multiSpikeTrains,1);
[channelNum] = size(multiSpikeTrains{1},1);
disp(['sampleNum = ' num2str(sampleNum) ', channelNum = ' num2str(channelNum) ', rankNum = ' num2str(rankNum) ', learningRate = ' num2str(learningRate)]);
elemKernelParamNum = length(elemKernelParams);
allParamNum = channelNum * (rankNum + 1) + elemKernelParamNum + 1;
loopCnt = 1;
loopMax = 1000;
logLikelihoodLOODynamics = zeros(loopMax,1);
allParamVecDynamics = zeros(allParamNum, loopMax);
computeLogLikeStep = 1;
stopThresh = 10^-16;
increment = Inf;

%--------------
% initialize matrices
oldLogLikelihoodLOO = - Inf;
logLikelihoodLOO = - Inf;

%--------------
% loop for optimizing the parameters

% while loopCnt < loopMax && incrementOfLogLike > stopThresh
while loopCnt < loopMax

    %-------------------
    % show parameters
    disp(['lowRankMatVec = ' num2str(lowRankMatVec')]);
    disp(['diagMatVec = ' num2str(diagMatVec')]);
    disp(['sorted diagMatVec = ' num2str(sort(diagMatVec,'descend')')]);
    disp(['elemKernelParams = ' num2str(elemKernelParams')]);
    disp(['regCoeff = ' num2str(regCoeff)]);
    logDiagMatVec = log(diagMatVec);
    allParamVec = cat(1, lowRankMatVec, logDiagMatVec, elemKernelParams, regCoeff);   % log for diagMatVec
    % allParamVec = cat(1, lowRankMatVec, diagMatVec, elemKernelParams, regCoeff);   % no log for diagMatVec
    
    %-------------------
    % compute the kernel matrix
    lowRankMat = reshape(lowRankMatVec, channelNum, rankNum);
    diagMat = diag(diagMatVec);
    weightMat = lowRankMat * lowRankMat' + diagMat;
    kernelTensor = getKernelTensor(multiSpikeTrains, ks, elemKernelParams);
    kernelMat = kernelTensor2mixtureKernelMat(kernelTensor, weightMat) + (regCoeff * eye(sampleNum));
    save temp.kernelMat.fa.mat kernelMat weightMat kernelTensor
    
    %-------------------
    % compute vector alpha and the inverse of kernelMat invKVec
    disp('now computing matrix inverse and cholesky decomposition');
    R = chol(kernelMat);
    alpha = R \ (R' \ depVar);
    % invKVec = diag(inv(kernelMat));
    invKVec = diag(inv(R) * inv(R'));
   
    %------------------
    % compute log likelhiood
    if mod(loopCnt, computeLogLikeStep) == 0
        disp('computing log likelihood');
        logLikelihoodLOO = logLikelihoodFromKernelMat(depVar, alpha, invKVec);
        disp(['loopCnt = ' num2str(loopCnt)])
        disp(['logLikelihoodLOO = ' num2str(logLikelihoodLOO)]);
        incrementOfLogLike = logLikelihoodLOO - oldLogLikelihoodLOO;
        oldLogLikelihoodLOO = logLikelihoodLOO;
    end    
    logLikelihoodLOODynamics(loopCnt) = logLikelihoodLOO;
    
    %--------------
    % save data
    allParamVecDynamics(:,loopCnt) = allParamVec;
    save dynamics.fa.mat logLikelihoodLOODynamics allParamVecDynamics loopCnt channelNum rankNum learningRate ks
        
    %--------------
    % get gradient tensor for the low rank matrix    
    gradTensor4lowRankMat = zeros(sampleNum,sampleNum,channelNum,rankNum);
    %{
    for sampleID1 = 1:sampleNum
        for sampleID2 = 1:sampleNum        
            Btemp = permute((kernelTensor(sampleID1,sampleID2,:,:) + kernelTensor(sampleID2,sampleID1,:,:)),[3 4 1 2]);
            gradTensor4lowRankMat(sampleID1,sampleID2,:,:) = Btemp * lowRankMat;
        end
    end
    %}
    gradTensor4lowRankMatVec = reshape(gradTensor4lowRankMat, [sampleNum sampleNum channelNum*rankNum]);    
    
    %--------------
    % get gradient tensor for the diagonal matrix
    gradTensor4diagMatVec = zeros(sampleNum,sampleNum,channelNum);
    %{
    for sampleID1 = 1:sampleNum
        for sampleID2 = 1:sampleNum
            gradTensor4diagMatVec(sampleID1,sampleID2,:) = diagMatVec .* diag(permute(kernelTensor(sampleID1,sampleID2,:,:),[3 4 1 2]));   % log for diagMatVec
            % gradTensor4diagMatVec(sampleID1,sampleID2,:) = diag(permute(kernelTensor(sampleID1,sampleID2,:,:),[3 4 1 2]));  % no log for diagMatVec
        end
    end
    %}

    %--------------
    % get gradient tensor for the parameters of the elementary kernel
    disp('now computing the gradient tensor for the parameters of the elementary kernel')       
    gradTensor4elemKernelParams = zeros(sampleNum,sampleNum,length(elemKernelParams));
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

    %--------------
    % get gradient tensor for the regularization coefficient
    gradTensor4regCoeff = zeros(sampleNum);
    %{
    gradTensor4regCoeff = eye(sampleNum);
    %}
    
    %--------------
    % compute final gradient tensor using kernelMat and gradTensor   
    gradTensor = cat(3, gradTensor4lowRankMatVec, gradTensor4diagMatVec, gradTensor4elemKernelParams, gradTensor4regCoeff);
    gradient = zeros(allParamNum,1);
    disp('now computing the final gradient tensor');
    for paramID = 1:allParamNum    
        ZMat = R \ (R' \ gradTensor(:, :, paramID));
        Zalpha = ZMat * alpha;
        invKZTransVec = diag(R \ (R' \ ZMat'));
        gradBySamples = ((alpha .* Zalpha) - ((((alpha.^2) ./ invKVec) + 1) .* invKZTransVec / 2 )) ./ invKVec;
        gradient(paramID) = sum(gradBySamples);
    end
    disp(['gradient = ' num2str(gradient')]);

    %--------------
    % revise parameters
    allParamIncrement = learningRate * gradient;    
    disp(['allParamIncrement = ' num2str(allParamIncrement')]);    
    allParamVec = allParamVec + allParamIncrement;
    lowRankMatVec = allParamVec(1:channelNum*rankNum);
    logDiagMatVec = allParamVec(channelNum*rankNum+1:channelNum*(rankNum+1));   % log for diagMatVec
    % diagMatVec = allParamVec(channelNum*rankNum+1:channelNum*(rankNum+1));   % no log for diagMatVec    
    diagMatVec = exp(logDiagMatVec);
    diagMatVec(diagMatVec < 0) = 0;   % when a component of diagMatVec is negative, revise it to 0.
    elemKernelParams = allParamVec(channelNum*(rankNum+1)+1:end-1);
    regCoeff = allParamVec(end);
    regCoeff(regCoeff < 0) = 0;
    
    %------------------------
    % increment loopCnt
    loopCnt = loopCnt + 1;
    
end

end

