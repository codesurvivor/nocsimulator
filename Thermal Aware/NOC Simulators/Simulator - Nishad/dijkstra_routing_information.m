function  [ DijkstraRoutingMatrix ] = dijkstra_routing_information( DijkstraRoutingMatrix )

% Global Simulation numbers

global MaxSwitchNumber; % maximum number of switches determined by topology

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

% structure of DijkstraRoutingMatrix
% 3D array with switch number on both dimensions (row sender and column
% receiver)
% contains the shortest path routing for each combination of source and
% destination


for DijkstraSource = 1:MaxSwitchNumber
    
    % initialization
    Q = ones(1,MaxSwitchNumber);
    for v = 1:MaxSwitchNumber 
        Distance(v) = 1000000000;
        Previous(v) = 0;
    end
    Distance(DijkstraSource) = 0; % distance from source to source
    
    while sum(Q) ~=0
        MinDistance = 10000000000;
        for i = 1:MaxSwitchNumber
            if (Q(i) == 1) && ( Distance(i) < MinDistance )
                MinDistance = Distance(i);
                u = i; % vertex in Q with smallest distance
            end
        end

        Q(u) = 0; % remove u from Q
        for v = 1:MaxSwitchNumber
            if ( Connectivity(u,v,LinkCycle) ~= -1 ) && (Q(v) == 1) % for each neighbour v of u, where v has not yet been removed from Q
                alt = Distance(u) + Connectivity(u,v,LinkCycle);
                if alt < Distance(v)
                    Distance(v) = alt;
                    Previous(v) = u;
                end
            end
        end
    end


    for DijkstraDestination = 1:MaxSwitchNumber 
        if DijkstraDestination ~= DijkstraSource
            Current = DijkstraDestination;
            ReverseRouting = [ DijkstraDestination ];
            for i = 1:MaxSwitchNumber
                if Current ~= DijkstraSource
                    ReverseRouting = [ ReverseRouting Previous(Current) ];
                    Current = Previous(Current);
                else 
                    break;
                end
            end
            Number = size(ReverseRouting,2);
            ReverseNumber = Number;
            for i = 1:Number
                DijkstraRoutingMatrix(DijkstraSource,DijkstraDestination,i) = ReverseRouting(ReverseNumber);
                ReverseNumber = ReverseNumber - 1;
            end
        end
    end
end           
                
            
    