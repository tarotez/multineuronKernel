% coded by Taro Tezuka since 14.12.29
% run Poisson regression (GLM, generalized linear model) with cubic spline
% Olson, Gettner, Ventura, Carta, Kass (2000) Neuronal activity in macaque supplementary eye field during planning of saccades in response to pttern and spatial cues.
% DiMatteo, Genovese, and Kass (2000), Bayesian curve-fitting with free-knot splines.
% Kass and Ventura (2001) A spike-train probability model.
% Ventura, Carta, Kass, Gettner, Olson (2002) Statistical analysis of temporal evolution in single neuron firing rates.
% Jacobs, Fridman, Douglas, Alam, Latham, Prusky, Nirenberg (2009) Ruling out and ruling in neural codes.
% 
% INPUT: 
%   train_spikeTrains: spike trains in trialID -> unitID
%   train_depVarByIDs: IDs of dependent variable y, as a sequence corresponding to elements of spikeTrains
%   depVarByIDs_domain_before_thinning: set of IDs appearing in depVarByIDs
%   defaultBetaMat: use this as beta if glmfit returns a warning. covariateNum * channelNum
% OUTPUT:
%   betaCell: cell array of beta coefficients for Poisson regression with cubic spline. condNum * channelNum.
%   spikeTrainsByCond: spike trains cell array. condID -> trialID -> channelID.
%   unreliableUnits: cell array of channels that uses default beta because of computational warning during glmfit. dimension of condNum.

function [betaCell, spikeTrainsByCond, unreliableUnitsCell] = poissonRegressionTrain(train_spikeTrains, train_depVarByIDs, depVarByIDs_domain_thinned, condNum_before_thinning, defaultBetaMat, binSize)

trialNum = length(train_depVarByIDs);
unitNum = length(train_spikeTrains{1});
betaCell = cell(condNum_before_thinning, unitNum);    % for beta coefficients obtained as a result of Poisson regression
covariateNum = 4;   % number of covariate num for Poisson regression  (dimension of beta coefficient vector)

spikeTrainsByCond = cell(condNum_before_thinning,1);
dataCounts = zeros(condNum_before_thinning,1);
for trialID = 1:trialNum
    condID = train_depVarByIDs(trialID);
    if dataCounts(condID) == 0
        spikeTrainsByCond{condID} = cell(1,1);
        spikeTrainsByCond{condID}{1} = train_spikeTrains{trialID};
    else
        spikeTrainsByCond{condID}{dataCounts(condID),1} = train_spikeTrains{trialID};
    end
    dataCounts(condID) = dataCounts(condID) + 1;
end

% disp(['dataCounts = ' num2str(dataCounts')])

unreliableUnitsCell = cell(condNum_before_thinning);
for condID = 1:condNum_before_thinning
    if ismember(condID, depVarByIDs_domain_thinned)
        for unitID = 1:unitNum            
            [betaCell{condID,unitID}, spikeCounts, unreliableUnitsCell{condID}] = getBeta4poissonRegression(spikeTrainsByCond{condID}, unitID, unreliableUnitsCell{condID}, defaultBetaMat(:, unitID), binSize);            
            % disp(['in poissonRegressionTrain, for condID = ' num2str(condID) ', channelID = ' num2str(channelID) ', beta = ' num2str(betaCell{condID,channelID}')]);
        end
    else
        for unitID = 1:unitNum
            betaCell{condID,unitID} = zeros(covariateNum + 1, 1);            
        end
    end
end

end
