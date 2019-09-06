% Coded by Taro Tezuka since 2014.9.20
% extract channels from multichannel spike trains
% INPUT
%   multivariateSpikeTrains:
%   targetUnits:
% OUTPUT
%   reducedUnitSpikeTrains: 
%
function [reducedUnitSpikeTrains] = extractUnits(multivariateSpikeTrains, targetUnits)

if isempty(targetUnits)

    reducedUnitSpikeTrains = multivariateSpikeTrains;

else
    
    stimTypeNum = size(multivariateSpikeTrains,1);
    reducedUnitSpikeTrains = cell(stimTypeNum,1);

    for stimTypeID = 1:stimTypeNum

        samples = multivariateSpikeTrains{stimTypeID};    
        sampleNum = size(samples,1);
        newSamples = cell(sampleNum,1);

        for sampleID = 1:sampleNum
            sample = samples{sampleID};

            newSamples{sampleID} = sample(targetUnits);

        end

        reducedUnitSpikeTrains{stimTypeID} = newSamples;

    end

end

end

