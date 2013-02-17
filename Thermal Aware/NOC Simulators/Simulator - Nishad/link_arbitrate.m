function [ LinkArbitStatus ] = link_arbitrate( iSwitch, jPort, LinkArbitStatus )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% global simulation parameters
global MaxVCNumberOutput; % maximum number of VCs in all ports

% structure of LinkArbitStatus
% 2D array
% 1st dimension denoted by Switch Number
% 2nd dimension denoted by port number
% contains the number of the VC last served


LinkArbitStatus(iSwitch,jPort) = 1 + mod((LinkArbitStatus(iSwitch,jPort)),MaxVCNumberOutput);

end

