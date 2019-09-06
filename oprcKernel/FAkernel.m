% Coded by Taro Tezuka since 2016.1.8
% calculates factor analysis kernel for spike trains
% x1, x2 : cell array of spike trains (multichannel spike trains)
% lowRankMat:
% diagonalMat:
% ks : kernel structure, defined in spiketrainlib
% param : parameter for ks
%
function res  = FAkernel(ks, x1, x2, lowRankMat, diagonalMat, param)

%----
% calculate mixture kernel by simple summing with weight matrix
weightMat = lowRankMat * lowRankMat' + diagonalMat;

componentNum = size(weightMat,1);
res = 0;
for s = 1:componentNum
    for t = 1:componentNum        
        res = res + (weightMat(s,t) * ks.kernel(ks, x1{s}, x2{t}, param));
    end
end

end


