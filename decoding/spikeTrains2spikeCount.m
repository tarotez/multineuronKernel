% coded by Taro Tezuka since 14.10.21
% counts average number of spikes for each (channelID, condID)
% input:
%   spikeTrains: spike trains, organized by globalSampleID -> channelID
%   depVarByIDs: value of correct labels (condition) by globalSampleID
% output:
%   spikeCountCell: average number of spikes for each (channelID, condID)
%   channelNum: number of samples for each (channelID, condID)

function [spikeCountCell, channelNum] = spikeTrains2spikeCount(spikeTrains, depVarByIDs, condNum)

totalSampleNum = size(spikeTrains,1);
channelNum = size(spikeTrains{1},1);

spikeCountCell = cell(condNum, channelNum);

for sampleID=1:totalSampleNum
    for channelID = 1:channelNum
        % disp(['sampleID = ' num2str(sampleID) ', depVarByID = ' num2str(depVarByIDs(sampleID)) ', channelID = ' num2str(channelID)]);
        % disp(['size(spikeCountCell) = ' num2str(size(spikeCountCell))]);
        if isempty(spikeCountCell{depVarByIDs(sampleID), channelID})
            spikeCountCell{depVarByIDs(sampleID), channelID} = size(spikeTrains{sampleID}{channelID},1);
        else
            spikeCountCell{depVarByIDs(sampleID), channelID} = [spikeCountCell{depVarByIDs(sampleID), channelID}; size(spikeTrains{sampleID}{channelID},1)];
        end
        %{
        % show a part of results
        if sampleID < 50;
            spikeCountVec = spikeCountCell{depVarByIDvec(sampleID), channelID};
            disp(['condID = ' num2str(depVarByIDvec(sampleID)) ', channelID = ' num2str(channelID) ', spikeCountVec = ' num2str(spikeCountVec')]);
        end
        %}
    end
end

end

