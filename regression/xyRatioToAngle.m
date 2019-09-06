% coded by Taro Tezuka since 15.4.26

function angle = xyRatioToAngle(x, y, period)

origAngle = atan(y/x) * period / (2 * pi);

if x >= 0
    if y >= 0
        angle = origAngle;
    else
        angle = origAngle + period;
    end
else        
    angle = origAngle + (period / 2);
end
    
end

