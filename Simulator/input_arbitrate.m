function [ InputArbitStatus ] = input_arbitrate( iSwitch, jPort, InputArbitStatus )
% This function arbitrates between VCs in the input port
%   Round-Robin arbitration is used: simple

% global simulation parameters
global MaxNumberOfVC; % maximum number of VCs in all ports

InputArbitStatus(iSwitch,jPort) = 1 + mod((InputArbitStatus(iSwitch,jPort)),MaxNumberOfVC);

end

