function [ WirelessPortArbitStatus, WiNodes, successful ] = port_arbitrate_wireless( iSwitch, WirelessPortArbitStatus, WiNodes, OutputVCBufferStatus )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global SwitchTotal;

global SBConnectivity;
global SendPort;

global NumberOfFreeFIFOOutput;

global OutputBufferDepth;
global MaxOutputVCNumber;
global MaxVCNumberOutput;
global NumberWirelessNodes;


global PortNumber;

successful = 0;
portCount = 0;

while(successful == 0 && portCount < PortNumber(iSwitch))

    for i = 1:NumberWirelessNodes
        if(iSwitch == WiNodes(i,1))
            WiIndex = i;
        end
    end
    
    WirelessPortArbitStatus(WiIndex,1) = 1 + mod(WirelessPortArbitStatus(WiIndex,1),PortNumber(iSwitch));
    portCount = portCount + 1;
    
    NextPort = WirelessPortArbitStatus(WiIndex,1);
    
    NextSwitch = 0;
    for jNextSwitch = 1:1:SwitchTotal,
        if(SBConnectivity(iSwitch,jNextSwitch,SendPort) == NextPort) % finding the switch number of next switch
            NextSwitch = jNextSwitch;
            %jPort
            break; % iNextSwitch contains the number of the receving switch for the current jPort
        end
    end
    
    wirelessPort = 0;
    
    for i = 1:NumberWirelessNodes
        if(NextSwitch == WiNodes(i,1))
            wirelessPort = 1;
        end
    end
    
    if(wirelessPort == 1)
        
        count = 0;
        WirelessPortArbitStatus(WiIndex,2) = 1 + mod(WirelessPortArbitStatus(WiIndex,2),MaxVCNumberOutput);
        
        while((OutputVCBufferStatus(iSwitch,NextPort,WirelessPortArbitStatus(WiIndex,2),NumberOfFreeFIFOOutput) == OutputBufferDepth) && (count < MaxOutputVCNumber))
            WirelessPortArbitStatus(WiIndex,2) = 1 + mod(WirelessPortArbitStatus(WiIndex,2),MaxVCNumberOutput);
            count = count + 1;
        end
        
        if(OutputVCBufferStatus(iSwitch,NextPort,WirelessPortArbitStatus(WiIndex,2),NumberOfFreeFIFOOutput) < OutputBufferDepth) % arbited VC has a flit to send
            % check for free FIFO on input side and send
            successful = 1;
            WirelessPortArbitStatus(WiIndex,3) = NextSwitch;
            
            WiNodes(WiIndex,3) = 1;
            WiNodes(WiIndex,2) = WirelessPortArbitStatus(WiIndex,1);
            WiNodes(WiIndex,4) = WirelessPortArbitStatus(WiIndex,2);
            WiNodes(WiIndex,5) = WirelessPortArbitStatus(WiIndex,3);

            
        end
        
    end
end
end

