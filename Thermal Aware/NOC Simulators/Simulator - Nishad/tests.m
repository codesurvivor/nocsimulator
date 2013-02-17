%% test programs
clc;
%% tests for global variable properties
% global CycleOfLastCompletedTime;
% CycleOfLastCompletedTime = 1;
% CycleOfLastCompletedTime
% flit_generate();
% CycleOfLastCompletedTime

% test for generate random address
% global UniformRandom;
% UniformRandom = 1;
% global MaxCoreNumber;
% MaxCoreNumber = 16;
% MaxSimCycle = 10000;
% 
% traffic = UniformRandom;
% CoreNumber = 4;
% 
% bin = zeros(MaxCoreNumber,1);
% error = 0;
% h = waitbar(0,'Simulation in progress, please wait...');
% for SimCycle = 1:MaxSimCycle,
%     DestinationAddress = generate_destination(CoreNumber, traffic);
%     if((DestinationAddress < 1) || (DestinationAddress > MaxCoreNumber))
%         error = error + 1;
%     else
%         bin(DestinationAddress) = bin(DestinationAddress) + 1;
%     end
%     waitbar(SimCycle/MaxSimCycle);
% end
% close(h);
% figure;
% plot(bin);

%% tests for message injection
% clear;
% % Global Simulation numbers
% global MsgLength; % Number of flits in messages
% MsgLength = 8;
% global MaxNumberOfVC; % maximum number of VCs in all ports
% MaxNumberOfVC = 4;
% global CoreBufferDepth;
% CoreBufferDepth = MsgLength;
% 
% % Data Structure indices of CoreStatus (values: 1,2,3,4)
% % 2D array
% % row denoted by CoreNumber
% global CycleOfLastCompletedTime; % value = 1
% CycleOfLastCompletedTime = 1;
% global OnOrOff; % value = 2
% OnOrOff = 2;
% global DurationOfNextTime; % value = 3
% DurationOfNextTime = 3;
% global CurrentMsgNumber; % value = 4
% CurrentMsgNumber = 4;
% 
% % Data Structure indices for MsgStatus
% % 2D array
% % row denoted by MsgNumber
% global VCNumber; % value = 1
% VCNumber = 1;
% global FlitsLeft; % value = 2
% FlitsLeft = 2;
% global Source; % value = 3
% Source = 3;
% global Destination; % value = 4
% Destination = 4;
% 
% % struture of InputVCBufferStatus
% % 4D array
% % 1st dimension denoted by switch number
% % 2nd dimension denoted by port number of the switch
% % 3rd dimension denoted by VC number
% global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
% % global FlitsPassedFromVC; % value = 2, contains the number of flits of MsgNumber passed from the VC
% % global NextPortNumber; % value = 3,contains the next port number for the flit
% % global NextVCNumber; % value = 4, contains the next port's VC number for the flit
% global NumberOfFreeFIFO; % value = 5, initialized to BufferDepth
% MsgNumberInVC = 1;
% NumberOfFreeFIFO = 5;
% 
% % Data Structure indices for CoreBufferStatus
% % 2D array
% % row denoted by CoreNumber
% % 2nd dimension by VCNumber (1 to MaxNumberOfVC)
% 
% % Global informatio
% global UniformRandom;
% UniformRandom = 1;
% global MaxCoreNumber;
% MaxCoreNumber = 6;
% InjectionLoad = 1;
% traffic = UniformRandom;
% CoreNumber = 4;
% global MaxPortNumber;
% MaxPortNumber = 4;
% % Initialization
% 
% InputVCBufferStatus = CoreBufferDepth*zeros(MaxCoreNumber,MaxPortNumber, MaxNumberOfVC, NumberOfFreeFIFO);
% InputVCBufferStatus ( :, : ,:, NumberOfFreeFIFO ) = CoreBufferDepth;
% CoreStatus = zeros(MaxCoreNumber,CurrentMsgNumber);
% % for i = 1:MaxCoreNumber,
% %     if(rand<0.5)
% %         CoreStatus(i, OnOrOff) = 1; % set Core# 4 to On for injection
% %     end
% % end
% CoreStatus(4, OnOrOff) = 1;
% CoreStatus(4, CurrentMsgNumber) = 1;
% InputVCBufferStatus( 4,1,2,1) = 1;
% %MsgStatus = zeros(1, Destination); % init with 1 dummy message
% MsgStatus = [ 2 5 4 5];
% CoreBufferStatus = CoreBufferDepth*ones(MaxCoreNumber,MaxNumberOfVC);
% for j = 1:2*MsgLength-1,
%     for i = 1:MaxCoreNumber,
%         
%         [ CoreStatus, CoreBufferStatus, MsgStatus, InputVCBufferStatus ] = flit_generate( InjectionLoad, traffic, i, CoreStatus, CoreBufferStatus, MsgStatus, InputVCBufferStatus );
%        
%     end
%     CoreStatus
%         MsgStatus
%        CoreBufferStatus
%        InputVCBufferStatus( 4,1,2,5)
% end
    
%% % test for power tail
% bin = zeros(1, 1000);
% h = waitbar(0,'Simulation in progress, please wait..');
% for i = 1:10000,
%     [ time ] = heavy_tail( );
%     % t = round(time);
%     bin(time) = bin(time) + 1;
%     waitbar(i/10000);
% end
% close(h);
% figure;
% semilogy(bin);    

%% % tests for message injection on all cores
% clear;
% % Global Simulation numbers
% global MsgLength; % Number of flits in messages
% MsgLength = 4;
% global MaxNumberOfVC; % maximum number of VCs in all ports
% MaxNumberOfVC = 4;
% global CoreBufferDepth;
% CoreBufferDepth = 4;
% % Global information
% global UniformRandom;
% UniformRandom = 1;
% global MaxCoreNumber;
% MaxCoreNumber = 4;
% InjectionLoad = 1;
% traffic = UniformRandom;
% 
% % Data Structure indices of CoreStatus (values: 1,2,3,4)
% % 2D array
% % row denoted by CoreNumber
% global CycleOfLastCompletedTime; % value = 1
% CycleOfLastCompletedTime = 1;
% global OnOrOff; % value = 2
% OnOrOff = 2;
% global DurationOfNextTime; % value = 3
% DurationOfNextTime = 3;
% global CurrentMsgNumber; % value = 4
% CurrentMsgNumber = 4;
% 
% % Data Structure indices for MsgStatus
% % 2D array
% % row denoted by MsgNumber
% global VCNumber; % value = 1
% VCNumber = 1;
% global FlitsLeft; % value = 2
% FlitsLeft = 2;
% global Source; % value = 3
% Source = 3;
% global Destination; % value = 4+
% Destination = 4;
% 
% % Data Structure indices for CoreBufferStatus
% % 2D array
% % row denoted by CoreNumber
% % 2nd dimension by VCNumber (1 to MaxNumberOfVC)
% 
% % struture of InputVCBufferStatus
% % 4D array
% % 1st dimension denoted by switch number
% % 2nd dimension denoted by port number of the switch
% % 3rd dimension denoted by VC number
% global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
% % global FlitsPassedFromVC; % value = 2, contains the number of flits of MsgNumber passed from the VC
% % global NextPortNumber; % value = 3,contains the next port number for the flit
% % global NextVCNumber; % value = 4, contains the next port's VC number for the flit
% global NumberOfFreeFIFO; % value = 5, initialized to BufferDepth
% MsgNumberInVC = 1;
% NumberOfFreeFIFO = 5;
% 
% global MaxPortNumber;
% MaxPortNumber = 4;
% 
% % Initialization
% CoreStatus = zeros(MaxCoreNumber,CurrentMsgNumber); % initialize with all cores reset
% MsgStatus = zeros(1, Destination); % init with 1 dummy message.
% CoreBufferStatus = CoreBufferDepth*ones(MaxCoreNumber,MaxNumberOfVC);
% InputVCBufferStatus = CoreBufferDepth*zeros(MaxCoreNumber,MaxPortNumber, MaxNumberOfVC, NumberOfFreeFIFO);
% InputVCBufferStatus ( :, : ,:, NumberOfFreeFIFO ) = CoreBufferDepth;
% for SimCycle = 1:10
%     SimCycle
%     
%     [ CoreStatus, CoreBufferStatus, MsgStatus, InputVCBufferStatus ] = flit_generate_all_cores( SimCycle, InjectionLoad, traffic, CoreStatus, MsgStatus, CoreBufferStatus, InputVCBufferStatus );
%     CoreStatus
%     MsgStatus
%         CoreBufferStatus
%         %InputVCBufferStatus
% end

%% % Test for flit absorb function

% % global simulation parameters
% global OutputBufferDepth; % max depth of output VCs
% OutputBufferDepth = 4;
% global MsgLength;
% MsgLength = 16;
% global MaxCoreNumber;
% MaxCoreNumber = 4; % 2x2 mesh
% global MaxOutputVCNumber;
% MaxOutputVCNumber = 4;
% global MaxVCNumberOutput;
% MaxVCNumberOutput = 4;
% global MaxNumberOfVC;
% MaxNumberOfVC = 4;
% 
% % Structure of AbsorbArbitStatus
% % 2D array: contains the number of the VC last serviced for flit absorption
% % 1st dimension addressed by core/switch number
% % 2nd dimension by port number: which is always 1 for ports to the core
% % structure maintained same as InputVCBufferStatus to reuse the
% % input_arbitrate funtion
% 
% % structure of OutputVCBufferStatus
% % 4D array
% % 1st dimension denoted by switch number
% % 2nd dimension denoted by port number of the switch
% % 3rd dimension denoted by VC number
% global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
% global NumberOfFreeFIFOOutput; % value = 2, contains the number of free FIFOs in the output VC
% global FlitsPassedFromVCOutput; % value = 3, contains the number of flits passed from this virtual channel (not needed in this function; needed for inter-move)
% MsgNumberInVC = 1;
% NumberOfFreeFIFOOutput = 2;
% FlitsPassedFromVCOutput = 3;
% 
% AbsorbArbitStatus = zeros(MaxCoreNumber,2);
% OutputVCBufferStatus = zeros(MaxCoreNumber,5,MaxVCNumberOutput,FlitsPassedFromVCOutput); % assumed 5 ports for a mesh switch
% OutputVCBufferStatus( :, :, :,NumberOfFreeFIFOOutput) = 4;
% OutputVCBufferStatus(1,1,3,NumberOfFreeFIFOOutput) = 1;
% OutputVCBufferStatus(1,1,3,MsgNumberInVC) = 1;
% OutputVCBufferStatus(1,1,2,NumberOfFreeFIFOOutput) = 1;
% OutputVCBufferStatus(1,1,2,MsgNumberInVC) = 2;
% % for i = 1:MaxCoreNumber,
% %     for j = 1:5,
% %         for ii = 1:MaxVCNumberOutput,
% %             OutputVCBufferStatus(i,j,ii,NumberOfFreeFIFOOutput) = 2;
% %             OutputVCBufferStatus(i,j,ii,MsgNumberInVC) = i+j+ii;
% %         end
% %     end
% % end
% 
% for SimCycle = 1:5
%     SimCycle
%     %OutputVCBufferStatus
%     [ OutputVCBufferStatus, AbsorbArbitStatus ] = flit_absorb( OutputVCBufferStatus, AbsorbArbitStatus  );
%     OutputVCBufferStatus
%     AbsorbArbitStatus
% end


 %% tests for intra switch move old functions

% % initializations
% 
% % global simulation parameters
% global MsgLength; % Number of flits in messages
% MsgLength = 64;
% global MaxNumberOfVC; % maximum number of VCs in all ports
% MaxNumberOfVC = 3;
% global MaxOutputVCNumber; % VC number of output ports
% MaxOutputVCNumber = 3;
% global MaxSwitchNumber; % maximum number of switches determined by topology
% MaxSwitchNumber = 9;
% global BufferDepth; % maximum depth of VC buffers
% BufferDepth = 5;
% global OutputBufferDepth; % max depth of output VCs
% OutputBufferDepth = 5;
% global RoutingType; % value denotes type of routing adopted
% RoutingType = 1;
% global Mesh; % routing type of Mesh
% Mesh = 1;
% global TileDimension;
% TileDimension = [3 3];
% global XDim; % 1
% XDim = 1;
% global YDim; % 2
% YDim = 2;
% % structure of PortNumber
% % 1D array
% % 1st dimension denoted by switch number
% % contains the nummber of ports for a particular switch, formed depending
% % upon topology, can be globally defined
% global PortNumber;
% PortNumber = 3*ones(MaxSwitchNumber,1); % mesh topology
% 
% % Data Structure indices for MsgStatus
% % 2D array
% % row denoted by MsgNumber
% global VCNumber; % value = 1
% VCNumber =1;
% global FlitsLeft; % value = 2
% FlitsLeft = 2;
% global Source; % value = 3
% Source = 3;
% global Destination; % value = 4
% Destination = 4;
% 
% % structure of Connectivity
% % 3D array with switch number on both dimensions (row sender and column
% % receiver)
% % contains the number of cycles needed by each link between switches,
% % sending and receiving port numbers as well
% % default 0 for no link
% global Connectivity; % the array
% global LinkCycle; % value = 1, contains number of cycles taken by link for flit traversal
% LinkCycle = 1;
% global SendPort; % value = 2, contains the number of the port of sending switch
% SendPort = 2;
% global RecvPort; % value = 3, contains number of the port of the receiving switch
% RecvPort = 3;
% %yglobal Connectivity;
% Connectivity = zeros(MaxSwitchNumber,MaxSwitchNumber,RecvPort); % init
% Connectivity(1,2,LinkCycle) = 1;
% Connectivity(1,2,SendPort) = 3;
% Connectivity(1,2,RecvPort) = 3;
% Connectivity(1,4,LinkCycle) = 2;
% Connectivity(1,4,SendPort) = 2;
% Connectivity(1,4,RecvPort) = 2;
% Connectivity(2,3,LinkCycle) = 2;
% Connectivity(2,3,SendPort) = 1;
% Connectivity(2,3,RecvPort) = 1;
% 
% % structure of InputArbitStatus and OutputArbitStatus
% % 2D array
% % 1st dimension denoted by Switch Number
% % 2nd dimension denoted by port number
% % contains the number of the VC (for Input) or input port (for Output) last
% % served
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
% MsgNumberInVC = 1;
% FlitsPassedFromVC = 2;
% NextPortNumber = 3;
% NextVCNumber = 4;
% NumberOfFreeFIFO = 5;
% 
% % structure of OutputVCBufferStatus
% % 4D array
% % 1st dimension denoted by switch number
% % 2nd dimension denoted by port number of the switch
% % 3rd dimension denoted by VC number
% % global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
% global NumberOfFreeFIFOOutput; % value = 2, contains the number of free FIFOs in the output VC
% global FlitsPassedFromVCOutput; % value = 3, contains the number of flits passed from this virtual channel (not needed in this function; needed for inter-move)
% % MsgNumberInVC = 1;
% NumberOfFreeFIFOOutput = 2;
% FlitsPassedFromVCOutput = 3;
% 
% InputArbitStatus = zeros(MaxSwitchNumber, 3);
% OutputArbitStatus = zeros(MaxSwitchNumber, 3);
% 
% MsgStatus = zeros(2,Destination);
% MsgStatus(1,Destination) = 8;
% MsgStatus(1,Source) = 1;
% MsgStatus(2,Destination) = 3;
% MsgStatus(2,Source) = 1;
% % MsgStatus(1,FlitsLeft) = 0;
% InputVCBufferStatus = zeros(MaxSwitchNumber,3, MaxNumberOfVC, NumberOfFreeFIFO);
% InputVCBufferStatus( :, :, :, 5 ) = BufferDepth;
% OutputVCBufferStatus = zeros(MaxSwitchNumber,3,MaxOutputVCNumber,FlitsPassedFromVCOutput);
% OutputVCBufferStatus(:, :, :, 2) = OutputBufferDepth;
% InputVCBufferStatus (1,1,2,MsgNumberInVC) = 1;
% InputVCBufferStatus (1,1,2,NumberOfFreeFIFO) = 1;
% InputVCBufferStatus (1,1,3,MsgNumberInVC) = 2;
% InputVCBufferStatus (1,1,3,NumberOfFreeFIFO) = 2;
% for SimCycle = 1:10
%     SimCycle;
%     %OutputVCBufferStatus
%     [ InputVCBufferStatus, OutputVCBufferStatus, InputArbitStatus, OutputArbitStatus ] = intra_switch_moves( InputVCBufferStatus, OutputVCBufferStatus, InputArbitStatus, OutputArbitStatus, MsgStatus );
%     
%     InputVCBufferStatus
%     OutputVCBufferStatus
% end
% 
% 
 %% tests for intra switch move functions

% initializations

% global simulation parameters
global MsgLength; % Number of flits in messages
MsgLength = 64;
global MaxNumberOfVC; % maximum number of VCs in all ports
MaxNumberOfVC = 3;
global MaxOutputVCNumber; % VC number of output ports
MaxOutputVCNumber = 3;
global MaxSwitchNumber; % maximum number of switches determined by topology
MaxSwitchNumber = 9;
global BufferDepth; % maximum depth of VC buffers
BufferDepth = 5;
global OutputBufferDepth; % max depth of output VCs
OutputBufferDepth = 5;
global RoutingType; % value denotes type of routing adopted
RoutingType = 3;
global Mesh; % routing type of Mesh
Mesh = 1;
global TileDimension;
TileDimension = [3 3];
global XDim; % 1
XDim = 1;
global YDim; % 2
YDim = 2;
% structure of PortNumber
% 1D array
% 1st dimension denoted by switch number
% contains the nummber of ports for a particular switch, formed depending
% upon topology, can be globally defined
global PortNumber;
PortNumber = 5*ones(MaxSwitchNumber,1); % mesh topology

% Data Structure indices for MsgStatus
% 2D array
% row denoted by MsgNumber
global VCNumber; % value = 1
VCNumber =1;
global FlitsLeft; % value = 2
FlitsLeft = 2;
global Source; % value = 3
Source = 3;
global Destination; % value = 4
Destination = 4;

% structure of Connectivity
% 3D array with switch number on both dimensions (row sender and column
% receiver)
% contains the number of cycles needed by each link between switches,
% sending and receiving port numbers as well
% default 0 for no link
global Connectivity; % the array
global LinkCycle; % value = 1, contains number of cycles taken by link for flit traversal
LinkCycle = 1;
global SendPort; % value = 2, contains the number of the port of sending switch
SendPort = 2;
global RecvPort; % value = 3, contains number of the port of the receiving switch
RecvPort = 3;
%yglobal Connectivity;
X = TileDimension(XDim);
 
%N = 64;
for i = 1:MaxSwitchNumber
    for j = 1:MaxSwitchNumber
        if i == j
            Connectivity(i,j,1) = 0;
        else
            Connectivity(i,j,1) = 1;  %ceil(rand*10);
        end
        ysend = ceil(i/X);
        xsend = mod(i, X);
        yrecv = ceil(j/X);
        xrecv = mod(j, X);
        
        if xsend == 0
            xsend = X;
        end
        if xrecv == 0
            xrecv = X;
        end
        
        if (ysend == yrecv)
            if (xsend == xrecv + 1)
                Connectivity(i,j,2) = 5;
            end
            if (xsend == xrecv - 1)
                Connectivity(i,j,2) = 3;
            end
        end
        if (xsend == xrecv) 
            if (ysend == yrecv + 1)   
                 Connectivity(i,j,2) = 2;
            end
            if (ysend == yrecv - 1)
               Connectivity(i,j,2) = 4;
            end
        end
    end
end
 Connectivity( :, :,3) = Connectivity( :, :,2)';

        
% structure of InputArbitStatus and OutputArbitStatus
% 2D array
% 1st dimension denoted by Switch Number
% 2nd dimension denoted by port number
% contains the number of the VC (for Input) or input port (for Output) last
% served

% Data Structure indices for CoreBufferStatus
% 2D array
% row denoted by CoreNumber
% 2nd dimension by VCNumber (1 to MaxNumberOfVC)

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
MsgNumberInVC = 1;
FlitsPassedFromVC = 2;
NextPortNumber = 3;
NextVCNumber = 4;
NumberOfFreeFIFO = 5;

% structure of OutputVCBufferStatus
% 4D array
% 1st dimension denoted by switch number
% 2nd dimension denoted by port number of the switch
% 3rd dimension denoted by VC number
% global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
global NumberOfFreeFIFOOutput; % value = 2, contains the number of free FIFOs in the output VC
global FlitsPassedFromVCOutput; % value = 3, contains the number of flits passed from this virtual channel (not needed in this function; needed for inter-move)
% MsgNumberInVC = 1;
NumberOfFreeFIFOOutput = 2;
FlitsPassedFromVCOutput = 3;

InputArbitStatus = zeros(MaxSwitchNumber, 3);
OutputArbitStatus = zeros(MaxSwitchNumber, 3);
PortArbitStatus = zeros(MaxSwitchNumber, 1);
%VirtualArbitStatus = zeros(MaxSwitchNumber,MaxPortNumber);
VirtualArbitStatus = zeros(MaxSwitchNumber,5);


MsgStatus = zeros(2,Destination);
MsgStatus(1,Destination) = 3;
MsgStatus(1,Source) = 2;
MsgStatus(2,Destination) = 3;
MsgStatus(2,Source) = 4;
% MsgStatus(1,FlitsLeft) = 0;
CoreBufferStatus = BufferDepth*ones(MaxSwitchNumber,MaxNumberOfVC);
InputVCBufferStatus = zeros(MaxSwitchNumber,5, MaxNumberOfVC, NumberOfFreeFIFO);
InputVCBufferStatus( :, :, :, 5 ) = BufferDepth;
OutputVCBufferStatus = zeros(MaxSwitchNumber,5,MaxOutputVCNumber,FlitsPassedFromVCOutput);
OutputVCBufferStatus(:, :, :, 2) = OutputBufferDepth;
InputVCBufferStatus (1,1,2,MsgNumberInVC) = 1;
InputVCBufferStatus (1,1,2,NumberOfFreeFIFO) = 1;
InputVCBufferStatus (1,4,3,MsgNumberInVC) = 2;
InputVCBufferStatus (1,4,3,NumberOfFreeFIFO) = 2;
% InputVCBufferStatus (1,4,3,FlitsPassedFromVC) = 2;
% InputVCBufferStatus (1,4,3,NextPortNumber) = 3;
% InputVCBufferStatus (1,4,3,NextVCNumber) = 1;
% OutputVCBufferStatus(1,3,1,MsgNumberInVC) = 2;
for SimCycle = 1:10
    SimCycle
    %OutputVCBufferStatus
    [ InputVCBufferStatus, OutputVCBufferStatus, PortArbitStatus, CoreBufferStatus, VirtualArbitStatus ] = intra_switch_moves( InputVCBufferStatus, OutputVCBufferStatus, PortArbitStatus, MsgStatus, CoreBufferStatus, VirtualArbitStatus );
      
    InputVCBufferStatus
    OutputVCBufferStatus
end


