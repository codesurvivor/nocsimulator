function [ InputVCBufferStatus, OutputVCBufferStatus, PortArbitStatus, CoreBufferStatus, VirtualArbitStatus, MsgStatus ] = intra_switch_moves( InputVCBufferStatus, OutputVCBufferStatus, PortArbitStatus, MsgStatus, CoreBufferStatus, VirtualArbitStatus )
% This function processes intra switch moves for all swithces in the NoC
%   For each switch it checks the status of the input ports arbitrates and
%   places a flit on the appropriate output port

% global simulation parameters
global MsgLength; % Number of flits in messages
global MaxNumberOfVC; % maximum number of VCs in all ports
global MaxOutputVCNumber; % VC number of output ports
global MaxSwitchNumber; % maximum number of switches determined by topology
global BufferDepth; % maximum depth of VC buffers
global OutputBufferDepth; % max depth of output VCs

% structure of PortNumber
% 1D array
% 1st dimension denoted by switch number
% contains the nuymber of ports for a particular switch, formed depending
% upon topology, can be globally defined
global PortNumber;

% structure of Connectivity
% 2D array with switch number on both dimensions
% contains the number of cycles needed by each link between switches,
% default 0 for no link
global Connectivity;

% struture of InputVCBufferStatus
% 4D array
% 1st dimension denoted by switch number
% 2nd dimension denoted by port number of the switch
% 3rd dimension denoted by VC number
global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
global FlitsPassedFromVC; % value = 2, contains the number of flits of MsgNumber passed from the VC
global NextPortNumber; % value = 3,contains the next port number for the flit
global NextVCNumber; % value = 4, contains the next port's VC number for the flit
global NumberOfFreeFIFO; % value = 5, initialized to BufferDepth

% structure of OutputVCBufferStatus
% 4D array
% 1st dimension denoted by switch number
% 2nd dimension denoted by port number of the switch
% 3rd dimension denoted by VC number
% global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
global NumberOfFreeFIFOOutput; % value = 2, contains the number of free FIFOs in the output VC
% global FlitsPassedFromVCOutput; % value = 3, contains the number of flits passed from this virtual channel (not needed in this function; needed for inter-move)
       
% Data Structure indices for CoreBufferStatus
% 2D array contains the number of FIFOs free in the VC
% row denoted by CoreNumber
% 2nd dimension by VCNumber (1 to MaxNumberOfVC)

% structure of PortArbitStatus 
% 2D array
% 1st dimension denoted by Switch Number
% contains the number of the input port last served

% structure of VirtualArbitStatus
% 2D array
% 1st dimension denoted by Switch Number
% 2nd dimension denoted by port number
% contains the number of the VC last served for input each port

global SwitchTotal;

%Naseef Mansoor
% Data Structure indices for MsgStatus
% 2D array
% row denoted by MsgNumber
global VCNumber; % value = 1
VCNumber = 1;
global FlitsLeft; % value = 2
FlitsLeft = 2;
global Source; % value = 3
Source = 3;
global Destination; % value = 4
Destination = 4;
global InjectCycle; % value = 5
InjectCycle = 5;
global AbsorbCycle; % value = 6
AbsorbCycle = 6;
global CurrentBufferDirection; % value = 7
CurrentBufferDirection = 7;
global SwitchCycles;
SwitchCycles = 8;
global BufferCycles;
BufferCycles = 9;
% Here we are updating the Switchcyle for the flits either waiting in the
% input VC of a switch or moving from input VC to output VC of the same
% switch
% for iMsgNo=1:size(MsgStatus,XDim)
% MsgStatus(iMsgNo,SwitchCycles)
% end

for iSwitch = 1:SwitchTotal
    for jPort = 1:PortNumber(iSwitch)
        NumberOfFlitsInVCForMsgiMsg=0;
        for kVC = 1:MaxNumberOfVC
            iMsgNo=InputVCBufferStatus(iSwitch,jPort,kVC,MsgNumberInVC); 
            % determine the message number for the VC
            if(iMsgNo~=0)
                % Check this VC is not free or we have a valid iMsgNo
%                 if(InputVCBufferStatus(iSwitch,jPort,kVC,NumberOfFreeFIFO)==0)
%                      NumberOfFlitsInVCForMsgiMsg=BufferDepth;
%                 elseif(InputVCBufferStatus(iSwitch,jPort,kVC,NumberOfFreeFIFO)==BufferDepth)
%                      NumberOfFlitsInVCForMsgiMsg=0;
%                 else
                    NumberOfFlitsInVCForMsgiMsg=BufferDepth-InputVCBufferStatus(iSwitch,jPort,kVC,NumberOfFreeFIFO);
                    %determine the Number Of Flits In KVC ForMsg number iMsg
%                 end
                MsgStatus(iMsgNo,SwitchCycles)=MsgStatus(iMsgNo,SwitchCycles)+NumberOfFlitsInVCForMsgiMsg;
                %update MsgStatus
            end
         end
    end
end
%naseef mansoor end


% for body flits including tail
for iSwitch = 1:SwitchTotal
    for jPort = 1:PortNumber(iSwitch)
        for kVC = 1:MaxNumberOfVC
            % if body flit is available in input port, it is passed to the
            % corresponding output port
            if (InputVCBufferStatus(iSwitch,jPort,kVC,FlitsPassedFromVC) ~= 0) && (InputVCBufferStatus(iSwitch,jPort,kVC,NumberOfFreeFIFO) ~= BufferDepth) && (OutputVCBufferStatus(iSwitch,InputVCBufferStatus(iSwitch,jPort,kVC,NextPortNumber),InputVCBufferStatus(iSwitch,jPort,kVC,NextVCNumber),NumberOfFreeFIFOOutput) ~= 0)
                InputVCBufferStatus(iSwitch,jPort,kVC,FlitsPassedFromVC) = InputVCBufferStatus(iSwitch,jPort,kVC,FlitsPassedFromVC) + 1;
                InputVCBufferStatus(iSwitch,jPort,kVC,NumberOfFreeFIFO) = InputVCBufferStatus(iSwitch,jPort,kVC,NumberOfFreeFIFO) + 1;
                OutputVCBufferStatus(iSwitch,InputVCBufferStatus(iSwitch,jPort,kVC,NextPortNumber),InputVCBufferStatus(iSwitch,jPort,kVC,NextVCNumber),NumberOfFreeFIFOOutput) = OutputVCBufferStatus(iSwitch,InputVCBufferStatus(iSwitch,jPort,kVC,NextPortNumber),InputVCBufferStatus(iSwitch,jPort,kVC,NextVCNumber),NumberOfFreeFIFOOutput) - 1;
                if jPort == 1 % for core port update CoreBufferStatus
                    CoreBufferStatus(iSwitch,kVC) = CoreBufferStatus(iSwitch,kVC) + 1;
                end
                if InputVCBufferStatus(iSwitch,jPort,kVC,FlitsPassedFromVC) == MsgLength  % tail flit passed so empty input VC
                    % free VC
                    InputVCBufferStatus(iSwitch,jPort,kVC,MsgNumberInVC) = 0;
                    InputVCBufferStatus(iSwitch,jPort,kVC,FlitsPassedFromVC) = 0;
                    InputVCBufferStatus(iSwitch,jPort,kVC,NextPortNumber) = 0;
                    InputVCBufferStatus(iSwitch,jPort,kVC,NextVCNumber) = 0;
                    InputVCBufferStatus(iSwitch,jPort,kVC,NumberOfFreeFIFO) = BufferDepth;
                    if jPort == 1 % for core port update CoreBufferStatus
                        CoreBufferStatus(iSwitch,kVC) = BufferDepth;
                    end
                end
            end
        end
    end
end

% for header flits
for iSwitch = 1:SwitchTotal
    RoutingDone = 0;
    PortCount = 0;
    % arbitrating among all the ports, till routing is done
    while (RoutingDone ~= 1) && (PortCount < PortNumber(iSwitch))
        PortArbitStatus = port_arbitrate(iSwitch, PortArbitStatus);
        VCcount = 0;
        % arbitrating among the virtual channels, till routing is done
        while (RoutingDone ~= 1) && ( VCcount < MaxNumberOfVC )   
            VirtualArbitStatus = input_arbitrate(iSwitch,PortArbitStatus(iSwitch),VirtualArbitStatus);
            if (InputVCBufferStatus(iSwitch,PortArbitStatus(iSwitch),VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)),FlitsPassedFromVC) == 0) && (InputVCBufferStatus(iSwitch,PortArbitStatus(iSwitch),VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)),NumberOfFreeFIFO) ~= BufferDepth) && (RoutingDone ~= 1) % if a header flit is found in the input VC buffer     
                ijMsgNumber = InputVCBufferStatus( iSwitch, PortArbitStatus(iSwitch), VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)), MsgNumberInVC );
                
                [ InputVCBufferStatus( iSwitch, PortArbitStatus(iSwitch), VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)), NextPortNumber ), MsgStatus ] = routing(iSwitch, ijMsgNumber, MsgStatus );
                    % finding a free VC in the output buffers
                    FreeVC = 0;
                    for iVC = 1:MaxOutputVCNumber
                        if(OutputVCBufferStatus(iSwitch,InputVCBufferStatus( iSwitch, PortArbitStatus(iSwitch), VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)), NextPortNumber ),iVC,MsgNumberInVC) == 0)
                            FreeVC = iVC;

                            break;
                        end
                    end
                      % if free VC is found in the output buffers
                    if(FreeVC ~= 0)
                        RoutingDone = 1;
                        % update output buffers for header 
                        OutputVCBufferStatus(iSwitch,InputVCBufferStatus( iSwitch, PortArbitStatus(iSwitch), VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)), NextPortNumber ),FreeVC,MsgNumberInVC) = InputVCBufferStatus( iSwitch, PortArbitStatus(iSwitch), VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)), MsgNumberInVC );
                        OutputVCBufferStatus(iSwitch,InputVCBufferStatus( iSwitch, PortArbitStatus(iSwitch), VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)), NextPortNumber ),FreeVC,NumberOfFreeFIFOOutput) = OutputVCBufferStatus(iSwitch,InputVCBufferStatus( iSwitch, PortArbitStatus(iSwitch), VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)), NextPortNumber ),FreeVC,NumberOfFreeFIFOOutput) - 1;
                        
                        % update input buffer
                        InputVCBufferStatus(iSwitch,PortArbitStatus(iSwitch),VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)),FlitsPassedFromVC) = InputVCBufferStatus(iSwitch,PortArbitStatus(iSwitch),VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)),FlitsPassedFromVC) + 1;
                        InputVCBufferStatus(iSwitch,PortArbitStatus(iSwitch),VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)),NextVCNumber) = FreeVC;
                        InputVCBufferStatus(iSwitch,PortArbitStatus(iSwitch),VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)),NumberOfFreeFIFO) = InputVCBufferStatus(iSwitch,PortArbitStatus(iSwitch),VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch)),NumberOfFreeFIFO) + 1;
                        if PortArbitStatus(iSwitch) == 1
                            
                            CoreBufferStatus(iSwitch,VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch))) = CoreBufferStatus(iSwitch,VirtualArbitStatus(iSwitch,PortArbitStatus(iSwitch))) + 1;
                        end
                    end
            end
            VCcount = VCcount + 1;
        end
        PortCount = PortCount + 1;
    end
end
end
        
    

