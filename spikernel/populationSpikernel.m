% by Taro Tezuka since 15.1.14
% calculates spikernel using population rate
% INPUT:
%   ks : kernel structure, defined in spiketrainlib
%   multivariateSpikeTrain1: multivariate spike train 1
%   multivariateSpikeTrain2: multivariate spike train 2
%   kernelParams : parameter for ks
% OUTPUT:
%   val: value of the kernel
% 
function val  = populationSpikernel(ks, multivariateSpikeTrain1, multivariateSpikeTrain2, kernelParams)

%----
% calculate mixture kernel by simple summing with weight matrix

unitNum1 = length(multivariateSpikeTrain1);

overlayedSpikeTrain1 = [];
overlayedSpikeTrain2 = [];
for s = 1:unitNum1    
    if length(multivariateSpikeTrain1) > 0
        % disp(['size(overlayedSpikeTrain1) = ' num2str(size(overlayedSpikeTrain1)) ', size(mst1) = ' num2str(size(multivariateSpikeTrain1{s}))]);    
        overlayedSpikeTrain1 = [overlayedSpikeTrain1; multivariateSpikeTrain1{s}];    
    end
    if length(multivariateSpikeTrain2) > 0
        % disp(['size(overlayedSpikeTrain2) = ' num2str(size(overlayedSpikeTrain2)) ', size(mst2) = ' num2str(size(multivariateSpikeTrain2{s}))]);
        overlayedSpikeTrain2 = [overlayedSpikeTrain2; multivariateSpikeTrain2{s}];
    end    
end
overlayedSpikeTrain1 = sort(overlayedSpikeTrain1);
overlayedSpikeTrain2 = sort(overlayedSpikeTrain2);

val = ks.kernel(ks, overlayedSpikeTrain1, overlayedSpikeTrain2, kernelParams);

end

