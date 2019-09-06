% coded by Taro Tezuka since 14.10.21
% cross validation for decoding methods (popVector and maxLike)
% INPUT;
% 
% OUTPUT:
% 
function [meanAbsErrors, meanSquaredErrors, est_depVars_all, test_depVars_all] = crossValidateDecoding(spikeTrains, depVarByIDs, foldNum, method, option, increment, period, timeLength, thinConditionsBy)

foldSkipNum = 20;

disp(' ')
disp(['starts evaluating ' method])

totalSampleNum = size(spikeTrains,1);

if foldNum == 0
    % this is the case for leave-one-out analysis
    trainRatio = 0;
    foldNum = totalSampleNum;
else
    testRatio = 1 / foldNum;
    trainRatio = 1 - testRatio;
end

maxRadian = pi * period / 180;

meanAbsErrors = zeros(foldNum,1);
meanSquaredErrors = zeros(foldNum,1);

depVarByIDsCellArray = cell(length(depVarByIDs),1);
for depVarCnt = 1:length(depVarByIDs)
    depVarByIDsCellArray{depVarCnt} = num2str(depVarByIDs(depVarCnt));
end
% depVarByIDs= depVarByIDsStr;

condNum_before_thinning = size(unique(depVarByIDsCellArray),1);
% target_depVarByIDs = 1:condNum;

est_depVars_all = zeros(totalSampleNum,1);
test_depVars_all = zeros(totalSampleNum,1);
counter = 1;

permutationInd = [];
unreliableDefaultBetaChannels = [];

%-----
% obtains 
if strcmp(method, 'poissonRegression')   
    [defaultBetaMat, unreliableDefaultBetaChannels] = spikeTrains2defaultBeta(spikeTrains);
    disp(['unreliableDefaultBetaChannels = ' num2str(unreliableDefaultBetaChannels')]);
else
    defaultBetaMat = zeros(5, foldNum);    
end

for foldID = 1:foldNum
    
    if mod(foldID, foldSkipNum) == 1
        % disp(' ');
        disp(['now in foldID = ' num2str(foldID) ' / ' num2str(foldNum)]);
    end
    
    % offset4testPart = testSampleNumInAFold * (foldID - 1);
    offset4testPart = counter - 1;
    
    % separate data to train and test
    % permutationInd = randperm(sampleNum);  % in case test samples are to be sampled randomly. otherwise it is sampled sequentially.
    [train_spikeTrains_before_thinning, train_depVarByIDs_before_thinning, test_spikeTrains, test_depVarByIDs] = divide2trainAndTest4globalSampleID(spikeTrains, depVarByIDs, trainRatio, offset4testPart, permutationInd);
    
    %----
    % thin training data
    % depVarByIDs_domain_before_thinning = 1:condNum_before_thinning;
    % showThinConditionsBy = thinConditionsBy
    depVarByIDs_domain_thinned = 1:thinConditionsBy:condNum_before_thinning;
    % disp(['depVarByIDs_types_thinned = ' num2str(depVarByIDs_domain_thinned)]);
    % disp(['size(train_depVarByIDs_before_thinning,1) = ' num2str(size(train_depVarByIDs_before_thinning,1))]);
    % showTrain_depVarByIDs_before_thinning = train_depVarByIDs_before_thinning    
    trainNum = size(train_depVarByIDs_before_thinning,1);
    trainIndices_thinned_binaryVec = zeros(trainNum,1); 
    for trainID = 1:trainNum
        % showTrain = train_depVarByIDs_before_thinning(trainID)
        % showDepVar =  depVarByIDs_domain_thinned
        trainIndices_thinned_binaryVec(trainID) = ismember(train_depVarByIDs_before_thinning(trainID), depVarByIDs_domain_thinned);
    end
    % disp(['trainIndices_thinned_binaryVec = ' num2str(trainIndices_thinned_binaryVec')]);
    % disp(['sum(trainIndices_thinned_binaryVec) = ' num2str(sum(trainIndices_thinned_binaryVec))]);              
    train_spikeTrains_thinned = train_spikeTrains_before_thinning(trainIndices_thinned_binaryVec == 1);
    train_depVarByIDs_thinned = train_depVarByIDs_before_thinning(trainIndices_thinned_binaryVec == 1);
    % disp(['train_depVarByIDs = ' num2str(train_depVarByIDs')]);
    % disp(['train_depVarByIDs_thinned = ' num2str(train_depVarByIDs_thinned')]);
    % disp(['size(train_depVarByIDs,1) = ' num2str(size(train_depVarByIDs,1))]);
    % disp(['size(train_depVarByIDs_thinned,1) = ' num2str(size(train_depVarByIDs_thinned,1))]);
    
    %----
    % eval popVector
    if strcmp(method, 'popVector')        
        [param, prefDir, ~] = popVectorTrain(train_spikeTrains_thinned, train_depVarByIDs_thinned, condNum_before_thinning, maxRadian);
        neuralDir = popVectorTest(test_spikeTrains, param, prefDir, option.type);
        est_depVars = neuralDir;
    end
    
    %----
    % eval maxLike
    if strcmp(method, 'maxLike')
        [meanFRT, stdFRT, ~] = maxLikeTrain4spikeTrains(train_spikeTrains_thinned, train_depVarByIDs_thinned, depVarByIDs_domain_thinned, condNum_before_thinning);
        est_depVarByIDs = maxLikeTest4spikeTrains(test_spikeTrains, meanFRT, stdFRT, option.distribution);
        est_depVars = (est_depVarByIDs' - 1) * increment;
    end

    %----
    % eval Poisson regression
    if strcmp(method, 'poissonRegression')        
        [betaCell, ~, unreliableChannelsCell] = poissonRegressionTrain(train_spikeTrains_thinned, train_depVarByIDs_thinned, depVarByIDs_domain_thinned, condNum_before_thinning, defaultBetaMat, option.binSize4poissonRegression);        
        %{
        unreliableChannelsAll = [];
        for condID = 1:condNum_before_thinning            
            disp(['unreliableChannels in condID = ' num2str(condID) ' where default beta is used = ' num2str(unreliableChannelsCell{condID}')]);
            unreliableChannelsAll = [unreliableChannelsAll; unreliableChannelsCell{condID}];
        end
        unreliableChannelsAll = unique(unreliableChannelsAll);                    
        disp(['unreliableChannelsAll where default beta is used = ' num2str(unreliableChannelsAll')]);
        disp(['length(unreliableChannelsAll) = ' num2str(length(unreliableChannelsAll))]);        
        %}
        est_depVarByIDs = poissonRegressionTest(test_spikeTrains, betaCell, unreliableChannelsCell, unreliableDefaultBetaChannels, option.binSize4poissonRegression);
        est_depVars = (est_depVarByIDs' - 1) * increment;
        disp(['test_depVarByIDs(1) = ' num2str(test_depVarByIDs(1)) ', est_depVarByIDs(1) = ' num2str(est_depVarByIDs(1))]);
    end
        
    %----
    % eval Poisson regression
    if strcmp(method, 'freeKnot')        
        [modes, ~, unreliableUnits] = freeKnotTrain(train_spikeTrains_thinned, train_depVarByIDs_thinned, depVarByIDs_domain_thinned, condNum_before_thinning, option.binSize4poissonRegression, timeLength);        
        est_depVarByIDs = freeKnotTest(test_spikeTrains, modes, unreliableUnits, option.binSize4poissonRegression, timeLength);
        est_depVars = (est_depVarByIDs' - 1) * increment;
        disp(['test_depVarByIDs(1) = ' num2str(test_depVarByIDs(1)) ', est_depVarByIDs(1) = ' num2str(est_depVarByIDs(1))]);
    end
        
    % create test_y_vec and est_y_vec used in boxplot
    test_depVars = (test_depVarByIDs - 1) * increment;
    testSampleSize = size(test_depVarByIDs,1);
    test_depVars_all(counter:counter + testSampleSize - 1) = test_depVars;
    est_depVars_all(counter:counter + testSampleSize - 1) = est_depVars;
    counter = counter + testSampleSize;
    
    % calculate mean aboslute error and mean squared error
    meanAbsErrors(foldID) = mean(periodicDiff(est_depVars, test_depVars, period));
    meanSquaredErrors(foldID) = mean(power(periodicDiff(est_depVars, test_depVars, period), 2));    

end

end

