function [ CoreStatus, CoreBufferStatus, MsgStatus, InputVCBufferStatus ] = flit_generate( InjectionLoad, traffic, CoreNumber, CoreStatus, CoreBufferStatus, MsgStatus, InputVCBufferStatus )
% This function generates flits for a single core in a single cycle
% Takes status of cores as inputs and determines whether or not to inject a flit and then updates status of cores accordingly
% Modifies InputVCBufferStatus accordingly

% Global Simulation numbers
global MsgLength; % Number of flits in messages
global MaxNumberOfVC; % maximum number of VCs in all ports
global CorePort; % Port number where all cores are connected to the switch; value = 1
CorePort = 1;
global NumberOfFlitsGenerated;
global SimCycle;


 %%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%%%%%%%%
global HeaderFlit;

%Naseef Mansoor
%MsgRoutingScheme 1D matrics used to notify which msg will take wired and
%which will take wireless path.
global MsgRoutingScheme;
%WirelessRoutingThreshold is a variable that denotes the threshold level to
%use the wireless topology.
global WirelessRoutingThreshold;
%naseed mansoor end

% Data structure for energy calculations
%stores the energy comsumed for each flit in each message
global MsgEnergyStatus;
%3D array
%1D Message Number
%2D Flit Number of each message
%3D mentioned below
global FlitInjectCycle; % value = 1
%global FlitAbsorbCycle; % value = 2
global FlitEnergy ;     % value = 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% Data Structure indices of CoreStatus (values: 1,2,3,4)
% 2D array
% row denoted by CoreNumber
% global CycleOfLastCompletedTime; % value = 1
global OnOrOff; % value = 2
% global DurationOfNextTime; % value = 3
global CurrentMsgNumber; % value = 4


% Data Structure indices for MsgStatus
% 2D array
% row denoted by MsgNumber
global VCNumber; % value = 1
global FlitsLeft; % value = 2
global Source; % value = 3
global Destination; % value = 4
global InjectCycle; % value = 5
global AbsorbCycle; % value = 6

% Data Structure indices for CoreBufferStatus
% 2D array contains the number of FIFOs free in the VC
% row denoted by CoreNumber
% 2nd dimension by VCNumber (1 to MaxNumberOfVC)

% struture of InputVCBufferStatus
% 4D array
% 1st dimension denoted by switch number
% 2nd dimension denoted by port number of the switch
% 3rd dimension denoted by VC number
global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
% global FlitsPassedFromVC; % value = 2, contains the number of flits of MsgNumber passed from the VC
% global NextPortNumber; % value = 3,contains the next port number for the flit
% global NextVCNumber; % value = 4, contains the next port's VC number for the flit
global NumberOfFreeFIFO; % value = 5, initialized to BufferDepth
%Nishad Nerurkar
global InjectionMatrix;
%Nishad Nerurkar

if (CoreStatus(CoreNumber,OnOrOff) == 1) % Check for flit injection if it is in On-time
    %Inject flit
    if (CoreStatus(CoreNumber,CurrentMsgNumber)~=0) % this is also the current Msg Number the core is injecting
        %inject body flits of previous message after checking for buffer space
        %checking for free buffer space
        if (CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),VCNumber)) > 0)
            %checking if flit is due in this cycle
			%Nishad Nerurkar
% 			src = MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),Source);
            
% 			for i = 1:length(InjectionMatrix(CoreNumber,:))
%                 CoreInjectCDF(i) = sum(InjectionMatrix(CoreNumber,1:i));
%             end
%             r = rand/10;
%             dst = find(CoreInjectCDF > r,1);
% 			%Nishad Nerurkar
            if (rand < 1)%(dst == MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),Destination)) % Edit for Variable Injection Loads based on Injection Matrix
                           
                %injecting flit and updating status
                CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),VCNumber)) = CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),VCNumber)) - 1;
                MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),FlitsLeft) = MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),FlitsLeft) - 1;
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),VCNumber),NumberOfFreeFIFO) - 1;
                
                 %%%%%%%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%
                 %capture current flit number
                FlitNo=MsgLength - MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),FlitsLeft);
                %ugdate inject cycle for the selected flit
                MsgEnergyStatus(CoreStatus(CoreNumber,CurrentMsgNumber),FlitNo,FlitInjectCycle)=SimCycle;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
                if (MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),FlitsLeft) == 0)
                    
                    CoreStatus(CoreNumber,CurrentMsgNumber) = 0; % tail flit injected
%                     MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),InjectCycle) = SimCycle;
                end
                % update InputVCBufferStatus
                
            end
        end
    else
        %inject new message (header flit) after checking for free VC
        % max = 0;
        imax = 0;
        for i = 1:MaxNumberOfVC,
            if (InputVCBufferStatus(CoreNumber,CorePort,i,MsgNumberInVC) == 0)
                % max = CoreBufferStatus(CoreNumber,i); % getting the VC with the max capacity
                imax = i;
            end
        end
        if (imax ~= 0) % VC number imax is free
            % checking if flit is due in this cycle
            % Nishad Nerurkar
            for i = 1:length(InjectionMatrix(CoreNumber,:))
                CoreInjectCDF(i) = sum(InjectionMatrix(CoreNumber,1:i));
            end
            r = rand/336;
            dst = find(CoreInjectCDF > r,1);
            if(numel(dst)== 1 && dst > 0)%(rand < InjectionLoad)
                %inject header flit and updating status
                if(size(MsgStatus,1) == 1 && MsgStatus(1,Source) == 0) % checking if it is the very first message of the simulation
                    NewMsgNumber = 1;
                else
                    NewMsgNumber = size(MsgStatus,1) + 1;
                end
                % Naseef Mansoor
                % Condition if the probability is greater than or equal to
                % threshold then let this use the wireless topology else use
                % the wired topology
                if (rand >= WirelessRoutingThreshold)
                    MsgRoutingNewEntry=[NewMsgNumber 2];
                    MsgRoutingScheme=[MsgRoutingScheme 
                                      MsgRoutingNewEntry];
                else
                    MsgRoutingNewEntry=[NewMsgNumber 1];
                    MsgRoutingScheme=[MsgRoutingScheme 
                                      MsgRoutingNewEntry];
                end
                
                % naseef mansoor end
                CoreStatus(CoreNumber,CurrentMsgNumber) = NewMsgNumber; % new message
                MsgStatus(NewMsgNumber,VCNumber) = imax; % going to the VC with max capacity
                MsgStatus(NewMsgNumber,FlitsLeft) = MsgLength - 1;
                MsgStatus(NewMsgNumber,Source) = CoreNumber;
                MsgStatus(NewMsgNumber,Destination) = dst;%generate_destination(CoreNumber, traffic);
                MsgStatus(NewMsgNumber,InjectCycle) = SimCycle;
                MsgStatus(NewMsgNumber,AbsorbCycle) = 0;
                
                
                
                
                 %%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%%%%%%%%
                MsgEnergyStatus(NewMsgNumber,:,:)=zeros(MsgLength,FlitEnergy);
                MsgEnergyStatus(NewMsgNumber,HeaderFlit,FlitInjectCycle)=SimCycle;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                %decrement the number of free fifo in the selected VC for the core
                CoreBufferStatus(CoreNumber,imax) = CoreBufferStatus(CoreNumber,imax) - 1;
                % update InputVCBufferStatus
                %decrements the fifo of the selected VC at the source input port by 1
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),VCNumber),NumberOfFreeFIFO) - 1;
                %assigns the message number to the VC at the source input port
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),VCNumber),MsgNumberInVC) = NewMsgNumber;
                NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
            end
        end
    end  
end

end

