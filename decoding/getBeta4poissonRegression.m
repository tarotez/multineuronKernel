% by Taro Tezuka since 15.1.2
% run Poisson regression with cubic spline, based on following papers.
% Olson, Gettner, Ventura, Carta, Kass (2000) Neuronal activity in macaque supplementary eye field during planning of saccades in response to pttern and spatial cues.
% DiMatteo, Genovese, and Kass (2000), Bayesian curve-fitting with free-knot splines.
% Kass and Ventura (2001) A spike-train probability model.
% Ventura, Carta, Kass, Gettner, Olson (2002) Statistical analysis of temporal evolution in single neuron firing rates.
% Jacobs, Fridman, Douglas, Alam, Latham, Prusky, Nirenberg (2009) Ruling out and ruling in neural codes.
% INPUT:
%   spikeTrains: spike trains for one condition, sampleNum x channelNum
%   targetChannel: target channel for multivariate spike trains
%   defaultBeta: use this as beta if glmfit returns a warning. a column vector whose dimension is (covariateNum + 1).
% OUTPUT:
%   beta: coefficient beta for linear predictor obtained by Poisson regression. a column vector whose dimension is (covariateNum + 1).
%   totalSpikeNum: total spike num

function [beta, spikeCounts, unreliableChannels] = getBeta4poissonRegression(spikeTrains4oneCondition, targetChannel, unreliableChannels, defaultBeta, binSize)

%-----
% sets warnings produced by glmfit as errors, so that it can be catched using try - catch.
s = warning('error', 'stats:glmfit:BadScaling');
warning('error', 'stats:glmfit:IterationLimit');

%-----
% set parameters
covariateNum = 4;   % the number of covariates used in cubic-spline Poisson regression
%%% timeLength = 580;   % 580 ms, according to Olson 2000. This was because the length of recordings varied between 580 and 600
timeLength = 600;   % 600 ms, in case all recordings are longer than 600 ms.
xi1 = - 250;   % \xi_1 = - 250 ms, according to Olson 2000 and Ventura 2002. Since time bin size is 10 ms, - 250 ms / 10 ms = - 25.
xi2 = 200;   % \xi_2 = 200 ms, according to Olson 2000 and Ventura 2002. Since time bin size is 10 ms, 200 ms / 10 ms = 20.

binNum = ceil(timeLength/binSize);
[trialNum, ~] = size(spikeTrains4oneCondition);
sampleNum = trialNum * binNum;
designMat = zeros(sampleNum, covariateNum);   % covariate matrix
spikeCounts = zeros(sampleNum,1);

sampleCnt = 1;
for trialID = 1:trialNum    
    for binID = 1:binNum
        t = (binID - (1/2)) * binSize;
        designMat(sampleCnt, 1) = positive(t - xi1);
        designMat(sampleCnt, 2) = power(positive(t - xi1), 2);
        designMat(sampleCnt, 3) = power(positive(t - xi1), 3);
        designMat(sampleCnt, 4) = power(positive(t - xi2), 3);
        binRange = [t - (binSize/2), t + (binSize/2)];
        spikeCounts(sampleCnt) = getSpikeCount(spikeTrains4oneCondition{trialID}{targetChannel}, binRange);
        sampleCnt = sampleCnt + 1;
    end
end

% disp(['in getBeta4poissonRegression, spikeCounts = ' num2str(spikeCounts')]);

try
    beta = glmfit(designMat, spikeCounts, 'poisson', 'link', 'log');
catch caught_error
   % disp(['in getBeta4poissonRegression, targetChannel = ' num2str(targetChannel) ', sum(spikeCounts) = ' num2str(sum(spikeCounts))]);
   % disp(['*** in getBeta4poissonRegression, targetChannel = ' num2str(targetChannel) ' : warning captured *** : ' caught_error.identifier]);
   % disp(['so using default beta']);
   % beta = zeros(covariateNum + 1, 1);
   beta = defaultBeta;   
   unreliableChannels = [unreliableChannels; targetChannel];
end

warning(s);

end
