% coded by Taro Tezuka since 14.9.20
% calculates kernel mat using mixture kernel on spike trains
% INPUT 
%    spikeTrains: cell array of multichannel spike trains
%    ks: kernel structure by spiketrainlib
%    kernelParams: parameter for ks in spiketrainlib
% OUTPUT
%    kernelTensor: sampleNum x sampleNum x unitNum x unitNum
%
function [kernelTensor] = getKernelTensor(spikeTrains, ks, kernelParams)

%%% disp('starting getKernelTensor');

%------
% note that xs is given as a cell array
sampleNum = size(spikeTrains,1);
sample = spikeTrains{1};
channelNum = size(sample,1);
presentTime = fix(clock);
%%% disp(['in getKernelTensor, sampleNum = ' num2str(sampleNum) ' at ' num2str(presentTime(1,4)) ':' num2str(presentTime(1,5)) ':' num2str(presentTime(1,6))]);

%------
% compute kernel matrix (calculate lower half only, using the symmetry of the kernel matrix)

kernelTensor = zeros(sampleNum, sampleNum, channelNum, channelNum);

indicatorLength = 5;
indicatorDisplayThresh = round(sampleNum * sampleNum / indicatorLength);

samplesSoFar = 0;
%%% disp(['in getKernelTensor, indicatorLength = ' num2str(indicatorLength)])
for sampleID1 = 1:sampleNum    
    for sampleID2 = 1:sampleNum
        samplesSoFar = samplesSoFar + 1;
        if mod(samplesSoFar, indicatorDisplayThresh) == 0
            amountDoneSoFar = samplesSoFar / indicatorDisplayThresh;
            presentTime = fix(clock);
            %%% disp(['in getKernelTensor, ' num2str(amountDoneSoFar) '/' num2str(indicatorLength) ' done at ' num2str(presentTime(1,4)) ':' num2str(presentTime(1,5)) ':' num2str(presentTime(1,6))]);
            % save -v7.3 temp.kernelTensor.mat kernelTensor
        end                
        for channelID1 = 1:channelNum
            for channelID2 = 1:channelID1
                % disp(['sampleID1 = ' num2str(sampleID1)])
                % disp(['sampleID2 = ' num2str(sampleID2)])
                % disp(['channelID1 = ' num2str(channelID1)])
                % disp(['channelID2 = ' num2str(channelID2)])
                % disp(['size(spikeTrains) = ' num2str(size(spikeTrains))])
                % disp(['size(spikeTrains{sampleID1}) = ' num2str(size(spikeTrains{sampleID1}))])
                % disp(['size(spikeTrains{sampleID2}) = ' num2str(size(spikeTrains{sampleID2}))])
                % save temp.mat spikeTrains sampleID1 sampleID2 channelID1 channelID2
                kernelVal = ks.kernel(ks, spikeTrains{sampleID1}{channelID1}, spikeTrains{sampleID2}{channelID2}, kernelParams);  % samples{sampleID1} and samples{sampleID2} should be row vectors.
                kernelTensor(sampleID1, sampleID2, channelID1, channelID2) = kernelVal;                                              
                if channelID1 ~= channelID2
                    kernelTensor(sampleID2, sampleID1, channelID2, channelID1) = kernelVal;
                end
            end
        end        
    end
end

end

