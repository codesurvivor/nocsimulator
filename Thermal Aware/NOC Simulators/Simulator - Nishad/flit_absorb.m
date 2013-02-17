function [ OutputVCBufferStatus, AbsorbArbitStatus, MsgStatus, ThroughputPerCycle ] = flit_absorb( OutputVCBufferStatus, AbsorbArbitStatus, MsgStatus, ThroughputPerCycle  )
% This function absorbs a flit in the output port of the switch connected
% to the core
%   needs to arbitrate between virtual channels

% global simulation parameters
global OutputBufferDepth; % max depth of output VCs
global MsgLength;
global MaxCoreNumber;
global MaxOutputVCNumber;
global NumberOfFlitsAbsorbed;
global SimCycle;
global ResetCycle;



% Data structure for energy calculations
%stores the energy comsumed for each flit in each message
global MsgEnergyStatus;
%3D array
%1D Message Number
%2D Flit Number of each message
%3D mentioned below
% global FlitInjectCycle; % value = 1
global FlitAbsorbCycle; % value = 2
global FlitEnergy ;     % value = 3



% p=p+1;

% Structure of AbsorbArbitStatus
% 2D array: contains the number of the VC last serviced for flit absorption
% 1st dimension addressed by core/switch number
% 2nd dimension by port number: which is always 1 for ports to the core
% structure maintained same as InputVCBufferStatus to reuse the
% input_arbitrate funtion

% Data Structure indices for MsgStatus
% 2D array
% row denoted by MsgNumber
% global VCNumber; % value = 1
% global FlitsLeft; % value = 2
% global Source; % value = 3
% global Destination; % value = 4
% global InjectCycle; % value = 5
global AbsorbCycle; % value = 6

% structure of OutputVCBufferStatus
% 4D array
% 1st dimension denoted by switch number
% 2nd dimension denoted by port number of the switch
% 3rd dimension denoted by VC number
global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
global NumberOfFreeFIFOOutput; % value = 2, contains the number of free FIFOs in the output VC
global FlitsPassedFromVCOutput; % value = 3, contains the number of flits passed from this virtual channel (not needed in this function; needed for inter-move)

for iCore = 1:MaxCoreNumber,
    AbsorbArbitStatus = input_arbitrate(iCore,1,AbsorbArbitStatus); % core number is same as switch number and port number for core connection in 1
    count = 0;
    while(OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),NumberOfFreeFIFOOutput) == OutputBufferDepth && count < MaxOutputVCNumber)
        AbsorbArbitStatus = input_arbitrate(iCore,1,AbsorbArbitStatus);
        count = count + 1;
    end
    if(OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),NumberOfFreeFIFOOutput) < OutputBufferDepth) % arbited VC has a flit
        OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),NumberOfFreeFIFOOutput) = OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),NumberOfFreeFIFOOutput) + 1;
        OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),FlitsPassedFromVCOutput) = OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),FlitsPassedFromVCOutput) + 1;
      
        % Update number of flits absorbed per cycle
        ThroughputPerCycle(SimCycle,1) = ThroughputPerCycle(SimCycle,1) + 1;
        
        %Updating Absorb cycle for each flit in each message
        MsgEnergyStatus(OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),MsgNumberInVC),OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),FlitsPassedFromVCOutput),FlitAbsorbCycle) = SimCycle;
        
       
%         if OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),FlitsPassedFromVCOutput) == MsgLength
%             MsgStatus(OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),MsgNumberInVC), AbsorbCycle) = SimCycle;
%         end
           if SimCycle > ResetCycle
                 NumberOfFlitsAbsorbed = NumberOfFlitsAbsorbed + 1;
           end
        if(OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),FlitsPassedFromVCOutput) == MsgLength) % tail flit has just passed
            MsgStatus(OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),MsgNumberInVC), AbsorbCycle) = SimCycle;
            OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),MsgNumberInVC) = 0; % reset to unreserved VC
            OutputVCBufferStatus(iCore,1,AbsorbArbitStatus(iCore,1),FlitsPassedFromVCOutput) = 0;
%             NumberOfFlitsAbsorbed = NumberOfFlitsAbsorbed + 1;
            % the rest of the fields must be automatically updated
            % update MsgStatus for throughput, energy and latency numbers
        end
    end
end

end

