%% test2 - testing link buffers

clc;
clear;

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

LinkData = zeros(MaxSwitchNumber,MaxSwitchNumber,3);

% structure of ConnLink
% 3D array with switch number on both dimensions (row sender and column
% receiver)

global SendBuff; % value = 1; contains the number of the port of the sending buffer
SendBuff = 1;
global RecvBuff; % value = 2; 
RecvBuff = 2;

global ConnLink;


% Structure of SwitchConn
% 1st dimension contains the buffer number

global SwitchRecvPort; % value = 1; contains the number of the port of the receiving switch
SwitchRecvPort = 1;
global BuffSendPort;  % value = 2; contains the number of the port the buffer sends out of
BuffSendPort = 2;
global BufferSwitch;  % value = 3; contains the number of the switch the buffer sends to
BufferSwitch = 3;

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
CurrentBuff = MaxSwitchNumber + 1;

% initialization of SwitchConn and ConnLink after the total number of
% buffers on the links was calculated

SwitchConn = zeros(TotalLinkBuffers,2);
ConnLink = zeros(TotalLinkBuffers,TotalLinkBuffers,1);

% Populate LinkData(:,:,3) with the next jumps 

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

% Populate ConnLink with the sending and receiving ports for the buffers


for i=1:MaxSwitchNumber
    
    for j=i:MaxSwitchNumber
        temp = LinkData(i,j,3);
        if(temp > 0)
            % Switch i sends to buffer temp on port 2
            ConnLink(i,temp,1) = Connectivity(i,j,2);
            ConnLink(temp,i,1) = 2;
            while(temp < LinkData(j,i,3))
                % temp sends to the next buffer on 3 and receives on 2
                ConnLink(temp,temp+1,1) = 3;
                %ConnLink(temp,temp+1,2) = 2;
                
                ConnLink(temp+1,temp,1) = 2;
                %ConnLink(temp+1,temp,2) = 3;
                temp = temp + 1;
            end
            
         ConnLink(temp,j,1) = 3;
         ConnLink(j,temp,1) = Connectivity(j,i,2);
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
            else
                SwitchConn(tempSend1,1) = Connectivity(i,j,2);           
                SwitchConn(tempSend1,2) = 2;
                
                SwitchConn(tempSend2,1) = Connectivity(j,i,2);
                SwitchConn(tempSend2,2) = 3;
            end
        end
    end
end


% structure of PortNumber
% 1D array
% 1st dimension denoted by switch number
% contains the nummber of ports for a particular switch, formed depending
% upon topology, can be globally defined


for i = 1:MaxSwitchNumber + TotalLinkBuffers
    
    if(i > MaxSwitchNumber)
        count = 3;
    else
        count = 1;
        for j = 1:MaxSwitchNumber
            if Connectivity(i,j,LinkCycle) ~= -1
                count = count + 1;
            end
        end
    end
    
    PortNumber(i) = count;

end

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


InputArbitStatus = zeros(MaxSwitchNumber, 3);
OutputArbitStatus = zeros(MaxSwitchNumber, 3);
PortArbitStatus = zeros(MaxSwitchNumber, 1);
%VirtualArbitStatus = zeros(MaxSwitchNumber,MaxPortNumber);
VirtualArbitStatus = zeros(MaxSwitchNumber,5);


MsgStatus = zeros(2,Destination);
MsgStatus(1,Destination) = 3;
MsgStatus(1,Source) = 1;
MsgStatus(2,Destination) = 3;
MsgStatus(2,Source) = 4;
% MsgStatus(1,FlitsLeft) = 0;
CoreBufferStatus = BufferDepth*ones(MaxSwitchNumber,MaxNumberOfVC);
InputVCBufferStatus = zeros(MaxSwitchNumber + TotalLinkBuffers,5, MaxNumberOfVC, NumberOfFreeFIFO);
InputVCBufferStatus( :, :, :, 5 ) = BufferDepth;
OutputVCBufferStatus = zeros(MaxSwitchNumber + TotalLinkBuffers,5,MaxOutputVCNumber,FlitsPassedFromVCOutput);
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
      
    %InputVCBufferStatus
    %OutputVCBufferStatus
end















