function [ time ] = exp_tail( )
%This function generates Off-time following an exponential distribution
%   used in self-similar and Poisson distribution
lambda = 1.8;
rnum = rand;
while(rnum == 0)
    rnum = rand;
end
time = 1+ round((-log(rnum))/lambda);
end
% 
% alpha = 1.25;
% xm = 1;
% rnum = rand;
% while(rnum == 0)
%     rnum = rand;
% end
% time = floor(xm/(rnum^(1/alpha)));
% end