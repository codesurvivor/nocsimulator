function [ CoreStatus ] = determine_onofftime( SimCycle, CoreNumber, CoreStatus )
% This function determines whether to place a particular core in On or Off State
%   Self Similar temporal Injection Pattern

% Data Structure indices of CoreStatus (values: 1,2,3,4)
% 2D array
% row denoted by CoreNumber
global CycleOfLastCompletedTime; % value = 1
global OnOrOff; % value = 2
global DurationOfNextTime; % value = 3
% global CurrentMsgNumber; % value = 4

% if((CoreStatus(CoreNumber,CycleOfLastCompletedTime) + CoreStatus(CoreNumber,DurationOfNextTime)) == (SimCycle-1))
%     if(CoreStatus(CoreNumber,OnOrOff) == 0)
%         time = heavy_tail(); % On-time with Pareto distribution
%         CoreStatus(CoreNumber,OnOrOff) = 1;
%         CoreStatus(CoreNumber,CycleOfLastCompletedTime) = SimCycle-1;
%         CoreStatus(CoreNumber,DurationOfNextTime) = time;
%     else
%         time = exp_tail(); % off-time with exponential tail
%         CoreStatus(CoreNumber,OnOrOff) = 1; %0;
%         CoreStatus(CoreNumber,CycleOfLastCompletedTime) = SimCycle-1;
%         CoreStatus(CoreNumber,DurationOfNextTime) = time;
%     end
% end
%     
% end

CoreStatus(CoreNumber,OnOrOff) = 1;