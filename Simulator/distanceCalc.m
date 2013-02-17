function [ distance ] = distanceCalc( SourceLink, DestinationLink )
% distanceCalc simply calculated the distance between two nodes in the
% network

% if type = 0, its just the distance between two nodes
% if type = 1, it calculated the distance of the total network, which is
% the variable hBAR used for simulated annealing

global MaxCoreNumber;
global LinkData;
global DijkstraRoutingMatrix;

distance = 0;

SourceIndex=1;
DestinationIndex=MaxCoreNumber+2;
NextDestinationIndex=1;


if(SourceLink == DestinationLink)
    
    distance = 0;
    
else
    
    while(DestinationIndex ~= DestinationLink)
        
        SourceIndex = DijkstraRoutingMatrix(SourceLink,DestinationLink,NextDestinationIndex);
        DestinationIndex = DijkstraRoutingMatrix(SourceLink,DestinationLink,(NextDestinationIndex+1));
        
        distance = distance + LinkData(SourceIndex,DestinationIndex,1);
        
        NextDestinationIndex=NextDestinationIndex+1;
        
    end
    
end
end

