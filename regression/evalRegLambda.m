% coded by Taro Tezuka since 14.9.19
% test various values of regularization parameter lambda
% 
function [squaredErrors, lambdas] = evalRegLambda(kernelMat, train_spikeTrains, test_spikeTrains, train_depVar, test_depVar, period)

polyDim = 1;
tradeOff = 0;
timeLengthBetwStimuli = 5000;

kernelType = 'wmci';
ks = kernelFactory(kernelType, timeLengthBetwStimuli, 'quadratic');   % param1 for wmci is a window type
ksize = 2000;
componentNum = size(train_spikeTrains{1},1);
weightMat = (0.5 * eye(componentNum)) + (0.5 * ones(componentNum));

lambdas = power(2, 40:50);

lambdaNum = length(lambdas);

squaredErrors = zeros(lambdaNum,1);

for lambdaID = 1:lambdaNum
        
    regLambda = lambdas(lambdaID);
    
    disp(['now at regLambda = ' num2str(regLambda)]);
    alpha = kernelRegression(kernelMat, train_depVar, regLambda);
    kernelMatForTestData = getKernelMatBetwTrainAndTest(train_spikeTrains, test_spikeTrains, ks, weightMat, ksize, polyDim, tradeOff);
    est_y = predictByAlpha(kernelMatForTestData, alpha);
    
    squaredErrors(lambdaID) = norm(periodicDiff(test_depVar, est_y, period), 2);

end

save res.evalRegLambda.mat squaredErrors lambdas

end

