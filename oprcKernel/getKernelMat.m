% coded by Taro Tezuka since 14.9.19
% calculates kernel mat using mixture kernel on spike trains
%   xs: cell array of multichannel spike trains
%   ks: kernel structure by spiketrainlib
%   weightMat: weight matrix for the mixture kernel
%   kernelParams: parameter for ks in spiketrainlib
%
function [kernelMat] = getKernelMat(xs, ks, weightMat, kernelParams)

disp(['starting getKernelMat']);

%------
% note that xs is given as a cell array
sampleNum = size(xs,1);
presentTime = fix(clock);
disp(['sampleNum = ' num2str(sampleNum) ' at ' num2str(presentTime(1,4)) ':' num2str(presentTime(1,5)) ':' num2str(presentTime(1,6))]);

%------
% compute kernel matrix (calculate lower half only, using the symmetry of the kernel matrix)

kernelMat = zeros(sampleNum, sampleNum);

indicatorLength = 50;
indicatorDisplayThresh = round(sampleNum * (sampleNum - 1) / (2 * indicatorLength));

samplesSoFar = 0;
disp(['in getKernelMat, indicatorLength = ' num2str(indicatorLength)])
for sampleID1 = 1:sampleNum
    for sampleID2 = 1:sampleID1        
        if mod(samplesSoFar + sampleID2, indicatorDisplayThresh) == 0
            amountDoneSoFar = (samplesSoFar + sampleID2) / indicatorDisplayThresh;
            presentTime = fix(clock);
            disp([num2str(amountDoneSoFar) '/' num2str(indicatorLength) ' done at ' num2str(presentTime(1,4)) ':' num2str(presentTime(1,5)) ':' num2str(presentTime(1,6))]);
            % save tempKernelMat.mat kernelMat
        end        
        kernelMat(sampleID1,sampleID2) = mixtureKernel(ks, xs{sampleID1}, xs{sampleID2}, weightMat, kernelParams);  % samples{sampleID1} and samples{sampleID2} should be row vectors.
    end 
    samplesSoFar = samplesSoFar + sampleID1;
end

kernelMat = (kernelMat + kernelMat') - diag(diag(kernelMat));   % make it a symmetric matrix

end
