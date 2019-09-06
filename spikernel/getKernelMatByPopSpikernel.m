% coded by Taro Tezuka since 15.1.14
% calculates kernel matrix using population-rate spikernel.
% INPUT: 
%    spikeTrains: cell array of multichannel spike trains
%    ks: kernel structure by spiketrainlib
%    kernelParams: parameter for ks in spiketrainlib
% OUTPUT:
%    kernelMat: kernel matrix
%
function kernelMat = getKernelMatByPopSpikernel(spikeTrains, ks, kernelParams)

disp(['starting getKernelTensor']);

%------
% note that xs is given as a cell array
sampleNum = size(spikeTrains,1);
presentTime = fix(clock);
disp(['sampleNum = ' num2str(sampleNum) ' at ' num2str(presentTime(1,4)) ':' num2str(presentTime(1,5)) ':' num2str(presentTime(1,6))]);

%------
% compute kernel matrix (calculate lower half only, using the symmetry of the kernel matrix)

kernelMat = zeros(sampleNum, sampleNum);

indicatorLength = 10;
indicatorDisplayThresh = round(sampleNum * sampleNum / (2 * indicatorLength));

samplesSoFar = 0;
for sampleID1 = 1:sampleNum    
    for sampleID2 = 1:sampleID1
        samplesSoFar = samplesSoFar + 1;
        if mod(samplesSoFar, indicatorDisplayThresh) == 0
            amountDoneSoFar = samplesSoFar / indicatorDisplayThresh;
            presentTime = fix(clock);
            disp(['in getKernelTensor, ' num2str(amountDoneSoFar) '/' num2str(indicatorLength) ' done at ' num2str(presentTime(1,4)) ':' num2str(presentTime(1,5)) ':' num2str(presentTime(1,6))]);
            % save -v7.3 temp.kernelTensor kernelTensor
        end
        kernelVal = populationSpikernel(ks, spikeTrains{sampleID1}, spikeTrains{sampleID2}, kernelParams);
        kernelMat(sampleID1, sampleID2) = kernelVal;        
        if sampleID1 ~= sampleID2
            kernelMat(sampleID2, sampleID1) = kernelVal;
        end
        
    end
end

end

