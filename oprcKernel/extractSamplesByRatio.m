
function [extractedMultiSpikeTrainsBySampleID, otherMultiSpikeTrainsBySampleID, extractedSampleIDs, otherSampleIDs] = extractSamplesByRatio(multiSpikeTrainsBySampleID, ratio)

sampleNum = length(multiSpikeTrainsBySampleID);
randvec = randperm(sampleNum);
extractedSampleIDs = randvec(1:ceil(sampleNum * ratio));
extractedMultiSpikeTrainsBySampleID = multiSpikeTrainsBySampleID(extractedSampleIDs);
otherSampleIDs = 1:sampleNum;
otherSampleIDs(extractedSampleIDs) = [];
otherMultiSpikeTrainsBySampleID = multiSpikeTrainsBySampleID(otherSampleIDs);

end
