function [ PortArbitStatus ] = port_arbitrate( iSwitch, PortArbitStatus )

% global simulation parameters
% structure of PortNumber
% 1D array
% 1st dimension denoted by switch number
% contains the nuymber of ports for a particular switch, formed depending
% upon topology, can be globally defined
global PortNumber;


PortArbitStatus(iSwitch) = 1 + mod(PortArbitStatus(iSwitch),PortNumber(iSwitch));

end
