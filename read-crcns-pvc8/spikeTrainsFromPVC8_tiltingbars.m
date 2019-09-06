function [multivariateSpikeTrains, timeLength] = spikeTrainsFromPVC8_tiltingbars(animalID)

targetImgs = 672:4:732;

[multivariateSpikeTrains, timeLength] = spikeTrainsFromPVC8(animalID, targetImgs);

end

