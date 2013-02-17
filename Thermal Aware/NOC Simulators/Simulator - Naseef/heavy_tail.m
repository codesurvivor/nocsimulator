function [ time ] = heavy_tail( )
% This function generates the power tail following Pareto Distribution
%   for Self-Similar On-time
alpha = 1.25;
xm = 1;
rnum = rand;
while(rnum == 0)
    rnum = rand;
end
time = floor(xm/(rnum^(1/alpha)));

end

