% by Taro Tezuka since 15.1.5
% finds beta coefficient of Poisson regression with cubic spline for average binned firing rates.
% INPUT:
%   spikeTrains: spike trains for one condition, sampleNum x channelNum
% OUTPUT:
%   defaultBetaMat: coefficient beta for linear predictor obtained by Poisson regression. (covariateNum + 1) * channelNum
% 
function [defaultBetaMat, unreliableDefaultBetaChannels] = spikeTrains2defaultBeta(spikeTrains)

%-----
% sets warnings produced by glmfit as errors, so that it can be catched using try - catch.
s = warning('error', 'stats:glmfit:BadScaling');
warning('error', 'stats:glmfit:IterationLimit');

%-----
% set parameters
% spikeTrainNum4averaging = 10;
covariateNum = 4;   % the number of covariates used in cubic-spline Poisson regression
timeLength = 580;   % 580 ms, according to Olson 2000 and Ventura 2002.
xi1 = - 250;   % \xi_1 = - 250 ms, according to Olson 2000 and Ventura 2002. Since time bin size is 10 ms, - 250 ms / 10 ms = - 25.
xi2 = 200;   % \xi_2 = 200 ms, according to Olson 2000 and Ventura 2002. Since time bin size is 10 ms, 200 ms / 10 ms = 20.
binSize = 10;   % 10 ms, according to Olson 2000 and Ventura 2002.
binNum = ceil(timeLength/binSize);

spikeTrainNum = length(spikeTrains);
channelNum = length(spikeTrains{1});

sampleNum = spikeTrainNum * binNum;
designMat = zeros(sampleNum, covariateNum);   % covariate matrix
spikeCounts = zeros(sampleNum,1);
defaultBetaMat = zeros(covariateNum + 1, channelNum);
previousBeta = zeros(covariateNum + 1, 1);

% spikeTrainSkipBy = floor(spikeTrainNum / spikeTrainNum4averaging);

% disp(['spikeTrainNum = ' num2str(spikeTrainNum) ', spikeTrainSkipBy = ' num2str(spikeTrainSkipBy)]);

unreliableDefaultBetaChannels = [];
for channelID = 1:channelNum
    sampleCnt = 1;
    for spikeTrainID = 1:spikeTrainNum
        % if mod(spikeTrainID, spikeTrainSkipBy) == 0
            for binID = 1:binNum
                t = (binID - (1/2)) * binSize;
                designMat(sampleCnt, 1) = positive(t - xi1);
                designMat(sampleCnt, 2) = power(positive(t - xi1), 2);
                designMat(sampleCnt, 3) = power(positive(t - xi1), 3);
                designMat(sampleCnt, 4) = power(positive(t - xi2), 3);
                binRange = [t - (binSize/2), t + (binSize/2)];
                spikeCounts(sampleCnt) = getSpikeCount(spikeTrains{spikeTrainID}{channelID}, binRange);
                sampleCnt = sampleCnt + 1;
            end
        % end
    end    
    % disp(['size(designMat) = ' num2str(size(designMat))]);        
    % [defaultBeta, dev, stats] = glmfit(designMat, spikeCounts, 'poisson', 'link', 'log');
    % [defaultBeta, dev, stats] = glmfit(designMat, spikeCounts, 'poisson', 'link', 'log');
    % disp(['defaultBeta = ' num2str(defaultBeta')]);
    % disp(['stats.beta = ' num2str(stats.beta')]);
    % defaultBetaMat(:, channelID) = defaultBeta;    
    try
        defaultBeta = glmfit(designMat, spikeCounts, 'poisson', 'link', 'log');    
        previousBeta = defaultBeta;
    catch caught_error
        disp(['*** spikeTrains2defaultBeta, channelID = ' num2str(channelID) ' : warning captured *** : ' caught_error.identifier]);        
        disp(['previousBeta (obtained from the previous channel) used for default beta']);
        defaultBeta = previousBeta;
        unreliableDefaultBetaChannels = [unreliableDefaultBetaChannels; channelID];
    end        
    defaultBetaMat(:, channelID) = defaultBeta;         
end

warning(s);

end