% by Taro Tezuka since 15.1.3
% function that takes only the positive part, i.e. (-)_{+}. If arg < 0, then val = 0.
% 
function val = positive(arg)

val = (abs(arg) + arg) / 2;

end

