% by Taro Tezuka since 15.1.3
% calculates the value of expectation of the number of spikes in a bin using Poisson regression with cubic spline.
% Olson, Gettner, Ventura, Carta, Kass (2000) Neuronal activity in macaque supplementary eye field during planning of saccades in response to pttern and spatial cues.
% DiMatteo, Genovese, and Kass (2000), Bayesian curve-fitting with free-knot splines.
% Kass and Ventura (2001) A spike-train probability model.
% Ventura, Carta, Kass, Gettner, Olson (2002) Statistical analysis of temporal evolution in single neuron firing rates.
% Jacobs, Fridman, Douglas, Alam, Latham, Prusky, Nirenberg (2009) Ruling out and ruling in neural codes.
% INPUT:
%   t: time point
%   beta: beta coefficient for cubic spline
%   xi1: time constant 1
%   xi2: time constant 2
% OUTPUT:
%   log_expectation: log expectation log(E[y]) = log(\mu) = \eta = x\beta

function [log_expectation] = cubicSpline4logExpectation(t, beta, xi1, xi2)
    
    log_expectation = beta(1) + (beta(2) * positive(t - xi1)) + (beta(3) * power(positive(t - xi1), 2)) + (beta(4) * power(positive(t - xi1), 3)) + (beta(5) * power(positive(t - xi2), 3));
    
end

