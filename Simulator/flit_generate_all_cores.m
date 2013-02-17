function [ CoreStatus, CoreBufferStatus, MsgStatus, InputVCBufferStatus ] = flit_generate_all_cores( SimCycle, InjectionLoad, traffic, CoreStatus, MsgStatus, CoreBufferStatus, InputVCBufferStatus )
% Generates flits, header or body for all cores in a single cycle
%   Determines On or Off state of a Core as well
%   Modifies input VC buffer for switch connected to core as well

% Global Simulation numbers
global MaxCoreNumber;
% global MsgLength; % Number of flits in messages
% global MaxNumberOfVC; % maximum number of VCs in all ports
global CorePort; % Port number where all cores are connected to the switch; value = 1
global MulticastSource1;
global MulticastSource2;
global WirelessTranscievers;
global MulticastSource;
% Data Structure indices of CoreStatus (values: 1,2,3,4)
% 2D array
% row denoted by CoreNumber
global OnOrOff; % value = 1
% global CurrentMsgNumber; % value = 2
% global CurrentMsgNumber2; % value = 3
% global CurrentMsgNumber3; % value = 4
% global CurrentMsgNumber5; % value = 5
% global CurrentMsgNumber6; % value = 6
% global CurrentMsgNumber7; % value = 7

% Data Structure indices for MsgStatus
% 2D array
% row denoted by MsgNumber
% global VCNumber; % value = 1
% global FlitsLeft; % value = 2
% global Source; % value = 3
% global Destination; % value = 4
% global InjectCycle; % value = 5
% global AbsorbCycle; % value = 6

% Data Structure indices for CoreBufferStatus
% 2D array
% row denoted by CoreNumber
% 2nd dimension by VCNumber (1 to MaxNumberOfVC)
% 
% % struture of InputVCBufferStatus
% % 4D array
% % 1st dimension denoted by switch number
% % 2nd dimension denoted by port number of the switch
% % 3rd dimension denoted by VC number
% global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
% global FlitsPassedFromVC; % value = 2, contains the number of flits of MsgNumber passed from the VC
% global NextPortNumber; % value = 3,contains the next port number for the flit
% global NextVCNumber; % value = 4, contains the next port's VC number for the flit
% global NumberOfFreeFIFO; % value = 5, initialized to BufferDepth

% beginning loop for each core
for iCoreNumber = 1:MaxCoreNumber,
%     [ CoreStatus ] = determine_onofftime( SimCycle, iCoreNumber, CoreStatus );
    CoreStatus(iCoreNumber,OnOrOff) = 1;
%     if ((iCoreNumber == MulticastSource(MulticastSource1)) || (iCoreNumber == 100))
        
%        [ CoreStatus, CoreBufferStatus, MsgStatus, InputVCBufferStatus ] = flit_generate_multicast( InjectionLoad, traffic, iCoreNumber, CoreStatus, CoreBufferStatus, MsgStatus, InputVCBufferStatus );
%     else
        
    [ CoreStatus, CoreBufferStatus, MsgStatus, InputVCBufferStatus ] = flit_generate( InjectionLoad, traffic, iCoreNumber, CoreStatus, CoreBufferStatus, MsgStatus, InputVCBufferStatus );  
%     end
     
end    
end

