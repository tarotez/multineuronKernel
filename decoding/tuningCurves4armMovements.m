% coded by Taro Tezuka since 14.10.18
% obtains tuning curves for CenterOut data described in "MATLAB for Neuroscientists"

function [rates_inst, rates_go] = tuningCurves4armMovements(unit, direction, instruction, go)

stNum = size(unit,2);

offset_before_inst = 0;
offset_after_inst = 1;

offset_before_go = -0.5;
offset_after_go = 0.5;

rates_inst = zeros(stNum,1);
rates_go = zeros(stNum,1);

for stID = 1:stNum

    rates_inst(stID) = ratesByCues(unit(stID).times, direction, instruction, offset_before_inst, offset_after_inst);        
    rates_go(stID) = ratesByCues(unit(stID).times, direction, go, offset_before_go, offset_after_go);
            
end

end

