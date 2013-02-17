function [ OutputArbitStatus ] = output_arbitrate( iSwitch, jPort, OutputArbitStatus )
% This function arbitrates between input port for an output port
%   Round-Robin

% global simulation parameters
% structure of PortNumber
% 1D array
% 1st dimension denoted by switch number
% contains the nuymber of ports for a particular switch, formed depending
% upon topology, can be globally defined
global PortNumber;


OutputArbitStatus(iSwitch, jPort) = 1 + mod((OutputArbitStatus(iSwitch,jPort)),PortNumber(iSwitch));
if(OutputArbitStatus(iSwitch, jPort) == jPort)
   OutputArbitStatus(iSwitch, jPort) = 1 + mod((OutputArbitStatus(iSwitch,jPort)),PortNumber(iSwitch));
end

end

