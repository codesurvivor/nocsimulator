function [ RetNextPort, MsgStatus ] = routing( CurrentSwitch, ijMsgNumber, MsgStatus )
% This function routes a header from input port of current switch to output
% port

% global simulation parameters
global RoutingType; % value denotes type of routing adopted
global Mesh; % routing type of Mesh
global DijkstraRouting;
% global Mesh3D % routing type of 3D Mesh
global XDim; % 1
global YDim; % 2
% global ZDim; % 3
global TrainRouting;
global CorePort; % value = 1, number of the port connected to the core in a switch
global MaxSwitchNumber; % maximum number of switches determined by topology
global DijkstraRoutingMatrix;

% Naseef Mansoor
global DijkstraRoutingMatrixWired;
global DijkstraRoutingMatrixWireless;
global MsgRoutingScheme;
% naseef mansoor end

% structure of Connectivity
% 2D array with switch number on both dimensions (row sender and column
% receiver)
% contains the number of cycles needed by each link between switches,
% sending and receiving port numbers as well
% default 0 for no link
global Connectivity;
% global LinkCycle; % value = 1, contains number of cycles taken by link for flit traversal
global SendPort; % value = 2, contaons the number of the port of sending switch
% global RecvPort; % value = 3, contains number of the port of the receiving switch

% Structure of TileDimension
% vector of x,y,z,.. dimensions
% contains the number of tiles/cores in each direction
global TileDimension;

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


global SubTreeLabel;
global SwitchLevel;

% Wade Campney 
% global variables

global SwitchConn;
global SBConnectivity;
global LinkData;
global SwitchTotal;

if(RoutingType == Mesh) % dimension order routing; Y-X
    
    X = TileDimension(XDim);
    Y = TileDimension(YDim);
    
    % Wade Campney
    % Modified to route to the intermediate buffers if they exist between
    % the current switch and the destination switch
    
    yCurrent = ceil(CurrentSwitch/X);
    yDestination = ceil(MsgStatus(ijMsgNumber,Destination)/X);
    xRetNextSwitch = mod(CurrentSwitch, X);
    if xRetNextSwitch == 0
        xRetNextSwitch = X;
    end;
    % Check and do Y routing first
    if(yCurrent > yDestination)
        yRetNextSwitch = yCurrent - 1;
    else
        if(yCurrent < yDestination)
            yRetNextSwitch = yCurrent + 1;
        else
            % start X routing
            yRetNextSwitch = yCurrent;
            xCurrent = mod(CurrentSwitch, X);
            if xCurrent == 0
                xCurrent = X;
            end;
            xDestination = mod(MsgStatus(ijMsgNumber,Destination),X);
            if xDestination == 0
                xDestination = X;
            end;
            if(xCurrent > xDestination)
                xRetNextSwitch = xCurrent - 1;
            else
                if(xCurrent < xDestination)
                    xRetNextSwitch = xCurrent + 1;
                else
                    xRetNextSwitch = xCurrent;
                end
            end
        end
        
        RetNextSwitch = X*(yRetNextSwitch - 1) + xRetNextSwitch;
        
        
        if(RetNextSwitch ~= CurrentSwitch)
            % not in the destination switch
            RetNextPort = Connectivity(CurrentSwitch,RetNextSwitch,SendPort);
            
        else
            RetNextPort = CorePort; % port connected to core
        end
    end
    
    
end % end Mesh routing


% if(RoutingType == Mesh3D) % dimension order routing; Z-Y-X
%     X = TileDimension(XDim);
%     Y = TileDimension(YDim);
%     Z = TileDimension(ZDim);
%     zCurrent = 1+mod(CurrentSwitch, X*Y);
%     zDestination = 1+mod(MsgStatus(ijMsgNumber,Destination),X*Y);
%     if(zCurrent > zDestination)
%         if()
%         end
%     end
% end


if (RoutingType == TrainRouting)
    DestinationSwitch = MsgStatus(ijMsgNumber,Destination);
    % finding LCA of DestinationSwitch w.r.t CurrentSwitch
    for i = 1:MaxSwitchNumber
        if SubTreeLabel(CurrentSwitch,i) == SubTreeLabel(DestinationSwitch,i)
            LcaDestinationLabel(i) = SubTreeLabel(CurrentSwitch,i);
        else
            for j = i:MaxSwitchNumber
                LcaDestinationLabel(j) = 0;
            end
            break;
        end
    end
    % finding the LcaDestination switch number
    for p = 1:MaxSwitchNumber
        count = 0;
        for q = 1:MaxSwitchNumber
            if SubTreeLabel(p,q) == LcaDestinationLabel(q)
                count = count + 1;
            end
        end
        if count == MaxSwitchNumber
            LcaDestinationSwitch = p;
            break;
        end
    end
    
    TreeCycles = (SwitchLevel(CurrentSwitch) - SwitchLevel(LcaDestinationSwitch)) + (SwitchLevel(DestinationSwitch) - SwitchLevel(LcaDestinationSwitch));
    
    if CurrentSwitch ~= DestinationSwitch
        if SwitchLevel(LcaDestinationSwitch) == SwitchLevel(CurrentSwitch) % go to next downward switch
            NextSwitchLabel(1:(SwitchLevel(CurrentSwitch)+1)) = SubTreeLabel(DestinationSwitch,1:(SwitchLevel(CurrentSwitch)+1));
            for n = (SwitchLevel(CurrentSwitch)+2):MaxSwitchNumber
                NextSwitchLabel(n) = 0;
            end
            % finding the next switch number
            for p = 1:MaxSwitchNumber
                count = 0;
                for q = 1:MaxSwitchNumber
                    if SubTreeLabel(p,q) == NextSwitchLabel(q)
                        count = count + 1;
                    end
                end
                if count == MaxSwitchNumber
                    NextSwitch = p;
                    break;
                end
            end
        else % go to next upward switch or take shortcut
            
          % finding the minimum distance shortcut
          MinumumShortcutCycles = 1000000000000000000;  
          MinumumShortcutSwitch = 0;
            for k = 1:MaxSwitchNumber
                if (Connectivity(CurrentSwitch,k,1) ~= 0) && (Connectivity(CurrentSwitch,k,1) ~= 1)
                    ShortcutSwitch = k;

                    % finding LCA of ShortcutSwitch w.r.t DestinationSwitch 
                    for i = 1:MaxSwitchNumber
                        if SubTreeLabel(ShortcutSwitch,i) == SubTreeLabel(DestinationSwitch,i)
                            LcaShortcutLabel(i) = SubTreeLabel(ShortcutSwitch,i);
                        else
                            for j = i:MaxSwitchNumber
                                LcaShortcutLabel(j) = 0;
                            end
                            break;
                        end
                    end
                    % finding the LcaShortcut switch number
                    for p = 1:MaxSwitchNumber
                        count = 0;
                        for q = 1:MaxSwitchNumber
                            if SubTreeLabel(p,q) == LcaShortcutLabel(q)
                                count = count + 1;
                            end
                        end
                        if count == MaxSwitchNumber
                            LcaShortcutSwitch = p;
                            break;
                        end
                    end
                    ShortcutCycles = (SwitchLevel(ShortcutSwitch) - SwitchLevel(LcaShortcutSwitch)) + (SwitchLevel(DestinationSwitch) - SwitchLevel(LcaShortcutSwitch)) + Connectivity(CurrentSwitch,ShortcutSwitch,1);
                    if ShortcutCycles < MinumumShortcutCycles
                        MinumumShortcutCycles = ShortcutCycles;
                        MinumumShortcutSwitch = ShortcutSwitch;
                    end
                end
            end
            
             % 
            if (MinumumShortcutCycles < TreeCycles + Threshold) && (MinumumShortcutSwitch ~= 0)
                % take shortcut
                NextSwitch = MinumumShortcutSwitch;
            else
                % go upwards along the tree
                NextSwitchLabel(1:(SwitchLevel(CurrentSwitch)-1)) = SubTreeLabel(CurrentSwitch,1:(SwitchLevel(CurrentSwitch)-1));
                for n = (SwitchLevel(CurrentSwitch)):MaxSwitchNumber
                    NextSwitchLabel(n) = 0;
                end
                % finding the next switch number
                for p = 1:MaxSwitchNumber
                    count = 0;
                    for q = 1:MaxSwitchNumber
                        if SubTreeLabel(p,q) == NextSwitchLabel(q)
                            count = count + 1;
                        end
                    end
                    if count == MaxSwitchNumber
                        NextSwitch = p;
                        break;
                    end
                end
            end
        end
    else
        NextSwitch = CurrentSwitch;
    end

    if(NextSwitch ~= CurrentSwitch)
        % not in the destination switch
        
        RetNextPort = Connectivity(CurrentSwitch,NextSwitch,SendPort);
    else
        RetNextPort = CorePort; % port connected to core
    end
end






if ( RoutingType == DijkstraRouting )
    
    % Wade Campney
    % Modified to route to the intermediate buffers if they exist between
    % the current switch and the destination switch
    
    if(CurrentSwitch <= MaxSwitchNumber)
        % Not currently at a buffer
        
        for i = 1:MaxSwitchNumber
            
            %Naseef Mansoor
            % update the DijkstraRoutingMatrix as per the MsgRoutingScheme
            if(MsgRoutingScheme(ijMsgNumber , 2) == 1)
                DijkstraRoutingMatrix=DijkstraRoutingMatrixWired;
            else
                DijkstraRoutingMatrix=DijkstraRoutingMatrixWireless;
            end
            % naseef mansoor end
            
            if (CurrentSwitch == DijkstraRoutingMatrix( MsgStatus(ijMsgNumber,Source),MsgStatus(ijMsgNumber,Destination),i)) && (CurrentSwitch ~= MsgStatus(ijMsgNumber,Destination))
                
                NextSwitch = DijkstraRoutingMatrix( MsgStatus(ijMsgNumber,Source),MsgStatus(ijMsgNumber,Destination),i+1);
                
                % Set the Current Buffer Direction
                % 1 = increasing
                % -1 = decreasing
                
                if(CurrentSwitch < NextSwitch)
                    MsgStatus(ijMsgNumber,CurrentBufferDirection) = 1;
                elseif(CurrentSwitch > NextSwitch)
                    MsgStatus(ijMsgNumber,CurrentBufferDirection) = -1;
                end
            end
            
            if CurrentSwitch == MsgStatus(ijMsgNumber,Destination)
                NextSwitch = CurrentSwitch;
            end
            
            
        end

        if(NextSwitch ~= CurrentSwitch)
            % not in the destination switch
            RetNextPort = Connectivity(CurrentSwitch,NextSwitch,SendPort);
        else
            RetNextPort = CorePort; % port connected to core
        end
        
    else
        % Currently at a buffer
        
        if(CurrentSwitch == SwitchTotal)
            % at the last buffer
            tempPort = 0;
        else
            % Check to see if there is another buffer on the link
            % Currently only works in positive direction, not sure how to
            % tell which direction the message is going
            
            
            if(MsgStatus(ijMsgNumber,CurrentBufferDirection) == 1)
                
                tempPort = SBConnectivity(CurrentSwitch,CurrentSwitch + 1,2);
                
            elseif(MsgStatus(ijMsgNumber,CurrentBufferDirection) == -1)
                
                tempPort = SBConnectivity(CurrentSwitch,CurrentSwitch - 1,2);
                
            else
                tempPort = 0;
                
            end
            
        end
        
        if(tempPort ~= 0)
            % Next jump is to the next buffer in line
            
            if(MsgStatus(ijMsgNumber,CurrentBufferDirection) == 1)
                
                NextSwitch = CurrentSwitch + 1;
                
            elseif(MsgStatus(ijMsgNumber,CurrentBufferDirection) == -1)
                
                NextSwitch = CurrentSwitch - 1;
                
            else
            end
            
            
        else
            % No more buffers on the current link, next switch is the
            % actual switch
            
            TempSwitch = SwitchConn(CurrentSwitch,1);
            
            if(TempSwitch == -1)
                
                if(MsgStatus(ijMsgNumber,CurrentBufferDirection) == 1)
                    
                    NextSwitch = SwitchConn(CurrentSwitch,3);
                    
                elseif(MsgStatus(ijMsgNumber,CurrentBufferDirection) == -1)
                    
                    NextSwitch = SwitchConn(CurrentSwitch,2);
                    
                else

                end
            else
                
                NextSwitch = TempSwitch;
                
            end
        end
        
        
        RetNextPort = SBConnectivity(CurrentSwitch,NextSwitch,2);
        
        % Set the Current Buffer Direction
        % 1 = increasing
        % -1 = decreasing
        
        if(CurrentSwitch < NextSwitch)
            MsgStatus(ijMsgNumber,CurrentBufferDirection) = 1;
        else
            MsgStatus(ijMsgNumber,CurrentBufferDirection) = -1;
        end
        
    end
    
end

