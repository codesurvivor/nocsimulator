function [ HasWirelessInPath ] = check_wireless_communication_for_message(iMsgNo, MsgStatus)
% This function checks if for a Msg there is a wireless path from source to
% destination. If there is a wireless communication returns 1 else 0

global DijkstraRoutingMatrixWireless;
% structure of DijkstraRoutingMatrix
% 3D array with switch number on both dimensions (row sender and column
% receiver)
% contains the shortest path routing for each combination of source and
% destination

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

CurrentIndex=1;
HasWirelessInPath=0;

Node1=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),CurrentIndex);
Node2=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),CurrentIndex+1);

if(Node2==MsgStatus(iMsgNo,Destination))
    HasWirelessInPath=check_wireless(Node1,Node2);
else
%     PathSize=size(DijkstraRoutingMatrixWireless,3);
     while(Node2~=MsgStatus(iMsgNo,Destination)) % && CurrentIndex<PathSize )
        HasWirelessInPath=check_wireless(Node1,Node2);
        if(HasWirelessInPath==1)% detected a wireless communication
            break;
        end
        CurrentIndex=CurrentIndex+1;
        Node1=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),CurrentIndex);
        Node2=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),CurrentIndex+1);
    end
    if(Node2==MsgStatus(iMsgNo,Destination))
         HasWirelessInPath=check_wireless(Node1,Node2);
    end
end
end

