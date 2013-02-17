function [ hBar ] = hopCalc( DijkstraRoutingMatrix )
% calculates the average number of hops for the network, used in the
% simulated annealing process for the insertion of wireless nodes

global MaxCoreNumber

% average hop count calculation
hop=0;
hBar=0;

for SourceLink = 1:MaxCoreNumber
        for DestinationLink = 1:MaxCoreNumber
            if(SourceLink ~= DestinationLink)
             hop=hop+ nnz(DijkstraRoutingMatrix(SourceLink,DestinationLink,:));
            end
        end
end
 
hBar=hop/(MaxCoreNumber*(MaxCoreNumber-1));

end

