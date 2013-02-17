function [ both_node_is_wireless ] = check_wireless( iNode1, iNode2 )
%checks if the input nodes are both wireless or not. If both are wireless
%returns 1 else 0
global WiNodes;
% New data structure for information pertaining to wireless nodes/token
% Structure of WiNodes

% 1 contains the switches that have wireless
% 2 is the port of the switch that is wireless
% 3 contains the status of the token, if 1, then the switch has the token,
% only one switch can have it at a time
% 4 is the VC being serviced, once empty, the token is passed ( or the
% number of flits sent maybe, not sure what will be needed yet)
% 5 is the node currently being sent to if it has the token
% 6 is the number of flits sent this token possession
% 7 is the total number of flits sent wirelessly
% 8 is the number of cycles the switch has had the token

% added 9-10 for servicing all VCs on all ports before passing the token

% 9 is the number of ports served this token possession
% 10 is the number of VCs served this token possession

global NumberWirelessNodes;

both_node_is_wireless=0;
Node1Wireless = 0;
Node2Wireless = 0;

for iWiNodes=1:NumberWirelessNodes
     if(iNode1==WiNodes(iWiNodes,1))
         Node1Wireless=1;
     end
     if(iNode2==WiNodes(iWiNodes,1))
          Node2Wireless=1;
     end     
end
if(Node1Wireless==1&&Node2Wireless==1)% detected a wireless communication
     both_node_is_wireless=1;
end
end

