% coded by Taro Tezuka since 14.10.12
% runs kernel ridge regression on multichannel spike trains of CRCNS PVC3

%----
% read data and set parameters
[multiChannelSubtrains, subtrainsArray, stimIntervalTimes, spikesBeforeAnyStimArray, spikeFileNames] = readMultiChannelByStimulus();
targetChannels = [];
% targetChannels = [2,3,6,7,10];
reducedChannelsSubtrains = extractChannels(multiChannelSubtrains,targetChannels);
segmentLength = (10^6);  % use 1s starting from the stimulus onset
segmentNum = 4;  % because stimulus was presented for 4 seconds, there are 4 segments of 1s each.
% segmentLength = 500000;  % use 500ms starting from the stimulus onset
% segmentNum = 8;  % because stimulus was presented for 4 seconds, there are 8 segments of 500ms each.
shorterSubtrains  = divideByTimeLength(reducedChannelsSubtrains, segmentLength, segmentNum);
slimSubtrains = removeEmptySamples(shorterSubtrains);
stimTypes = [0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 300, 320, 340]';
[spikeTrains, stimIDs] = condIDbyTrialID2globalSampleID(slimSubtrains);
[spikeTrains, stimIDs, randIndices] = randomizeOrder(spikeTrains, stimIDs);
startTime = 0;
% [xs] = reduceTimeLength(xs, startTime, reducedTimeLength);
kernelType = 'mci';
kernelSpecification = '';
% kernelType = 'nci1';
% kernelSpecification = 'laplacian';
% timeLengthBetwStimuli = 5 * 10^6;   % 5s between stimulus presentation
ks = kernelFactory(kernelType, segmentLength, kernelSpecification);
% ksize = [5000, 1];
% ksize = [10000, 1];
ksize = [128000, 1];   % optimal due to optimizeKernelParams.m
totalKernelTensor = getKernelTensor(spikeTrains, ks, ksize);
y = indices2valuesByCellArray(stimTypes, stimIDs);
y = convertStimType(y);
foldNum = 0; % for leave-one-out analysis, set to 0
regLambda = 1024;
offDiagQuantization = 2;
[errorsByOffDiag, offDiagComponents] = optimizeCoeffMatByCrossValidation(totalKernelTensor, y, foldNum, regLambda, offDiagQuantization);
figure(1)
plot(errorsByOffDiag)

%----
% visualize average error
figure(2)
plot(mean(errorsByOffDiag,2)')
xlabel('off diagonal entry', 'FontName','Times','FontSize', 24);
ylabel('average error', 'FontName','Times','FontSize', 24);
xlabels = [offDiagComponents (1 + ((0.1 / 8) * (1:8)))];
lNum = size(xlabels,2);
set(gca, 'XTickLabel', xlabels(1:16:lNum), 'XTick', 1:4:lNum, 'FontName', 'Times', 'FontSize', 16)
xlim([0 24])
[mv,ind] = min(mean(errorsByOffDiag,2)')
offDiagComponents(ind)p

%----
% find the best regularization parameter by minimizing test error
componentNum = size(totalKernelTensor,3);
diagComponent = 1;
offDiagComponent = 0;
weightMat = ((diagComponent - offDiagComponent) * eye(componentNum)) + (offDiagComponent * ones(componentNum));
regLambdas = power(2,-5:15);
% regLambdas = 0:0.01:1;
[totalKernelMat] = kernelTensor2mixtureKernelMat(totalKernelTensor, weightMat);
[scores, errorsByRegLambdas] = optimizeRegularization(totalKernelMat, y, regLambdas);
figure(3)
plot(errorsByRegLambdas)
num2str(errorsByRegLambdas')
[mv,ind] = min(errorsByRegLambdas)
regLambdas(ind)
xlim([0 size(regLambdas,2)]);
xlabel('regularization parameter', 'FontName','Times','FontSize', 24);
ylabel('average error', 'FontName','Times','FontSize', 24);
xlabels = regLambdas;
set(gca, 'XTickLabel', xlabels(1:4:numel(xlabels)), 'XTick', 1:4:numel(xlabels), 'FontName', 'Times', 'FontSize', 16)

%----
% visualize using scatter plot (fix holdout and plot scatter)
sampleNum = size(totalKernelTensor,1);
testIndices = 1:50;  % static holdout
trainIndices = [51:sampleNum];
regLambda = 512;
offDiagComponent = 0;
figure(9)
scatterSingleFold(totalKernelTensor, y, trainIndices, testIndices, regLambda, offDiagComponent);
xlim([0 160]);
ylim([0 max(est_y)]);
xlabel('correct orientation', 'FontName','Times','FontSize', 24);
ylabel('estimated orientation', 'FontName','Times','FontSize', 24);
set(gca, 'FontName', 'Times', 'FontSize', 24);

%----
% visualize using boxplot (find error for each holdout of size 1 using leave-one-out anaysis, and then visualize mean and variance)
figure(5)
est_ys = leaveOneOut4eachStim(totalKernelTensor, y, regLambda, offDiagComponent);
boxplot(est_ys');
xlabel('correct orientation', 'FontName','Times','FontSize', 24);
ylabel('estimated orientation', 'FontName','Times','FontSize', 24);
xlabels = (0:8) * 20;
set(gca, 'XTickLabel', xlabels(1:2:numel(xlabels)), 'XTick', 1:2:numel(xlabels), 'FontName', 'Times', 'FontSize', 16)
