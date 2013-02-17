%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : Nishad Nerurkar
% Date   : 10/26/2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note --
% Function takes inputs -
% n = number of nodes
% s = source node
% netCostMatrix = connectivity matrix of the nodes.
% nodes connected have the cost, nodes not connected have inf as metric
% distance of nodes with themselves is 0.
% function returns the distance matrix with distance of source node with
% every other node.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [distance,parent] = dijkstra(n,s,netCostMatrix)
    visited(1:n) = 0;
    distance(1:n) = inf;
    parent(1:n) = 0;
    distance(s) = 0;
    for i = 1:(n)
        temp = [];
        for h = 1:n,
             if visited(h) == 0
                 temp=[temp distance(h)];
             else
                 temp=[temp inf];
             end
         end;
         [t, u] = min(temp);    
         visited(u) = u;       
         for v = 1:n,           
             if ( ( netCostMatrix(u, v) + distance(u)) < distance(v) )
                 distance(v) = distance(u) + netCostMatrix(u, v);   
                 parent(v) = u;                                     
             end;             
         end;
    end
end