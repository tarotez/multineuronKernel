function [multivariateSpikeTrains, timeLength] = spikeTrainsFromPVC8_thinstripes(animalID)

targetImgs = [653,657,661,665];

[multivariateSpikeTrains, timeLength] = spikeTrainsFromPVC8(animalID, targetImgs);

end

