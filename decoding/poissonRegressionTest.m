% coded by Taro Tezuka since 15.1.3
% run Poisson regression (GLM, generalized linear model) with cubic spline
% Olson, Gettner, Ventura, Carta, Kass (2000) Neuronal activity in macaque supplementary eye field during planning of saccades in response to pttern and spatial cues.
% DiMatteo, Genovese, and Kass (2000), Bayesian curve-fitting with free-knot splines.
% Kass and Ventura (2001) A spike-train probability model.
% Ventura, Carta, Kass, Gettner, Olson (2002) Statistical analysis of temporal evolution in single neuron firing rates.
% Jacobs, Fridman, Douglas, Alam, Latham, Prusky, Nirenberg (2009) Ruling out and ruling in neural codes.
% INPUT:
%   test_spikeTrains: spike trains in trialID -> channelID
%   betaCell: cell array of beta coefficients for Poisson regression with cubic spline. condNum x channelNum.
%   unreliableUnits: cell array of channels that uses default beta because of computational warning during glmfit. dimension of condNum.
% OUTPUT:
%   est_depVarByIDs: estimated dependent variable IDs
%   logLikelihoodMat: matrix of log likelihood. testSampleNum x condNum
%
function [est_depVarByIDs, logLikelihoodMat] = poissonRegressionTest(test_spikeTrains, betaCell, unreliableUnitsCell, unreliableDefaultBetaUnits, binSize4poisson)

timeLength = 580;   % 580 ms, according to Olson 2000 and Ventura 2002.
xi1 = - 250;   % \xi_1 = - 250 ms, according to Olson 2000 and Ventura 2002. Since time bin size is 10 ms, - 250 ms / 10 ms = - 25.
xi2 = 200;   % \xi_2 = 200 ms, according to Olson 2000 and Ventura 2002. Since time bin size is 10 ms, 200 ms / 10 ms = 20.
% dt = 0.1;   % bin size for calculating likelihood
dt = 1;   % bin size for calculating likelihood
binNum4integration = timeLength / dt;

[condNum, unitNum] = size(betaCell);
testSampleNum = size(test_spikeTrains,1);

est_depVarByIDs = zeros(testSampleNum,1);   % estimated dependent variable IDs
logLikelihoodMat = zeros(testSampleNum,condNum);

%----
% run for each test sample in testSpikeTrains array
for testSampleID = 1:testSampleNum
    multiChannelSpikeTrain = test_spikeTrains{testSampleID};    
    %----
    % calculate p(r|s) for each stimulus (condition) s, where r is the response
    
    for condID = 1:condNum
        logLikelihood = 0;
        for unitID = 1:unitNum
            if ~ismember(unitID, unreliableDefaultBetaUnits)
                spikeTrain = multiChannelSpikeTrain{unitID};
                beta = betaCell{condID,unitID};
                % disp(['channelID = ' num2str(channelID) ', spikeTrain = ' num2str(spikeTrain')]);                
                
                %{
                for spikeID = 1:length(spikeTrain)
                    logLikelihood = logLikelihood + (cubicSpline4logExpectation(spikeTrain(spikeID), beta, xi1, xi2) / binSize * dt);
                end
                logLikelihood = logLikelihood - integrateIntensity(timeLength, beta, xi1, xi2, binSize4poisson);
                %}
                
                % code below follows that described in the supplementary material (SI Appendix A.) of Jacobs.
                binsWithSpike = floor(spikeTrain / dt);
                % disp(['spikeTrain = ' num2str(spikeTrain')]);
                % disp(['spikeTrainFloored = ' num2str(spikeTrainFloored')]);
                for binID4integration = 1:binNum4integration
                    t = (binID4integration - 1) * dt;
                    log_expectation = cubicSpline4logExpectation(t, beta, xi1, xi2);                    
                    % firingProbability is the probability of a spike occurring in a time bin [t, t+dt]. 
                    % This is the parameter of Bernouill distribution Be(\mu) which approximates Poisson(\lambda) when \lambda is small.
                    % In this case, \mu can be approximated by \lambda.
                    % log_expectation is the log of the expected number of spikes in a bin of size binSize.
                    firingProbability = (exp(log_expectation) / binSize4poisson) * dt;
                    
                    if ismember(binID4integration, binsWithSpike)
                        % disp([num2str(t) ' is member, so adding ' num2str(log_intensity * dt)])
                        logLikelihood = logLikelihood + log(firingProbability);   % no need to multiply dt, because that is common for all conditions
                    else
                        % disp([num2str(t) ' is not a member, so adding ' num2str(log(1 - exp(log_intensity * dt)))]);
                        logLikelihood = logLikelihood + log(1 - firingProbability);   % no need to multiply dt, because that is common for all conditions
                    end
                end                
                
            end
                     
        end     
        logLikelihoodMat(testSampleID,condID) = logLikelihood;
    end
    
    disp(['logLikelihoodMat = ' num2str(logLikelihoodMat(testSampleID,:))]);
    
    %maximimze the log-likelihood
    [~, est_depVarByIDs(testSampleID)] = max(logLikelihoodMat(testSampleID,:));
    
end

end