% Coded by Taro Tezuka since 2014.9.17
% calculates mixture kernel
% x, y : cell array of spike trains (multichannel spike trains)
% ks : kernel structure, defined in spiketrainlib
% param : parameter for ks
%
function res  = mixtureKernel(ks, x1, x2, weightMat, param)

%----
% calculate mixture kernel by simple summing with weight matrix

componentNum = size(weightMat,1);
res = 0;
for s = 1:componentNum
    for t = 1:componentNum        
        res = res + (weightMat(s,t) * ks.kernel(ks, x1{s}, x2{t}, param));
    end
end

end

