% Coded by Taro Tezuka since 2014.9.16
% estimates alpha for kernel regression
% kernelVec: vector of kernel values K_{i} = k(x~, x^i) where x~ is a new data
% alpha: coefficient estimated from previous data
%
function est_y  = predictByAlpha(kernelMatForTestData, alpha)

est_y = kernelMatForTestData' * alpha;

end

