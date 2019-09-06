% coded by Taro Tezuka since 14.9.20
% calculates kernel mat using mixture kernel on spike trains
% input:
%    spikeTrains: cell array of multichannel spike trains
%    ks: kernel structure by spiketrainlib
%    kernelParams: parameter for ks in spiketrainlib
%
function [kernelTensor] = getKernelTensorAllComponentsNaive(spikeTrains, ks, kernelParams)

disp(['starting getKernelMat4eachChannel']);

%------
% note that xs is given as a cell array
sampleNum = size(spikeTrains,1);
sample = spikeTrains{1};
componentNum = size(sample,1);
presentTime = fix(clock);
disp(['sampleNum = ' num2str(sampleNum) ' at ' num2str(presentTime(1,4)) ':' num2str(presentTime(1,5)) ':' num2str(presentTime(1,6))]);

%------
% compute kernel matrix (calculate lower half only, using the symmetry of the kernel matrix)

kernelTensor = zeros(sampleNum, sampleNum, componentNum, componentNum);

indicatorLength = 50;
indicatorDisplayThresh = round(sampleNum * sampleNum / indicatorLength);

samplesSoFar = 0;
for sampleID1 = 1:sampleNum
    % for sampleID2 = 1:sampleID1        
    for sampleID2 = 1:sampleNum
        % if mod(samplesSoFar + sampleID2, indicatorDisplayThresh) == 0
        if mod(samplesSoFar, indicatorDisplayThresh) == 0
            amountDoneSoFar = samplesSoFar / indicatorDisplayThresh;
            presentTime = fix(clock);
            disp([num2str(amountDoneSoFar) '/' num2str(indicatorLength) ' done at ' num2str(presentTime(1,4)) ':' num2str(presentTime(1,5)) ':' num2str(presentTime(1,6))]);
        end
        for s = 1:componentNum
            for t = 1:componentNum
                kernelTensor(sampleID1,sampleID2, s, t) = ks.kernel(ks, spikeTrains{sampleID1}{s}, spikeTrains{sampleID2}{t}, kernelParams);  % samples{sampleID1} and samples{sampleID2} should be row vectors.
            end
        end
        samplesSoFar = samplesSoFar + 1;
    end 
end

end
