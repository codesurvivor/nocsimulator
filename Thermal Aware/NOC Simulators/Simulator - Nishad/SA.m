function [ WiNodes, hBar hBarArray, hBarCounter, Connectivity ] = SA( WiNodes, hBar, hBarArray, hBarCounter, Connectivity )
% Simulated annealing function

clc;

global MaxSwitchNumber
global NumberWirelessNodes;


for i = 1:10000
    
    done = 0;
    counter = 0;
    
    while(done == 0)
        
        newWiNode = randi(64,1);
        
        % check to see if that node already exists
        exists = 0;
        
        for j = 1:NumberWirelessNodes
            if(newWiNode == WiNodes(j))
                exists = 1;
            end
        end
        
        correctDist = 0;
        
        if(exists == 0)
            % check to see if the node is within 7mm of any other nodes;
            correctDist = 1;
            
            for j = 1:NumberWirelessNodes
                otherNode = WiNodes(j);
                
                if(otherNode ~= 0)
                    distance = distanceCalc(newWiNode,otherNode);
                    
                    if(distance < 7)
                        correcDist = 0;
                    end
                end
                
            end
            
        end
        
        alreadyLinked = 0;
        
        if(correctDist == 1)
            
            for j = 1:NumberWirelessNodes
                otherNode = WiNodes(j);
                
                if(Connectivity(otherNode,newWiNode) == 1)
                    alreadyLinked = 1;
                end
            end
            
        end
        
        if(alreadyLinked == 0 && correctDist == 1 && exists == 0)
            
            done = 1;
            
        end
    end
    
    newWiNode
    
    replaceNode = randi(12,1);
    
    oldNode = WiNodes(replaceNode);
    
    %removing the old links from the matrix
    for j = 1:NumberWirelessNodes
        
        if(j ~= replaceNode)
            Connectivity(WiNodes(j),oldNode,1) = -1;
            Connectivity(oldNode,WiNodes(j),1) = -1;
        end
    end
    
    
    WiNodes(replaceNode) = newWiNode;
    
    % adding the new links into the matrix
    for j = 1:NumberWirelessNodes
        
        if(j ~= replaceNode)
            Connectivity(WiNodes(j),newWiNode,1) = 1;
            Connectivity(newWiNode,WiNodes(j),1) = 1;
        end
        
    end
    
    DijkstraRoutingMatrix2 = zeros(MaxSwitchNumber,MaxSwitchNumber,MaxSwitchNumber);
    [ DijkstraRoutingMatrix2 ] = dijkstra_routing_information( DijkstraRoutingMatrix2 );
    
    
    hBarPrime = hopCalc(DijkstraRoutingMatrix2)
    
    break;
    
    if(hBarPrime < hBar)
        counter = 0;
        hBar = hBarPrime;
        hBarArray(hBarCounter) = hBar;
        hBarCounter = hBarCounter + 1;
    else
        
        T = 100/i;

        
        prob = exp(-(hBarPrime - hBar)/T)
        
        randValue = rand(1)
        
        
        if(randValue < prob)
            counter = 0;
            hBar = hBarPrime
            hBarArray(hBarCounter) = hBar;
            hBarCounter = hBarCounter + 1;
            
        else
            counter = counter + 1

            
            % if counter gets too high, break out of the for loop
            
            
            %removing the old links from the matrix
            for j = 1:NumberWirelessNodes
                
                if(j ~= replaceNode)
                    Connectivity(WiNodes(j),newWiNode,1) = -1;
                    Connectivity(newWiNode,WiNodes(j),1) = -1;
                end
            end
            
            WiNodes(replaceNode) = oldNode;
            
            % adding the new links into the matrix
            for j = 1:NumberWirelessNodes
                
                if(j ~= replaceNode)
                    Connectivity(WiNodes(j),oldNode,1) = 1;
                    Connectivity(oldNode,WiNodes(j),1) = 1;
                end
                
            end
            
            if(counter == 10)
                break;
            end
        end
    end
end

i
WiNodes = sort(WiNodes)


hBar
plot(hBarArray);

end

