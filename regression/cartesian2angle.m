% coded by Taro Tezuka since 14.10.25
% converts cartesian coordinate (h,v) to angle t

function [t] = cartesian2angle(h, v, period)

t = atan(v ./ h) * period / (2 * pi);

for i = 1:length(v)
    if h(i) < 0
       t(i) = t(i) + (period / 2); 
    end
    if h(i) >= 0 && v(i) < 0
        t(i) = t(i) + period; 
    end
end

end
