function [ CoreStatus, CoreBufferStatus, MsgStatus, InputVCBufferStatus ] = flit_generate_multicast( InjectionLoad, traffic, CoreNumber, CoreStatus, CoreBufferStatus, MsgStatus, InputVCBufferStatus )
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
global MulticastSource;
global MulticastDestination1;
global MulticastDestination2;
global MulticastDestination3;
global MulticastDestination4;
global MulticastDestination5;
global MulticastDestination6;

% Data Structure indices of CoreStatus (values: 1,2,3,4)
% 2D array
% row denoted by CoreNumber

global OnOrOff; % value = 1
global CurrentMsgNumber; % value = 2
global CurrentMsgNumber2; % value = 3
global CurrentMsgNumber3; % value = 4
global CurrentMsgNumber4; % value = 5
global CurrentMsgNumber5; % value = 6
global CurrentMsgNumber6; % value = 7

% Data Structure indices for MsgStatus
% 2D array
% row denoted by MsgNumber
global VCNumber; % value = 1
global FlitsLeft; % value = 2
global Source; % value = 3
global Destination; % value = 4
global InjectCycle; % value = 5
global AbsorbCycle; % value = 6




 %%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%%%%%%%%
global HeaderFlit;


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

global NoWirelessTranscievers;


global MulticastSource ;
global MulticastDestination;
MulticastDestination = zeros(NoWirelessTranscievers-1);

% determine the multicast destination depending on the multicast sources
j=1;
for i=1:NoWirelessTranscievers
    if(MulticastSource(i)== CoreNumber)
        continue;
    else
        MulticastDestination(j)=MulticastSource(i);
        j=j+1;
    end
end

%     1

 if (CoreStatus(CoreNumber,OnOrOff) == 1) % Check for flit injection if it is in On-time
           
            
            
            
            
            %Inject flit
            if (CoreStatus(CoreNumber,CurrentMsgNumber)~=0) % this is also the current Msg Number the core is injecting
                %inject body flits of previous message after checking for buffer space
                %checking for free buffer space
                if (CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),VCNumber)) > 0)
                    %checking if flit is due in this cycle
                    if(rand < InjectionLoad)
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
                    if (rand < InjectionLoad)
                        %inject header flit and updating status
                        if(size(MsgStatus,1) == 1 && MsgStatus(1,Source) == 0) % checking if it is the very first message of the simulation
                            NewMsgNumber = 1;
                        else
                            NewMsgNumber = size(MsgStatus,1) + 1;
                        end
                        CoreStatus(CoreNumber,CurrentMsgNumber) = NewMsgNumber; % new message
                        MsgStatus(NewMsgNumber,VCNumber) = imax; % going to the VC with max capacity
                        MsgStatus(NewMsgNumber,FlitsLeft) = MsgLength - 1;
                        MsgStatus(NewMsgNumber,Source) = CoreNumber;
                        MsgStatus(NewMsgNumber,Destination) = MulticastDestination(MulticastDestination1);   % generate_destination(CoreNumber, traffic);
                        MsgStatus(NewMsgNumber,InjectCycle) = SimCycle;
                        MsgStatus(NewMsgNumber,AbsorbCycle) = 0;
                        CoreBufferStatus(CoreNumber,imax) = CoreBufferStatus(CoreNumber,imax) - 1;
                        % update InputVCBufferStatus
                        InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),VCNumber),NumberOfFreeFIFO) - 1;
                        InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber),VCNumber),MsgNumberInVC) = NewMsgNumber;
                        NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
                    end
                end
            end  

        
    
    
%  2   
    %Inject flit
    if (CoreStatus(CoreNumber,CurrentMsgNumber2)~=0) % this is also the current Msg Number the core is injecting
        %inject body flits of previous message after checking for buffer space
        %checking for free buffer space
        if (CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),VCNumber)) > 0)
            %checking if flit is due in this cycle
            if(rand < InjectionLoad)
                %injecting flit and updating status
                CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),VCNumber)) = CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),VCNumber)) - 1;
                MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),FlitsLeft) = MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),FlitsLeft) - 1;
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),VCNumber),NumberOfFreeFIFO) - 1;
               
                                 %%%%%%%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%
                                %capture current flit number
                                FlitNo=MsgLength - MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),FlitsLeft);
                                %ugdate inject cycle for the selected flit
                                MsgEnergyStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),FlitNo,FlitInjectCycle)=SimCycle;
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
                if (MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),FlitsLeft) == 0)
                    
                    CoreStatus(CoreNumber,CurrentMsgNumber2) = 0; % tail flit injected
%                     MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),InjectCycle) = SimCycle;
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
            if (rand < InjectionLoad)
                %inject header flit and updating status
                if(size(MsgStatus,1) == 1 && MsgStatus(1,Source) == 0) % checking if it is the very first message of the simulation
                    NewMsgNumber = 1;
                else
                    NewMsgNumber = size(MsgStatus,1) + 1;
                end
                CoreStatus(CoreNumber,CurrentMsgNumber2) = NewMsgNumber; % new message
                MsgStatus(NewMsgNumber,VCNumber) = imax; % going to the VC with max capacity
                MsgStatus(NewMsgNumber,FlitsLeft) = MsgLength - 1;
                MsgStatus(NewMsgNumber,Source) = CoreNumber;
                MsgStatus(NewMsgNumber,Destination) = MulticastDestination(MulticastDestination2);   % generate_destination(CoreNumber, traffic);
                MsgStatus(NewMsgNumber,InjectCycle) = SimCycle;
                MsgStatus(NewMsgNumber,AbsorbCycle) = 0;
                
                
                  %%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%%%%%%%%
                MsgEnergyStatus(NewMsgNumber,:,:)=zeros(MsgLength,FlitEnergy);
                MsgEnergyStatus(NewMsgNumber,HeaderFlit,FlitInjectCycle)=SimCycle;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                
                
                
                CoreBufferStatus(CoreNumber,imax) = CoreBufferStatus(CoreNumber,imax) - 1;
                % update InputVCBufferStatus
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),VCNumber),NumberOfFreeFIFO) - 1;
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber2),VCNumber),MsgNumberInVC) = NewMsgNumber;
                NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
            end
        end
    end  
    
    
%   3  
    %Inject flit
    if (CoreStatus(CoreNumber,CurrentMsgNumber3)~=0) % this is also the current Msg Number the core is injecting
        %inject body flits of previous message after checking for buffer space
        %checking for free buffer space
        if (CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),VCNumber)) > 0)
            %checking if flit is due in this cycle
            if(rand < InjectionLoad)
                %injecting flit and updating status
                CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),VCNumber)) = CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),VCNumber)) - 1;
                MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),FlitsLeft) = MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),FlitsLeft) - 1;
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),VCNumber),NumberOfFreeFIFO) - 1;
                
                                %%%%%%%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%
                                %capture current flit number
                                FlitNo=MsgLength - MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),FlitsLeft);
                                %ugdate inject cycle for the selected flit
                                MsgEnergyStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),FlitNo,FlitInjectCycle)=SimCycle;
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
                if (MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),FlitsLeft) == 0)
                    
                    CoreStatus(CoreNumber,CurrentMsgNumber3) = 0; % tail flit injected
%                     MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),InjectCycle) = SimCycle;
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
            if (rand < InjectionLoad)
                %inject header flit and updating status
                if(size(MsgStatus,1) == 1 && MsgStatus(1,Source) == 0) % checking if it is the very first message of the simulation
                    NewMsgNumber = 1;
                else
                    NewMsgNumber = size(MsgStatus,1) + 1;
                end
                CoreStatus(CoreNumber,CurrentMsgNumber3) = NewMsgNumber; % new message
                MsgStatus(NewMsgNumber,VCNumber) = imax; % going to the VC with max capacity
                MsgStatus(NewMsgNumber,FlitsLeft) = MsgLength - 1;
                MsgStatus(NewMsgNumber,Source) = CoreNumber;
                MsgStatus(NewMsgNumber,Destination) = MulticastDestination(MulticastDestination3);    % generate_destination(CoreNumber, traffic);
                MsgStatus(NewMsgNumber,InjectCycle) = SimCycle;
                MsgStatus(NewMsgNumber,AbsorbCycle) = 0;
                
                %%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%%%%%%%%
                MsgEnergyStatus(NewMsgNumber,:,:)=zeros(MsgLength,FlitEnergy);
                MsgEnergyStatus(NewMsgNumber,HeaderFlit,FlitInjectCycle)=SimCycle;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                CoreBufferStatus(CoreNumber,imax) = CoreBufferStatus(CoreNumber,imax) - 1;
                % update InputVCBufferStatus
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),VCNumber),NumberOfFreeFIFO) - 1;
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber3),VCNumber),MsgNumberInVC) = NewMsgNumber;
                NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
            end
        end
    end  




%     4

       
            %Inject flit
            if (CoreStatus(CoreNumber,CurrentMsgNumber4)~=0) % this is also the current Msg Number the core is injecting
                %inject body flits of previous message after checking for buffer space
                %checking for free buffer space
                if (CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),VCNumber)) > 0)
                    %checking if flit is due in this cycle
                    if(rand < InjectionLoad)
                        %injecting flit and updating status
                        CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),VCNumber)) = CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),VCNumber)) - 1;
                        MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),FlitsLeft) = MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),FlitsLeft) - 1;
                        InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),VCNumber),NumberOfFreeFIFO) - 1;
                        
                                %%%%%%%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%
                                %capture current flit number
                                FlitNo=MsgLength - MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),FlitsLeft);
                                %ugdate inject cycle for the selected flit
                                MsgEnergyStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),FlitNo,FlitInjectCycle)=SimCycle;
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        
                        NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
                        if (MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),FlitsLeft) == 0)

                            CoreStatus(CoreNumber,CurrentMsgNumber4) = 0; % tail flit injected
        %                     MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),InjectCycle) = SimCycle;
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
                    if (rand < InjectionLoad)
                        %inject header flit and updating status
                        if(size(MsgStatus,1) == 1 && MsgStatus(1,Source) == 0) % checking if it is the very first message of the simulation
                            NewMsgNumber = 1;
                        else
                            NewMsgNumber = size(MsgStatus,1) + 1;
                        end
                        CoreStatus(CoreNumber,CurrentMsgNumber4) = NewMsgNumber; % new message
                        MsgStatus(NewMsgNumber,VCNumber) = imax; % going to the VC with max capacity
                        MsgStatus(NewMsgNumber,FlitsLeft) = MsgLength - 1;
                        MsgStatus(NewMsgNumber,Source) = CoreNumber;
                        MsgStatus(NewMsgNumber,Destination) = MulticastDestination(MulticastDestination4);   % generate_destination(CoreNumber, traffic);
                        MsgStatus(NewMsgNumber,InjectCycle) = SimCycle;
                        MsgStatus(NewMsgNumber,AbsorbCycle) = 0;
                        
                        
                        
                            %%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%%%%%%%%
                                MsgEnergyStatus(NewMsgNumber,:,:)=zeros(MsgLength,FlitEnergy);
                                MsgEnergyStatus(NewMsgNumber,HeaderFlit,FlitInjectCycle)=SimCycle;
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        
                        
                        CoreBufferStatus(CoreNumber,imax) = CoreBufferStatus(CoreNumber,imax) - 1;
                        % update InputVCBufferStatus
                        InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),VCNumber),NumberOfFreeFIFO) - 1;
                        InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber4),VCNumber),MsgNumberInVC) = NewMsgNumber;
                        NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
                    end
                end
            end  

    
    
    
%  5   
    %Inject flit
    if (CoreStatus(CoreNumber,CurrentMsgNumber5)~=0) % this is also the current Msg Number the core is injecting
        %inject body flits of previous message after checking for buffer space
        %checking for free buffer space
        if (CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),VCNumber)) > 0)
            %checking if flit is due in this cycle
            if(rand < InjectionLoad)
                %injecting flit and updating status
                CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),VCNumber)) = CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),VCNumber)) - 1;
                MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),FlitsLeft) = MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),FlitsLeft) - 1;
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),VCNumber),NumberOfFreeFIFO) - 1;
              
                
                                %%%%%%%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%
                                %capture current flit number
                                FlitNo=MsgLength - MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),FlitsLeft);
                                %ugdate inject cycle for the selected flit
                                MsgEnergyStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),FlitNo,FlitInjectCycle)=SimCycle;
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
                if (MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),FlitsLeft) == 0)
                    
                    CoreStatus(CoreNumber,CurrentMsgNumber5) = 0; % tail flit injected
%                     MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),InjectCycle) = SimCycle;
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
            if (rand < InjectionLoad)
                %inject header flit and updating status
                if(size(MsgStatus,1) == 1 && MsgStatus(1,Source) == 0) % checking if it is the very first message of the simulation
                    NewMsgNumber = 1;
                else
                    NewMsgNumber = size(MsgStatus,1) + 1;
                end
                CoreStatus(CoreNumber,CurrentMsgNumber5) = NewMsgNumber; % new message
                MsgStatus(NewMsgNumber,VCNumber) = imax; % going to the VC with max capacity
                MsgStatus(NewMsgNumber,FlitsLeft) = MsgLength - 1;
                MsgStatus(NewMsgNumber,Source) = CoreNumber;
                MsgStatus(NewMsgNumber,Destination) = MulticastDestination(MulticastDestination5);   % generate_destination(CoreNumber, traffic);
                MsgStatus(NewMsgNumber,InjectCycle) = SimCycle;
                MsgStatus(NewMsgNumber,AbsorbCycle) = 0;
                
                
                            %%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%%%%%%%%
                                MsgEnergyStatus(NewMsgNumber,:,:)=zeros(MsgLength,FlitEnergy);
                                MsgEnergyStatus(NewMsgNumber,HeaderFlit,FlitInjectCycle)=SimCycle;
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        
                CoreBufferStatus(CoreNumber,imax) = CoreBufferStatus(CoreNumber,imax) - 1;
                % update InputVCBufferStatus
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),VCNumber),NumberOfFreeFIFO) - 1;
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber5),VCNumber),MsgNumberInVC) = NewMsgNumber;
                NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
            end
        end
    end  
    
    
%   6 
    %Inject flit
    if (CoreStatus(CoreNumber,CurrentMsgNumber6)~=0) % this is also the current Msg Number the core is injecting
        %inject body flits of previous message after checking for buffer space
        %checking for free buffer space
        if (CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),VCNumber)) > 0)
            %checking if flit is due in this cycle
            if(rand < InjectionLoad)
                %injecting flit and updating status
                CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),VCNumber)) = CoreBufferStatus(CoreNumber, MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),VCNumber)) - 1;
                MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),FlitsLeft) = MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),FlitsLeft) - 1;
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),VCNumber),NumberOfFreeFIFO) - 1;
               
                                %%%%%%%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%
                                %capture current flit number
                                FlitNo=MsgLength - MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),FlitsLeft);
                                %ugdate inject cycle for the selected flit
                                MsgEnergyStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),FlitNo,FlitInjectCycle)=SimCycle;
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                
                NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
                if (MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),FlitsLeft) == 0)
                    
                    CoreStatus(CoreNumber,CurrentMsgNumber6) = 0; % tail flit injected
%                     MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),InjectCycle) = SimCycle;
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
            if (rand < InjectionLoad)
                %inject header flit and updating status
                if(size(MsgStatus,1) == 1 && MsgStatus(1,Source) == 0) % checking if it is the very first message of the simulation
                    NewMsgNumber = 1;
                else
                    NewMsgNumber = size(MsgStatus,1) + 1;
                end
                CoreStatus(CoreNumber,CurrentMsgNumber6) = NewMsgNumber; % new message
                MsgStatus(NewMsgNumber,VCNumber) = imax; % going to the VC with max capacity
                MsgStatus(NewMsgNumber,FlitsLeft) = MsgLength - 1;
                MsgStatus(NewMsgNumber,Source) = CoreNumber;
                MsgStatus(NewMsgNumber,Destination) = MulticastDestination(MulticastDestination6);    % generate_destination(CoreNumber, traffic);
                MsgStatus(NewMsgNumber,InjectCycle) = SimCycle;
                MsgStatus(NewMsgNumber,AbsorbCycle) = 0;
                
                
                            %%%%%%%%%%%%%%%%%Energy Calculation%%%%%%%%%%%%%%%%%%%%%%%%
                                MsgEnergyStatus(NewMsgNumber,:,:)=zeros(MsgLength,FlitEnergy);
                                MsgEnergyStatus(NewMsgNumber,HeaderFlit,FlitInjectCycle)=SimCycle;
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        
                
                CoreBufferStatus(CoreNumber,imax) = CoreBufferStatus(CoreNumber,imax) - 1;
                % update InputVCBufferStatus
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),VCNumber),NumberOfFreeFIFO) = InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),VCNumber),NumberOfFreeFIFO) - 1;
                InputVCBufferStatus(CoreNumber,CorePort,MsgStatus(CoreStatus(CoreNumber,CurrentMsgNumber6),VCNumber),MsgNumberInVC) = NewMsgNumber;
                NumberOfFlitsGenerated = NumberOfFlitsGenerated + 1;
            end
        end
    end



 end
        
end






















