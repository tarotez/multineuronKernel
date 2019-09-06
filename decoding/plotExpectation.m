% by Taro Tezuka since 15.1.2
% plot the result of Poisson regression with cubic spline, based on following papers.
% Olson, Gettner, Ventura, Carta, Kass (2000) Neuronal activity in macaque supplementary eye field during planning of saccades in response to pttern and spatial cues.
% DiMatteo, Genovese, and Kass (2000), Bayesian curve-fitting with free-knot splines.
% Kass and Ventura (2001) A spike-train probability model.
% Ventura, Carta, Kass, Gettner, Olson (2002) Statistical analysis of temporal evolution in single neuron firing rates.
% Jacobs, Fridman, Douglas, Alam, Latham, Prusky, Nirenberg (2009) Ruling out and ruling in neural codes.
% 
% INPUT:
%   beta: coefficient vector beta for Poisson regression with cubic spline.
%   binSize: 10 ms according to Olson 2000.
% OUTPUT:
%   expectation: \pi(t) which is a vector of parameters of Poisson distribution for the number of spikes of a bin with size binSize = 10 at time t.
% 
function expectation = plotExpectation(beta, binSize)

timeLength = 580;   % 580 ms, according to Olson 2000 and Ventura 2002.
xi1 = - 250;   % \xi_1 = - 250 ms, according to Olson 2000 and Ventura 2002. Since time bin size is 10 ms, - 250 ms / 10 ms = - 25.
xi2 = 200;   % \xi_2 = 200 ms, according to Olson 2000 and Ventura 2002. Since time bin size is 10 ms, 200 ms / 10 ms = 20.

binNum = ceil(timeLength/binSize);
expectation = zeros(binNum, 1);
for binID = 1:binNum
    t = (binID - (1/2)) * binSize;
    expectation(binID) = exp(cubicSpline4logExpectation(t, beta, xi1, xi2));
end

end
