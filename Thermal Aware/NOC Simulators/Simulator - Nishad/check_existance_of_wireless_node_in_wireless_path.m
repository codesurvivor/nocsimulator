function [ NodeExists ] = check_existance_of_wireless_node_in_wireless_path( iMsgNo, NodeToSearch, MsgStatus)
% Check if a wireless node exists in
% the wireless path and performing a wireless communication. It is assumed that the Msg already has a wireless path
% from source to destination. This method returns 1 if the node
% we are searching for exists and it is doing a wireless communication
% with some other wireless node in the path

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

NodeExists=0;

if(NodeToSearch==MsgStatus(iMsgNo,Source))
    FollowingNode=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),2);
    if(check_wireless(NodeToSearch,FollowingNode)==1)
        NodeExists=1;
    end
else
    %search for the node till the end
    CurrentIndex=1;
    CurrentNode=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),CurrentIndex);
    while(CurrentNode~=MsgStatus(iMsgNo,Destination))
        if(CurrentNode==NodeToSearch)
            NodeExists=1;
            break;
        end
        CurrentIndex=CurrentIndex+1;
        CurrentNode=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),CurrentIndex);

    end
    if(NodeExists==1)% node found in between
        FollowingNode=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),CurrentIndex+1);
        PreviousNode=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),CurrentIndex-1);
        if(check_wireless(NodeToSearch,FollowingNode)==1)
            NodeExists=1;
        elseif(check_wireless(NodeToSearch,PreviousNode)==1)
            NodeExists=1;
        else
            NodeExists=0;% remove false occurance
        end
    end
    if(CurrentNode==MsgStatus(iMsgNo,Destination)&&CurrentNode==NodeToSearch)% so the previous loop ended at destination and donot found the node we are looking for
     % if the last node is the node we are searching for then check if previous node was wireless or not
            PreviousNode=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),CurrentIndex-1);
            if(check_wireless(CurrentNode,PreviousNode)==1)
                NodeExists=1;
            else
                NodeExists=0;
            end
    
    end
end

% if (NodeExists==1) 
%     if(NodeToSearch==MsgStatus(iMsgNo,Source))
%         FollowingNode=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),2);
%         if(check_wireless(NodeToSearch,FollowingNode)==1)
%             NodeExists=1;
%         else
%             NodeExists=0;
%         end
%     elseif(NodeToSearch==MsgStatus(iMsgNo,Destination))
%    % Need to fill this part only
%     while()
%         CurrentNode=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),CurrentIndex);
%     end
%     else
%         FollowingNode=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),CurrentIndex+1);
%         PreviousNode=DijkstraRoutingMatrixWireless(MsgStatus(iMsgNo,Source),MsgStatus(iMsgNo,Destination),CurrentIndex-1);
%         if(check_wireless(NodeToSearch,FollowingNode)==1)
%             NodeExists=1;
%         elseif(check_wireless(NodeToSearch,PreviousNode)==1)
%             NodeExists=1;
%         else
%             NodeExists=0;% remove false occurance
%         end
%     end 
% end
end

