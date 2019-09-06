% coded by Taro Tezuka since 14.10.18
% for project 17.4 in page 294 of "MATLAB for Neuroscientists" (2nd edition)
% obtains rate for arm movement task data collected at the Hatsopoulos lab
% 
function rate = getRate(spikeTrain, startTime, endTime )

rate = size(spikeTrain(spikeTrain > startTime & spikeTrain < endTime), 1) / (endTime - startTime);

end

