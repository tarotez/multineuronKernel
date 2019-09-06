% Coded by Taro Tezuka since 2015.4.26
% cross validate different mixture kernels
% INPUT:
% OUTPUT:
%   errorTensor
%
function errorTensor = crossValidateMixtureKernels()

%----
% kernelParams = 5;
% kernelParams = 10;
% kernelParams = 11.3137;
% kernelParams = 50;
% kernelParams = [100, 1];
% kernelParams = 100;
kernelParams = 200;

%-----------
% read data
%%% [multivariateSpikeTrains, ~, ~, ~, ~] = spikeTrainsFromPVC3();
multivariateSpikeTrains = spikeTrainsFromCenterOut();
% timeLength = 4000;
% timeLength = 2000;
timeLength = 1000;
% timeLength = 200;
segmentNum = 1; % only one segment (length is 1 second) is used
% segmentNum = 2; % four segments (each one is 1 second long) is used
shorterSpikeTrains = divideByTimeLength(multivariateSpikeTrains, timeLength, segmentNum);
nonEmptySpikeTrains = removeEmptySamples(shorterSpikeTrains);
%----
% setup parameters for dependent variables
%%% orig_depVarTypes = 0:20:340;
orig_depVarTypes = 0:45:315;
period = 360;
%----
% setup parameters for regularization
rangeOfRegularizationCoeff = [10^-8, 10^8];
initialRegularizationCoeff = 10^2;
%----
% setup parameters for optimization
options4fmincon.MaxFunEvals = 10^6;   % the maximum number of evaluating the function during optimization.
%----
% setup kernel parameters
kernelType = 'mci';
segmentLength = timeLength;
kernelSpecification = '';
kernelStruct = kernelFactory(kernelType, segmentLength, kernelSpecification);

%----
% run cross validation
trialFoldSize4evaluation = 6;   % sets the number of trials used for training phase of the evaluation. it would be best to set it to the half of the average number of trials for each condition.
% sampleFoldSize4optimization = 4;   % set to 1 to do leave-one-out analysis. Smaller the value, more accurate but takes more time. Set to 16 for example for optimizing diagonally dominant mixture kernel.
sampleFoldSize4optimization = 1;   % set to 1 to do leave-one-out analysis. Smaller the value, more accurate but takes more time. Set to 16 for example for optimizing diagonally dominant mixture kernel.

condNum = size(nonEmptySpikeTrains,1);
condIDs4testSamples = 1:condNum;    
condIDs4trainSamples = 1:condNum;
testSampleNum4eachEvaluation = condNum * trialFoldSize4evaluation;

trialNums4eachCond = zeros(condNum,1);
for condID = 1:condNum
    trialNums4eachCond(condID) = size(nonEmptySpikeTrains{condID},1);
end
trialNum4evaluation = min(trialNums4eachCond);   % this is because all conditions are used for each evaluation.
trialFoldNum4evaluation = floor(trialNum4evaluation/trialFoldSize4evaluation);
disp(['trialNum4evaluation = ' num2str(trialNum4evaluation) ', trialFoldNum4evaluation = ' num2str(trialFoldNum4evaluation)]);

unitNum = size(multivariateSpikeTrains{1}{1},1);
unitSetNum = 4;   % setting to unitFoldNum = 1 might make it take too much time.
unitSetSize = floor(unitNum / unitSetNum);

methodNum = 5;
crossValidNum = trialFoldNum4evaluation * unitSetNum;
errorTensor = zeros(testSampleNum4eachEvaluation, crossValidNum, methodNum);
optimParams4identityX = cell(trialFoldNum4evaluation, unitSetNum);
optimParams4identityY = cell(trialFoldNum4evaluation, unitSetNum);
optimParams4diagonalX = cell(trialFoldNum4evaluation, unitSetNum); 
optimParams4diagonalY = cell(trialFoldNum4evaluation, unitSetNum);
optimParams4fairX = cell(trialFoldNum4evaluation, unitSetNum);
optimParams4fairY = cell(trialFoldNum4evaluation, unitSetNum);
optimParams4strDiagDominX = cell(trialFoldNum4evaluation, unitSetNum);
optimParams4strDiagDominY = cell(trialFoldNum4evaluation, unitSetNum);
optimParams4diagDominX = cell(trialFoldNum4evaluation, unitSetNum);
optimParams4diagDominY = cell(trialFoldNum4evaluation, unitSetNum);

crossValidID = 1;
sampleCnt = 1;

for firstTestSampleID4evaluation = 1:trialFoldNum4evaluation

    %----
    % set train and test sample IDs 
    testSampleIDs = firstTestSampleID4evaluation:trialFoldNum4evaluation:trialNum4evaluation;
    trainSampleIDs = 1:trialNum4evaluation;
    trainSampleIDs(testSampleIDs) = [];
    disp(['for crossValidID = ' num2str(crossValidID) ', sampleCnt = ' num2str(sampleCnt) ', trainSampleNum = ' num2str(size(trainSampleIDs,2)) ', trainSampleIDs = ' num2str(trainSampleIDs) ', condIDs4trainSamples = ' num2str(condIDs4trainSamples)]);
    disp(['for crossValidID = ' num2str(crossValidID) ', sampleCnt = ' num2str(sampleCnt) ', testSampleNum = ' num2str(size(testSampleIDs,2)) ', testSampleIDs = ' num2str(testSampleIDs) ', condIDs4testSamples = ' num2str(condIDs4testSamples)]);

    trainExtractedSpikeTrainsAllUnits = extractSampleSpikeTrains(nonEmptySpikeTrains, condIDs4trainSamples, trainSampleIDs);
    testExtractedSpikeTrainsAllUnits = extractSampleSpikeTrains(nonEmptySpikeTrains, condIDs4testSamples, testSampleIDs);

    for unitSetID = 1:unitSetNum
        % unitSetOffset = (unitSetID-1) * unitSetSize + 1;
        % targetUnitIDs = unitSetOffset:(unitSetOffset+unitSetSize-1);
        targetUnitIDs = unitSetID:unitSetNum:unitNum;
        
        disp(['for unitSetID = ' num2str(unitSetID) ', targetUnitIDs = ' num2str(targetUnitIDs)]);

        % get training samples                           
        trainExtractedSpikeTrains = extractUnits(trainExtractedSpikeTrainsAllUnits, targetUnitIDs);
        % disp(['trainExtractedSpikeTrains{1}{1}{1} = ' num2str(trainExtractedSpikeTrains{1}{1}{1})]);            
        [trainSpikeTrains, trainTotalDepVarIDs] = condIDbyTrialID2globalSampleID(trainExtractedSpikeTrains);

        disp(['size(trainSpikeTrains) = ' num2str(size(trainSpikeTrains))]);
        disp(['size(trainTotalDepVarIDs) = ' num2str(size(trainTotalDepVarIDs))]);

        trainTotalKernelTensor = getKernelTensor(trainSpikeTrains, kernelStruct, kernelParams);
        trainTotalDepVar = indices2valuesByCellArray(orig_depVarTypes, trainTotalDepVarIDs);
        trainTotalDepVarX = cos(trainTotalDepVar * 2 * pi / period);
        trainTotalDepVarY = sin(trainTotalDepVar * 2 * pi / period);            

        %----        
        % get test samples       
        disp(['condIDs4testSample = ' num2str(condIDs4testSamples)]);
        testExtractedSpikeTrains = extractUnits(testExtractedSpikeTrainsAllUnits, targetUnitIDs);
        % disp(['testExtractedSpikeTrains{1}{1}{1} = ' num2str(testExtractedSpikeTrains{1}{1}{1})]);            
        [testSpikeTrains, testTotalDepVarIDs] = condIDbyTrialID2globalSampleID(testExtractedSpikeTrains);

        disp(['size(testSpikeTrains) = ' num2str(size(testSpikeTrains))]);
        disp(['size(testTotalDepVarIDs) = ' num2str(size(testTotalDepVarIDs))]);            

        testTotalKernelTensor = getKernelTensor(testSpikeTrains, kernelStruct, kernelParams);
       
        testTotalDepVar = indices2valuesByCellArray(orig_depVarTypes, testTotalDepVarIDs);

        save res.train.and.test.kernel.temp.mat

        %----
        % identity diagonal matrix (sum kernel) (optimize regularization coefficient only)
        methodID = 1;
        [optimParamsX, fval] = optimizeIdentityCoeffMat(trainTotalKernelTensor, trainTotalDepVarX, rangeOfRegularizationCoeff, initialRegularizationCoeff, period, sampleFoldSize4optimization, options4fmincon);
        optimParams4identityX{sampleCnt,unitSetID}= optimParamsX;
        disp(['identity: optimParamsX = ' num2str(optimParamsX')])
        disp(['identity: fval = ' num2str(fval)])
        [optimParamsY, fval] = optimizeIdentityCoeffMat(trainTotalKernelTensor, trainTotalDepVarY, rangeOfRegularizationCoeff, initialRegularizationCoeff, period, sampleFoldSize4optimization, options4fmincon);
        optimParams4identityY{sampleCnt,unitSetID}= optimParamsY;
        disp(['identity: optimParamsY = ' num2str(optimParamsY')])
        disp(['identity: fval = ' num2str(fval)])        
        %----
        % test identity mixture coeff matrix        
        errorTensor(:, crossValidID, methodID) = leaveOneOut4identityCoeffMatByCartesian(optimParamsX, optimParamsY, testTotalKernelTensor, testTotalDepVar, period);
        disp(['identity: RMSE = ' num2str(sqrt(mean(power(errorTensor(:, crossValidID, methodID), 2))))]);
        disp(' ');                               

        %----
        % fair coefficient matrix
        methodID = 2;
        [optimParamsX, fval] = optimizeFairCoeffMat(trainTotalKernelTensor, trainTotalDepVarX, rangeOfRegularizationCoeff, initialRegularizationCoeff, period, sampleFoldSize4optimization, options4fmincon);
        optimParams4fairX{sampleCnt,unitSetID}= optimParamsX;
        disp(['fair: optimParamsX = ' num2str(optimParamsX')])
        disp(['fair: fval = ' num2str(fval)])
        [optimParamsY, fval] = optimizeFairCoeffMat(trainTotalKernelTensor, trainTotalDepVarY, rangeOfRegularizationCoeff, initialRegularizationCoeff, period, sampleFoldSize4optimization, options4fmincon);
        optimParams4fairY{sampleCnt,unitSetID}= optimParamsY;
        disp(['fair: optimParamsY = ' num2str(optimParamsY')])
        disp(['fair: fval = ' num2str(fval)])
        %----
        % test fair mixture coeff matrix
        errorTensor(:, crossValidID, methodID) = leaveOneOut4constantOffDiagElemsByCartesian(optimParamsX, optimParamsY, testTotalKernelTensor, testTotalDepVar, period);
        disp(['fair: RMSE = ' num2str(sqrt(mean(power(errorTensor(:, crossValidID, methodID), 2))))]);        
        disp(' ');

        %----
        % diagonal coefficient matrix (weighted sum kernel)
        methodID = 3;
        [optimParamsX, fval] = optimizeDiagonalCoeffMat(trainTotalKernelTensor, trainTotalDepVarX, rangeOfRegularizationCoeff, initialRegularizationCoeff, period, sampleFoldSize4optimization, options4fmincon);
        optimParams4diagonalX{sampleCnt,unitSetID}= optimParamsX;
        disp(['diagonal: optimParamsX = ' num2str(optimParamsX')])
        disp(['diagonal: fval = ' num2str(fval)])
        [optimParamsY, fval] = optimizeDiagonalCoeffMat(trainTotalKernelTensor, trainTotalDepVarY, rangeOfRegularizationCoeff, initialRegularizationCoeff, period, sampleFoldSize4optimization, options4fmincon);
        optimParams4diagonalY{sampleCnt,unitSetID}= optimParamsY;
        disp(['diagonal: optimParamsY = ' num2str(optimParamsY')])
        disp(['diagonal: fval = ' num2str(fval)])
        %----
        % test diagonal mixture coeff matrix
        errorTensor(:, crossValidID, methodID) = leaveOneOut4diagElemsByCartesian(optimParamsX, optimParamsY, testTotalKernelTensor, testTotalDepVar, period);                
        disp(['diagonal: RMSE = ' num2str(sqrt(mean(power(errorTensor(:, crossValidID, methodID), 2))))]);        
        disp(' ');

        
        %----
        % strongly diagonally dominant coefficient matrix
        methodID = 4;
        [optimParamsX, fval] = optimizeStronglyDiagDominCoeffMat(trainTotalKernelTensor, trainTotalDepVarX, rangeOfRegularizationCoeff, initialRegularizationCoeff, period, sampleFoldSize4optimization, options4fmincon); 
        optimParams4strDiagDominX{sampleCnt,unitSetID}= optimParamsX;
        disp(['strong: optimParamsX = ' num2str(optimParamsX')])
        disp(['strong: fval = ' num2str(fval)])                
        [optimParamsY, fval] = optimizeStronglyDiagDominCoeffMat(trainTotalKernelTensor, trainTotalDepVarY, rangeOfRegularizationCoeff, initialRegularizationCoeff, period, sampleFoldSize4optimization, options4fmincon); 
        optimParams4strDiagDominY{sampleCnt,unitSetID}= optimParamsY;
        disp(['strong: optimParamsY = ' num2str(optimParamsY')])
        disp(['strong: fval = ' num2str(fval)])
        %----
        % test strongly diagonally dominant coeff matrix
        errorTensor(:, crossValidID, methodID) = leaveOneOut4offDiagElemsByCartesian(optimParamsX, optimParamsY, testTotalKernelTensor, testTotalDepVar, period);                                
        disp(['strong: RMSE = ' num2str(sqrt(mean(power(errorTensor(:, crossValidID, methodID), 2))))]);
        disp(' ');   
        
        
        %{
        
        %----
        % diagonally dominant coefficient matrix
        methodID = 5;
        [optimParamsX, fval] = optimizeDiagDominCoeffMat(trainTotalKernelTensor, trainTotalDepVar, rangeOfRegularizationCoeff, initialRegularizationCoeff, period, sampleFoldSize4optimization, options4fmincon);
        optimParams4diagDominX{sampleCnt,unitSetID}= optimParamsX;
        disp(['dominant: optimParamsX = ' num2str(optimParamsX')])
        disp(['dominant: fval = ' num2str(fval)])                
        [optimParamsY, fval] = optimizeDiagDominCoeffMat(trainTotalKernelTensor, trainTotalDepVar, rangeOfRegularizationCoeff, initialRegularizationCoeff, period, sampleFoldSize4optimization, options4fmincon);
        optimParams4diagDominY{sampleCnt,unitSetID}= optimParamsY;
        disp(['dominant: optimParamsY = ' num2str(optimParamsY')])
        disp(['dominant: fval = ' num2str(fval)])
        %----
        % test diagonally dominant coeff matrix
        errorTensor(:, crossValidID, methodID) = leaveOneOut4wholeMixingCoeffMatByCartesian(optimParamsX, optimParamsY, testTotalKernelTensor, testTotalDepVar, period);                                        
        disp(['dominant: RMSE = ' num2str(sqrt(mean(power(errorTensor(:, crossValidID, methodID), 2))))]);
        %}
        
        %-----
        % save data
        save res.crossValidateMixtureKernels.mat
        %-----
        % increment crossValidID
        crossValidID = crossValidID + 1;                    
    end       
    sampleCnt = sampleCnt + 1;
end

end

