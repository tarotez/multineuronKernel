% by Taro Tezuka since 15.1.3
% integrates intensity function.
% unit is in ms
% INPUT:
%   timeLength: time length (in miliseconds)
%   beta: beta coefficient for cubic spline
%   xi1: time constant 1
%   xi2: time constant 2
% OUTPUT:
%   integral: integrated intensity (unit in milliseconds, i.e. firing rate for time length [0,T] measured in milliseconds)

function [integral] = integrateIntensity(timeLength, beta, xi1, xi2, binSize)

dt = 1;   % 1ms
binNum4integration = timeLength / dt;   % T is in ms

integral = 0;
for binID4integration = 1:binNum4integration
    t = (binID4integration - 1) * dt;
    % log_expectation is the log of the expected number of spikes in a bin of size binSize.    
    % This is the parameter of Bernouill distribution Be(\mu) which approximates Poisson(\lambda) when \lambda is small.                    
    log_expectation = cubicSpline4logExpectation(t, beta, xi1, xi2);                           
    % intensity \nu(t) is obtained by dividing the parameter \pi of Poisson distribution by binSize, multiplying dt and letting it go close to 0.
    integral = integral + (exp(log_expectation) / binSize) * dt;
        
end

end

