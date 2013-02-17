function [ InputVCBufferStatus, OutputVCBufferStatus, LinkArbitStatus, LinkStatus, MsgStatus, WiNodes, WirelessPortArbitStatus ] = inter_switch_moves( SimCycle, InputVCBufferStatus, OutputVCBufferStatus, LinkArbitStatus, LinkStatus, MsgStatus, WiNodes, WirelessPortArbitStatus )
% This function processes inter-switch moves for all switches
%   An arbitration for access to actual physical channel is necessary as a
%   first step
% Naseef Mansoor on 11 Jan 2013 for systems with multiple token
% This change is made to generate multiple tokens in the system
% In this case we will have multiple WI's transmitting but no effective message is received. So their output
% buffer depth is updated but not the receiver input buffer depth.
% Config: EnabledWirelessDataTransmission=1 DoNotBlockToken=0
% GenerateMultipleToken=1. The cycle where token will be regeenrated is the
% TokenPassingBlockCycle.
global GenerateMultipleToken;
global DuplicateTokenGenerationCycle;
global DuplicateAlreadyGenerated;
%naseef mansoor end

%Naseef Mansoor
global TokenPassingBlockCycle;
global EnabledWirelessDataTransmission;
%naseef mansoor end
% global simulation parameters
global MsgLength; % Number of flits in messages
global MaxNumberOfVC; % maximum number of VCs in all ports
global MaxOutputVCNumber; % VC number of output ports
global MaxSwitchNumber; % maximum number of switches determined by topology
% global BufferDepth; % maximum depth of VC buffers
global OutputBufferDepth; % max depth of output VCs
% structure of PortNumber
% 1D array
% 1st dimension denoted by switch number
% contains the nuymber of ports for a particular switch, formed depending
% upon topology, can be globally defined
global PortNumber;
% structure of SBConnectivity
% 2D array with switch number on both dimensions (row sender and column
% receiver)
% contains the number of cycles needed by each link between switches,
% sending and receiving port numbers as well
% default 0 for no link

global SBConnectivity;

global Connectivity; % the array
global LinkCycle; % value = 1, contains number of cycles taken by link for flit traversal
global SendPort; % value = 2, contains the number of the port of sending switch
global RecvPort; % value = 3, contains number of the port of the receiving switch

% structure of LinkArbitStatus
% 2D array
% 1st dimension denoted by Switch Number
% 2nd dimension denoted by port number
% contains the number of the VC last served

% struture of InputVCBufferStatus
% 4D array
% 1st dimension denoted by switch number
% 2nd dimension denoted by port number of the switch
% 3rd dimension denoted by VC number
global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
% global FlitsPassedFromVC; % value = 2, contains the number of flits of MsgNumber passed from the VC
% global NextPortNumber; % value = 3,contains the next port number for the flit
global NextVCNumber; % value = 4, contains the next port's VC number for the flit
global NumberOfFreeFIFO; % value = 5, initialized to BufferDepth

% structure of OutputVCBufferStatus
% 4D array
% 1st dimension denoted by switch number
% 2nd dimension denoted by port number of the switch
% 3rd dimension denoted by VC number
% global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
global NumberOfFreeFIFOOutput; % value = 2, contains the number of free FIFOs in the output VC
global FlitsPassedFromVCOutput; % value = 3, contains the number of flits passed from this virtual channel (not needed in this function; needed for inter-move)
% global NextVCNumber; % value = 4, contains the next port's VC number for the flit

% structure of LinkStatus
% 3D array
% 1st dimension: sending switch number
% 2nd dimension: receiving switch number
global SendCycle; % value = 1; contains the cycle of the SimCycle lst flit was sent in
global RecvCycle; % value = 2; contains the cycle of SimCycle lst flit was received in on this link
global SourceVC; % value = 3; contains the VC number at source port/switch currently
global DestinationVC; % value = 4, contains teh destination VC number at destination port/switch
global MsgNumber; % value = 5, contains the msg number of the flit in transit



% Wade Campney
% also changed all Connectivity to SBConnectivity
% Modified all switch loops to be switches + buffers
%
% Changed MaxSwitchNumber to SwitchTotal

% added a variable to track if the header flit was successfully moved or if
% it stayed in the buffer for the cycle

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

global BufferDepth;

global MsgMoved;
global MsgNo;

global SwitchTotal;
global NumberWirelessNodes;

global DoNotBlockToken;

%Naseef Mansoor
% global MsgLength;
% global XDim;
% 
% for iMsgNo=1:size(MsgStatus,XDim)
%     MsgStatus(iMsgNo,SwitchCycles)=MsgStatus(iMsgNo,SwitchCycles)+(MsgLength-MsgStatus(iMsgNo,FlitsLeft));
% end
for iSwitch = 1:SwitchTotal
    for jPort = 1:PortNumber(iSwitch)
        NumberOfFlitsInVCForMsgiMsg=0;
        for kVC = 1:MaxNumberOfVC
            iMsgNo=OutputVCBufferStatus(iSwitch,jPort,kVC,MsgNumberInVC); 
            % determine the message number for the VC
            if(iMsgNo~=0)
                % Check this VC is not free or we have a valid iMsgNo
%                 if(OutputVCBufferStatus(iSwitch,jPort,kVC,NumberOfFreeFIFOOutput)==0)
%                      NumberOfFlitsInVCForMsgiMsg=BufferDepth;
%                 elseif(OutputVCBufferStatus(iSwitch,jPort,kVC,NumberOfFreeFIFOOutput)==BufferDepth)
% %                      NumberOfFlitsInVCForMsgiMsg=NumberOfFlitsInVCForMsgiMsg;
%                 else
                    NumberOfFlitsInVCForMsgiMsg=OutputBufferDepth-OutputVCBufferStatus(iSwitch,jPort,kVC,NumberOfFreeFIFOOutput);
                    %determine the Number Of Flits In KVC ForMsg number iMsg
%                 end
                MsgStatus(iMsgNo,SwitchCycles)=MsgStatus(iMsgNo,SwitchCycles)+NumberOfFlitsInVCForMsgiMsg;
                %update MsgStatus
            end
         end
    end
end
%naseef mansoor end

for iSwitch = 1:SwitchTotal,
    for jPort = 1:PortNumber(iSwitch),
        
        % beginning of receive side (only needs to put the flit in right VC
        PrevSwitch = 0;
        for jPrevSwitch = 1:1:SwitchTotal,
            if(SBConnectivity(jPrevSwitch,iSwitch,RecvPort) == jPort) % finding the switch number of previous switch
                PrevSwitch = jPrevSwitch;
                break; % jPrevSwitch contains the number of the receving switch for the current jPort
            end
        end
        % Naseef Mansoor on 11 Jan 2013 for systems with multiple token
        % PrevSwitch is the switch connected to this port
        % Check if PrevSwitch and iSwitch is wireless or not?
        % If both are wireless and GenerateDuplicateToken=1 then you should
        % not update input vc buffer status.
        SenderIsWireless=0;
        ReceiverWireless=0;
        for iWiNodes=1:NumberWirelessNodes
            if(WiNodes(iWiNodes,1)==PrevSwitch)
                SenderIsWireless=1;
            elseif(WiNodes(iWiNodes,1)==iSwitch)
                ReceiverWireless=1;
            else
            end
        end
        %naseef mansoor end
        % Naseef Mansoor on 11 Jan 2013 for systems with multiple token
        % added the following if condition only to check if ( both sender
        % and receiver is wireless and simcycle >duplicate token generation
        % cycle and generate multiple token == 1
        if(~(SenderIsWireless == 1 && ReceiverWireless == 1 && SimCycle > DuplicateTokenGenerationCycle && GenerateMultipleToken == 1))
        %naseef mansoor end     
            if PrevSwitch ~= 0
                if((LinkStatus(PrevSwitch,iSwitch,SendCycle) + SBConnectivity(PrevSwitch,iSwitch,LinkCycle) == SimCycle) && (LinkStatus(PrevSwitch,iSwitch,RecvCycle) == -1))% time to receive flit
                    % updating input buffer for receiving a flit
                    InputVCBufferStatus(iSwitch,jPort,LinkStatus(PrevSwitch,iSwitch,DestinationVC),MsgNumberInVC) = LinkStatus(PrevSwitch,iSwitch,MsgNumber);
                    InputVCBufferStatus(iSwitch,jPort,LinkStatus(PrevSwitch,iSwitch,DestinationVC),NumberOfFreeFIFO) = InputVCBufferStatus(iSwitch,jPort,LinkStatus(PrevSwitch,iSwitch,DestinationVC),NumberOfFreeFIFO) - 1;

                    LinkStatus(PrevSwitch,iSwitch,RecvCycle) = SimCycle;

                    % Set switch being sent to here?
                end
            end
        end
    end
end


for iSwitch = 1:SwitchTotal,
    for jPort = 1:PortNumber(iSwitch),
        
        WiToken = 0;
        foundWi = 0;
        numWi = 0;

        %Naseef Mansoor
        %WirelessData=0;
        %naseef mansoor end
        
        % 1. Find out if the iSwitch has a Wireless interface. if so then set
        % founfWi=1, numWi=index in WiNodes for iSwitch and if iSwitch also
        % have the token then set WiToken=1.
        % We set WiToken=1 if we found this Switch has a Wireless inteface
        % and have the token. foundWi=1 if sending node has wireless
        for i = 1:NumberWirelessNodes
            if(iSwitch == WiNodes(i,1))
                % Sending node has wireless
                foundWi = 1;
                numWi = i; %numWi is an index for the WiNodes structure

                if(WiNodes(numWi,3) == 1)% 3 contains the status of the token, if 1, then the switch has the token,
                    WiToken = 1;% Means selected node has the token so seting WiToken to 1.
                end
            end
        end
        
        % beginning of send side
        count = 0;
        % 2. Find a VC in for the port.
        LinkArbitStatus = link_arbitrate(iSwitch,jPort,LinkArbitStatus);%Pick a VC for the jPort
        % check until a non-empty arbited Output VC is found (both wired and woreless)
        while((OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),NumberOfFreeFIFOOutput) == OutputBufferDepth) && (count < MaxOutputVCNumber))
            LinkArbitStatus = link_arbitrate(iSwitch,jPort,LinkArbitStatus);
            count = count + 1;
        end
        % need to talk on this update
        % If this is Wireless port then current service VC is also the
        % next VC. Update the Selected VCnumber to prev VC.
        if(foundWi == 1) % Current node has WI
            if(jPort == WiNodes(numWi,2)) % if current switch port i.e jPort is the Wireless port or not
                LinkArbitStatus(iSwitch,jPort) = WiNodes(numWi,4);% WiNodes(numWi,4) is the VC being serviced, once empty, the token is passed ( or the  number of flits sent maybe, not sure what will be needed yet)

            end
        end

        % If VC have flits to send
        if(OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),NumberOfFreeFIFOOutput) < OutputBufferDepth) % arbited VC has a flit to send
            % check for free FIFO on input side and send
            NextSwitch = 0;
            for jNextSwitch = 1:1:SwitchTotal,
                if(SBConnectivity(iSwitch,jNextSwitch,SendPort) == jPort) % finding the switch number of next switch
                    NextSwitch = jNextSwitch;
                    %jPort
                    break; % iNextSwitch contains the number of the receving switch for the current jPort
                end
            end
            
            
            %NextSwitch
            % check if link is free
            if NextSwitch ~= 0
                
                transmit = 1;
                WifiTransmission = 0;
                foundWiR = 0;
                % Check if the receiver is also wireless
                for i = 1:NumberWirelessNodes
                    if(NextSwitch == WiNodes(i,1))
                        % Receiving node is wireless
                        foundWiR = 1;
                        
                        if(foundWi == 1 && WiToken == 1)
                            if(WiNodes(numWi,2) == 0)
                                WiNodes(numWi,5) = NextSwitch;
                                WiNodes(numWi,2) = jPort;
                                WiNodes(numWi,4) = LinkArbitStatus(iSwitch,jPort);
                                WifiTransmission = 1;
                            elseif(WiNodes(numWi,5) == NextSwitch)
                                WifiTransmission = 1;
                                LinkArbitStatus(iSwitch,jPort) = WiNodes(numWi,4);
                            else
                                transmit = 0;
                            end
                        end
                    end
                end
                
                % check for no token wireless transmission attempts and
                % set transmit = 0
                
                if(foundWi == 1 && foundWiR == 1 && WiToken == 0)
                    %one = WiNodes(numWi,1)
                    %two = WiNodes(numWiR,1)
                    transmit = 0;
                    %WiNodes(numWi,9) = WiNodes(numWi,9) + 1;
                end
                
                %Naseef Mansoor
                
                if(WifiTransmission==1 && EnabledWirelessDataTransmission==0 && SimCycle >TokenPassingBlockCycle )
                    transmit=0;
                end
                
                %naseef mansoor end
                if(transmit == 1)
                    
                    if((((LinkStatus(iSwitch,NextSwitch,SendCycle) + SBConnectivity(iSwitch,NextSwitch,LinkCycle) -1) < SimCycle) && (LinkStatus(iSwitch,NextSwitch,RecvCycle) ~= -1)) || (LinkStatus(iSwitch,NextSwitch,SendCycle) == 0))% LinkCycle has passed after SendCycle => free
                        % check if header flit needs to be passed
                        
                        if(OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),FlitsPassedFromVCOutput) == 0) % header needs to be passed
                            
                            MsgMoved = 0;
                            
                            for jNextVC = 1:MaxNumberOfVC, % looking for empty VC on input port of next switch
                                %iSwitch
                                if(InputVCBufferStatus(NextSwitch,SBConnectivity(iSwitch,NextSwitch,RecvPort),jNextVC,MsgNumberInVC) == 0) % empty VC
                                    % update sending status for this VC
                                    OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),NumberOfFreeFIFOOutput) = OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),NumberOfFreeFIFOOutput) + 1;
                                    OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),FlitsPassedFromVCOutput) = OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),FlitsPassedFromVCOutput) +1;
                                    OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),NextVCNumber) = jNextVC;
                                    LinkStatus(iSwitch,NextSwitch,SendCycle) = SimCycle;
                                    LinkStatus(iSwitch,NextSwitch,DestinationVC) = jNextVC;
                                    LinkStatus(iSwitch,NextSwitch,SourceVC) = LinkArbitStatus(iSwitch,jPort);
                                    LinkStatus(iSwitch,NextSwitch,MsgNumber) = OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),MsgNumberInVC);
                                    LinkStatus(iSwitch,NextSwitch,RecvCycle) = -1;
                                    MsgMoved = 1;
                                    %Naseef Mansoor
                                    MsgNo = OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),MsgNumberInVC);
                                    MsgStatus(MsgNo,SwitchCycles) = MsgStatus(MsgNo,SwitchCycles) -1;
                                    %naseef mansoor end
                                    if(WifiTransmission == 1)
                                        WiNodes(numWi,6) =  WiNodes(numWi,6) + 1;
                                        WiNodes(numWi,7) =  WiNodes(numWi,7) + 1;
                                        %WiNodes(numWi,:)
                                    end
                                    
                                    break;
                                end
                            end
                            
%                             if(MsgMoved == 0)
%                                 
%                                 MsgNo = OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),MsgNumberInVC);
%                                 
%                                 if(iSwitch <= MaxSwitchNumber)
%                                     
%                                     MsgStatus(MsgNo,SwitchCycles) = MsgStatus(MsgNo,SwitchCycles) + 1;
%                                     
%                                 else
%                                     
%                                     MsgStatus(MsgNo,SwitchCycles) = MsgStatus(MsgNo,BufferCycles) + 1;
%                                     
%                                 end
%                                 
%                             end
                            
                        else
                            % body flit to send: needs to check for free space in VC
                            
                            MsgMoved = 0;
                            
                            if(InputVCBufferStatus(NextSwitch,SBConnectivity(iSwitch,NextSwitch,RecvPort),OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),NextVCNumber),NumberOfFreeFIFO) > 0) % there is free space in the VC of the next input port
                                % update sending status for body flit
                                
                                OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),NumberOfFreeFIFOOutput) = OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),NumberOfFreeFIFOOutput) + 1;
                                OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),FlitsPassedFromVCOutput) = OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),FlitsPassedFromVCOutput) +1;
                                LinkStatus(iSwitch,NextSwitch,SendCycle) = SimCycle;
                                LinkStatus(iSwitch,NextSwitch,DestinationVC) = OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),NextVCNumber);
                                LinkStatus(iSwitch,NextSwitch,SourceVC) = LinkArbitStatus(iSwitch,jPort);
                                LinkStatus(iSwitch,NextSwitch,MsgNumber) = OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),MsgNumberInVC);
                                LinkStatus(iSwitch,NextSwitch,RecvCycle) = -1;
                                MsgMoved = 1;
                                %Naseef Mansoor
                                MsgNo = OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),MsgNumberInVC);
                                MsgStatus(MsgNo,SwitchCycles) = MsgStatus(MsgNo,SwitchCycles) -1;
                                %naseef mansoor end
                                if(WifiTransmission == 1)
                                    WiNodes(numWi,6) =  WiNodes(numWi,6) + 1;
                                    WiNodes(numWi,7) =  WiNodes(numWi,7) + 1;
                                    %WiNodes(numWi,:)
                                end
                                
                                if(OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),FlitsPassedFromVCOutput) == MsgLength) % checking if tail flit just passed
                                    OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),MsgNumberInVC) = 0;
                                    OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),FlitsPassedFromVCOutput) = 0;
                                    OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),NumberOfFreeFIFOOutput) = OutputBufferDepth;
                                    OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),NextVCNumber) = 0; % freeing up VC after tail flit
                                end
                            else
                                
%                                 if(MsgMoved == 0)
%                                     
%                                     MsgNo = OutputVCBufferStatus(iSwitch,jPort,LinkArbitStatus(iSwitch,jPort),MsgNumberInVC);
%                                     
%                                     if(iSwitch <= MaxSwitchNumber)
%                                         
%                                         MsgStatus(MsgNo,SwitchCycles) = MsgStatus(MsgNo,SwitchCycles) + 1;
%                                         
%                                     else
%                                         
%                                         MsgStatus(MsgNo,BufferCycles) = MsgStatus(MsgNo,BufferCycles) + 1;
%                                         
%                                     end
%                                     
%                                 end
                                
                            end
                        end
                    end
                end
            end
        end
    end
end

% comment out token passing if running without wireless nodes
%Code segment to Pass the token
for i = 1:NumberWirelessNodes
    % WiNodes(i,3)==1 means the winode has the token
    if(WiNodes(i,3) == 1)
        
        CurSwitch = WiNodes(i,1);
        CurPort = WiNodes(i,2);
        
        % Increment the number of cycles this switch has had the token
        WiNodes(i,8) = WiNodes(i,8) + 1;
        pass = 0;
        
        if(WiNodes(i,8) == MsgLength + 1)
        %if(WiNodes(i,8) == 3)
            % Has had token for too many cycles, time to pass
            pass = 1;
        end
        
        if(WiNodes(i,2) ~= 0)
            if(OutputVCBufferStatus(CurSwitch,CurPort,LinkArbitStatus(CurSwitch,CurPort),NumberOfFreeFIFOOutput) == OutputBufferDepth)
                % Empty VC, time to pass token
                pass = 1;
            end
        end
        
        % Break token after 130 cycles
        %if(SimCycle < TokenPassingBlockCycle)

        if(pass == 1)
             % Pass token, clear switch and VC data
            disp('Node:');
            i
            disp('Trying to pass the token');
            WiNodes
            WiNodes(i,2) = 0;
            WiNodes(i,3) = 0;
            WiNodes(i,4) = 0;
            WiNodes(i,5) = 0;
            WiNodes(i,6) = 0;
            WiNodes(i,8) = 0;

            successful = 0;
            count = i;
            count2 = 0;
            % if statement to disable the token from being passed to a
            % different switch

            if(SimCycle < TokenPassingBlockCycle || DoNotBlockToken == 1)
                   
                if(count == NumberWirelessNodes)                 
                    nextSwitch = WiNodes(1,1);
                else
                    nextSwitch = WiNodes(i + 1,1);
                end
            else
               nextSwitch = CurSwitch; 
            end

            while(successful == 0 && count2 < NumberWirelessNodes)
                %[ WirelessPortArbitStatus, successful ] = port_arbitrate_wireless( CurSwitch, WirelessPortArbitStatus, OutputVCBufferStatus );
                [ WirelessPortArbitStatus, WiNodes, successful ] = port_arbitrate_wireless( nextSwitch, WirelessPortArbitStatus, WiNodes, OutputVCBufferStatus );

                % Pass the token (round robin)
                if(count == NumberWirelessNodes)
                    count = 1;
                else
                    count = count + 1;
                end

                % if statement to disable the token from being passed to a
                % different switch

                if(SimCycle < TokenPassingBlockCycle || DoNotBlockToken == 1)
                    nextSwitch = WiNodes(count,1);
                else
                   nextSwitch = CurSwitch;  
                end

                count2 = count2 + 1;
            end
            if(successful == 0)
                WiNodes(i,3)=1;
            end
            break;
        end
        %end
    end
end

% Naseef Mansoor on 11 Jan 2013 for systems with multiple token
% This is where we generate multiple tokens
if(SimCycle==DuplicateTokenGenerationCycle && GenerateMultipleToken==1) %&& DuplicateAlreadyGenerated==1)
    for j=1:NumberWirelessNodes
        %WiNodes(x,3) this is the set to 1 if it has the token
        if(WiNodes(j,3)==1)
           NodeCurrentlyHaveToken=j; 
        end
    end
    NodeHavingDulpicateToken=randi(NumberWirelessNodes);
    DoneFinding=0;
    while(DoneFinding==0)
        if(NodeHavingDulpicateToken==NodeCurrentlyHaveToken)
            %do nothing
            NodeHavingDulpicateToken=randi(NumberWirelessNodes);
        else
            % 
            DoneFinding=1;
            WiNodes(NodeHavingDulpicateToken,3)= 1 ;
            break;
        end
    end
    disp('********************************************************');
    disp('DupTokenNode');
    NodeHavingDulpicateToken
    disp('SimCycle');
    SimCycle
    disp('************************WINODES************************');
    WiNodes
    disp('********************************************************');
end
% naseef mansoor end

end


