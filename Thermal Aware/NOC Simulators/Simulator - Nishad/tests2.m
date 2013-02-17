%% test2 - testing link buffers

clc;
clear all;

% initializations

% global simulation parameters
global MsgLength; % Number of flits in messages
MsgLength = 64;

% Wade Campney
% Changed #VC and OutputVC from 3 to 8

global MaxCoreNumber;
MaxCoreNumber = 64;
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
global MaxPortNumber;

global RoutingType; % value denotes type of routing adopted
RoutingType = 3;
global Mesh; % routing type of Mesh
Mesh = 1;
global DijkstraRouting;
DijkstraRouting = 3; % value = 3
global TileDimension;
TileDimension = [3 3];
global XDim; % 1
XDim = 1;
global YDim; % 2
YDim = 2;


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

% structure of LinkStatus
% 3D array
% 1st dimension: sending switch number
% 2nd dimension: receiving switch number
global SendCycle; % value = 1; contains the cycle of the SimCycle lst flit was sent in
global RecvCycle; % value = 2; contains the cycle of SimCycle lst flit was received in on this link
global SourceVC; % value = 3; contains the VC number at source port/switch currently
global DestinationVC; % value = 4, contains the destination VC number at destination port/switch
global MsgNumber; % value = 5, contains the msg number of the flit in transit
SendCycle = 1;
RecvCycle = 2;
SourceVC = 3;
DestinationVC = 4;
MsgNumber = 5;

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
global InjectCycle; % value = 5
InjectCycle = 5;
global AbsorbCycle; % value = 6
AbsorbCycle = 6;
global CurrentBufferDirection; % value = 7
CurrentBufferDirection = 7;

% structure of Connectivity
% 3D array with switch number on both dimensions (row sender and column
% receiver)
% contains the number of cycles needed by each link between switches,
% sending and receiving port numbers as well
% default 0 for no link
%global Connectivity; % the array
global LinkCycle; % value = 1, contains number of cycles taken by link for flit traversal
LinkCycle = 1;
global SendPort; % value = 2, contains the number of the port of sending switch
SendPort = 2;
global RecvPort; % value = 3, contains number of the port of the receiving switch
RecvPort = 3;
%yglobal Connectivity;
X = TileDimension(XDim);

global Connectivity;

Connectivity = zeros(MaxSwitchNumber,MaxSwitchNumber,RecvPort);

% Structure of LinkData
% contains the distance of the links between the switches
% row sender and column receiver (sender,receiver,#)
global LinkDistance;
LinkDistance = 1; % contains the actual distance
global NumBuff;
NumBuff = 2; % contains the number of buffers on the link
global NextJump;
NextJump = 3; % contains the number of the buffer for the next jump on 
              % the link

global LinkData;

LinkData = zeros(MaxSwitchNumber,MaxSwitchNumber,NextJump);

% structure of SBConnectivity(SwitchBufferConnectivity)
% 3D array with switch number on both dimensions (row sender and column
% receiver)

 % value = 1, contains number of cycles taken by link for flit traversal
LinkCycle = 1;
% value = 2, contains the number of the port of sending switch
SendPort = 2;
 % value = 3, contains number of the port of the receiving switch
RecvPort = 3;

global SBConnectivity;


% Structure of SwitchConn
% 1st dimension contains  switch number that the buffer sends to
% 2nd contains the lower numbered switch for a one buffer situation
% 3rd contains the higher numbered switch for a one buffer situation

global SwitchRecvPort; % value = 1; contains the number of the port of the receiving switch
SwitchRecvPort = 1;
global LowerBuff;  % value = 2; contains the number of the port the buffer sends out of
LowerBuff = 2;
global HigherBuff;  % value = 3; contains the number of the switch the buffer sends to
HigherBuff = 3;

global SwitchConn;

% Populate Connectivity

Connectivity(:,:,1) = xlsread('test_wired.xlsx');
LinkData(:,:,1) = xlsread('test_links.xlsx');

temp1=Connectivity( :, :,1);
temp2=zeros(MaxSwitchNumber,MaxSwitchNumber);

for i=1:MaxSwitchNumber
    PortCount=2;
    for j=1:MaxSwitchNumber
        if(temp1(i,j)==1)
        temp2(i,j)=PortCount;
        PortCount=PortCount+1;
        end
    end
end

Connectivity(:,:,2) = temp2;
Connectivity(:,:,3) = Connectivity(:,:,2)';

% Calculate the number of buffers on each link and the total number of
% buffers to populate LinkData(:,:,2)

% Calculate the number of buffers on each link and the total number of
% buffers to populate LinkData(:,:,2)

global TotalLinkBuffers;

TotalLinkBuffers = 0;

for i=1:MaxSwitchNumber
    
    for j=1:MaxSwitchNumber
        
        if(LinkData(i,j,1) ~= -1)
            TempNumBuffers = round((LinkData(i,j,1)/2) - 1);
            LinkData(i,j,2) = TempNumBuffers;
            TotalLinkBuffers = TotalLinkBuffers + TempNumBuffers;
        else
            LinkData(i,j,2) = -1;
        end
    end
end

TotalLinkBuffers = TotalLinkBuffers/2;

global SwitchTotal;

SwitchTotal = MaxSwitchNumber + TotalLinkBuffers;


% initialization of SwitchConn and SBConnectivity after the total number of
% buffers on the links was calculated

SwitchConn = zeros(TotalLinkBuffers,3);
SBConnectivity = zeros(TotalLinkBuffers,TotalLinkBuffers,3);

% Populate LinkData(:,:,3) with the next jumps 

CurrentBuff = MaxSwitchNumber + 1;

for i=1:MaxSwitchNumber
    
    for j=i:MaxSwitchNumber
        
        if(LinkData(i,j,2) > 0)
            LinkData(i,j,3) = CurrentBuff;    
            LinkData(j,i,3) = CurrentBuff + LinkData(i,j,2) - 1;
            CurrentBuff = CurrentBuff + LinkData(i,j,2);            
        else
            LinkData(i,j,3) = -1;    
            LinkData(j,i,3) = -1;
        end
    end
end

% Populate SBConnectivity with the sending and receiving ports for the buffers

for i=1:MaxSwitchNumber
    
    for j=i:MaxSwitchNumber
        temp = LinkData(i,j,3);
        if(temp > 0)
            % Switch i sends to buffer temp on port 2
            SBConnectivity(i,temp,2) = Connectivity(i,j,2);
            SBConnectivity(temp,i,2) = 2;
            while(temp < LinkData(j,i,3))
                % temp sends to the next buffer on 3 and receives on 2
                SBConnectivity(temp,temp+1,2) = 3;
                
                SBConnectivity(temp+1,temp,2) = 2;
                temp = temp + 1;
            end
            
         SBConnectivity(temp,j,2) = 3;
         SBConnectivity(j,temp,2) = Connectivity(j,i,2);
        end
    end
end

% Wade Campney
% Combining Connectivity into SBConnectivity so SBConnectivity will contain
% all the necessary information

for i=1:MaxSwitchNumber
    
    for j=1:MaxSwitchNumber
        
        if(LinkData(i,j,3) == -1)
            SBConnectivity(i,j,2) = Connectivity(i,j,2);
        end
    end
end

SBConnectivity(:,:,3) = SBConnectivity(:,:,2)';

% setting up SBConnectivity(:,:,1)

for i=1:SwitchTotal
    
    for j=1:SwitchTotal
        if(SBConnectivity(i,j,2) == 0)
            SBConnectivity(i,j,1) = -1;
        else
            SBConnectivity(i,j,1) = 1;
        end
    end
    
end

% Populating SwitchConn with the port number for the switch connected to
% the buffer

% If there is only one buffer inbetwen the switches, need to just use
% Connectivity to chose the necessary port.

for i=1:MaxSwitchNumber
    
    for j=i:MaxSwitchNumber
        tempSend1 = LinkData(i,j,3);
        tempSend2 = LinkData(j,i,3);
        
        if(tempSend1 > 0)
            if(tempSend1 == tempSend2)
                % Special case of only one buffer
                SwitchConn(tempSend1,1) = -1;
                SwitchConn(tempSend1,2) = i;
                SwitchConn(tempSend1,3) = j;
            else
                SwitchConn(tempSend1,1) = i;           
                
                SwitchConn(tempSend2,1) = j;
            end
        end
    end
end


% structure of PortNumber
% 1D array
% 1st dimension denoted by switch number
% contains the nummber of ports for a particular switch, formed depending
% upon topology, can be globally defined


% MAY HAVE MESSED UP BY MISTAKE - CHECK LATER

for i = 1:SwitchTotal
    
    if(i > MaxSwitchNumber)
        count = 3;
    else
        count = 1;
        for j = 1:MaxSwitchNumber
            if (Connectivity(i,j,LinkCycle) ~= -1)
                count = count + 1;
            end
        end
    end
    
    PortNumber(i) = count;

end

% Wade Campney
% My changes end here


MaxPortNumber = max(PortNumber);

% structure of DijkstraRoutingMatrix
% 3D array with switch number on both dimensions (row sender and column
% receiver)
% contains the shortest path routing for each combination of source and
% destination
global DijkstraRoutingMatrix;
DijkstraRoutingMatrix = zeros(MaxSwitchNumber,MaxSwitchNumber,MaxSwitchNumber);
[ DijkstraRoutingMatrix ] = dijkstra_routing_information( DijkstraRoutingMatrix );

% intra_switch tests to test routing


InputArbitStatus = zeros(SwitchTotal, MaxPortNumber);
OutputArbitStatus = zeros(SwitchTotal, MaxPortNumber);
PortArbitStatus = zeros(SwitchTotal, 1);
%VirtualArbitStatus = zeros(MaxSwitchNumber,MaxPortNumber);
VirtualArbitStatus = zeros(SwitchTotal,MaxPortNumber);

LinkArbitStatus = zeros(SwitchTotal, MaxPortNumber);
LinkStatus = zeros(SwitchTotal, SwitchTotal, MsgNumber);


MsgStatus = zeros(2,CurrentBufferDirection);
MsgStatus(1,Destination) = 4;
MsgStatus(1,Source) = 1;
MsgStatus(2,Destination) = 6;
MsgStatus(2,Source) = 34;
MsgStatus(2,CurrentBufferDirection) = -1;
% MsgStatus(1,FlitsLeft) = 0;
CoreBufferStatus = BufferDepth*ones(SwitchTotal,MaxNumberOfVC);
InputVCBufferStatus = zeros(SwitchTotal,MaxPortNumber, MaxNumberOfVC, NumberOfFreeFIFO);
InputVCBufferStatus( :, :, :, 5 ) = BufferDepth;
OutputVCBufferStatus = zeros(SwitchTotal,MaxPortNumber,MaxOutputVCNumber,FlitsPassedFromVCOutput);
OutputVCBufferStatus(:, :, :, 2) = OutputBufferDepth;
InputVCBufferStatus (1,1,2,MsgNumberInVC) = 1;
InputVCBufferStatus (1,1,2,NumberOfFreeFIFO) = 1;
InputVCBufferStatus (34,1,3,MsgNumberInVC) = 2;
InputVCBufferStatus (34,1,3,NumberOfFreeFIFO) = 2;
% InputVCBufferStatus (1,4,3,FlitsPassedFromVC) = 2;
% InputVCBufferStatus (1,4,3,NextPortNumber) = 3;
% InputVCBufferStatus (1,4,3,NextVCNumber) = 1;
% OutputVCBufferStatus(1,3,1,MsgNumberInVC) = 2;


for SimCycle = 1:10
    SimCycle
    %OutputVCBufferStatus
    [ InputVCBufferStatus, OutputVCBufferStatus, PortArbitStatus, CoreBufferStatus, VirtualArbitStatus ] = intra_switch_moves( InputVCBufferStatus, OutputVCBufferStatus, PortArbitStatus, MsgStatus, CoreBufferStatus, VirtualArbitStatus );
    %[ InputVCBufferStatus, OutputVCBufferStatus, LinkArbitStatus, LinkStatus ] = inter_switch_moves( SimCycle, InputVCBufferStatus, OutputVCBufferStatus, LinkArbitStatus, LinkStatus ); 

        %InputVCBufferStatus
        %OutputVCBufferStatus
end















