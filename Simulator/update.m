function [ InputVCBufferStatus, OutputVCBufferStatus, CoreBufferStatus ] = update( InputVCBufferStatusTempAll, OutputVCBufferStatusTempAll, CoreBufferStatusTempAll, InputVCBufferStatus, OutputVCBufferStatus, CoreBufferStatus )

global MaxSwitchNumber; 
global MaxOutputVCNumber;
global MaxNumberOfVC;
global MaxPortNumber;

% struture of InputVCBufferStatus
% 4D array
% 1st dimension denoted by switch number
% 2nd dimension denoted by port number of the switch
% 3rd dimension denoted by VC number
global MsgNumberInVC; % value = 1, contains the number of the message currently occupying the VC, reserved for a single message until all flits pass
global FlitsPassedFromVC; % value = 2, contains the number of flits of MsgNumber passed from the VC
global NextPortNumber; % value = 3,contains the next port number for the flit
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
CoreBufferStatusTemp = CoreBufferStatus;
InputVCBufferStatusTemp = InputVCBufferStatus;
OutputVCBufferStatusTemp = OutputVCBufferStatus;

global SwitchTotal;

% updating CoreBufferStatus
for dim = 1:2
    for i = 1:SwitchTotal
        for j = 1:MaxNumberOfVC
            if CoreBufferStatusTempAll(i,j,dim) < CoreBufferStatusTemp(i,j)
                CoreBufferStatus(i,j) = CoreBufferStatus(i,j) - 1;
            else
                if CoreBufferStatusTempAll(i,j,dim) > CoreBufferStatusTemp(i,j)
                    CoreBufferStatus(i,j) = CoreBufferStatus(i,j) + 1;
                end
            end
        end
    end
end

for dim = 1:3
    for i = 1:SwitchTotal
        for j = 1:MaxPortNumber
            for k = 1:MaxNumberOfVC
                    % update NumberOfFreeFIFO in InputVCBufferStatus
                 if InputVCBufferStatusTempAll(i,j,k,NumberOfFreeFIFO,dim) < InputVCBufferStatusTemp(i,j,k,NumberOfFreeFIFO) % if NumberOfFreeFIFO in input buffers decrease
                     InputVCBufferStatus(i,j,k,NumberOfFreeFIFO) = InputVCBufferStatus(i,j,k,NumberOfFreeFIFO) - 1;
                 else     
                     if InputVCBufferStatusTempAll(i,j,k,NumberOfFreeFIFO,dim) > InputVCBufferStatusTemp(i,j,k,NumberOfFreeFIFO) % if NumberOfFreeFIFO in input buffers increase
                     InputVCBufferStatus(i,j,k,NumberOfFreeFIFO) = InputVCBufferStatus(i,j,k,NumberOfFreeFIFO) + 1;
                     end
                 end  
            end
        end
    end
    for i = 1:SwitchTotal
        for j = 1:MaxPortNumber
            for k = 1:MaxOutputVCNumber  
                % update NumberOfFreeFIFOOutput in OutputVCBufferStatus
                 if OutputVCBufferStatusTempAll(i,j,k,NumberOfFreeFIFOOutput,dim) < OutputVCBufferStatusTemp(i,j,k,NumberOfFreeFIFOOutput)% if NumberOfFreeFIFO in output buffers decrease
                     OutputVCBufferStatus(i,j,k,NumberOfFreeFIFOOutput) = OutputVCBufferStatus(i,j,k,NumberOfFreeFIFOOutput) - 1;
                 else     
                     if OutputVCBufferStatusTempAll(i,j,k,NumberOfFreeFIFOOutput,dim) > OutputVCBufferStatusTemp(i,j,k,NumberOfFreeFIFOOutput) % if NumberOfFreeFIFO in output buffers increase
                     OutputVCBufferStatus(i,j,k,NumberOfFreeFIFOOutput) = OutputVCBufferStatus(i,j,k,NumberOfFreeFIFOOutput) + 1;
                     end
                 end  
            end
        end
    end
end


for i = 1:SwitchTotal
    for j = 1:MaxPortNumber
        for k = 1:MaxNumberOfVC
            
            InputVCBufferStatus(i,j,k,FlitsPassedFromVC) = InputVCBufferStatusTempAll(i,j,k,FlitsPassedFromVC,2); % update FlitsPassedFromVC in InputVCBufferStatus
            InputVCBufferStatus(i,j,k,NextPortNumber) = InputVCBufferStatusTempAll(i,j,k,NextPortNumber,2); % update NextPortNumber in InputVCBufferStatus
            InputVCBufferStatus(i,j,k,NextVCNumber) = InputVCBufferStatusTempAll(i,j,k,NextVCNumber,2); % update NextVCNumber in InputVCBufferStatus
             % update MsgNumberInVC in InputVCBufferStatus
             if InputVCBufferStatusTempAll(i,j,k,MsgNumberInVC,1) ~= InputVCBufferStatusTemp(i,j,k,MsgNumberInVC)
                 InputVCBufferStatus(i,j,k,MsgNumberInVC) = InputVCBufferStatusTempAll(i,j,k,MsgNumberInVC,1);
             else
                 if InputVCBufferStatusTempAll(i,j,k,MsgNumberInVC,2) ~= InputVCBufferStatusTemp(i,j,k,MsgNumberInVC)
                     InputVCBufferStatus(i,j,k,MsgNumberInVC) = InputVCBufferStatusTempAll(i,j,k,MsgNumberInVC,2);
                 else
                     if InputVCBufferStatusTempAll(i,j,k,MsgNumberInVC,3) ~= InputVCBufferStatusTemp(i,j,k,MsgNumberInVC)
                         InputVCBufferStatus(i,j,k,MsgNumberInVC) = InputVCBufferStatusTempAll(i,j,k,MsgNumberInVC,3);
                     end
                 end
             end
        end
    end
end
for i = 1:SwitchTotal
    for j = 1:MaxPortNumber
        for k = 1:MaxOutputVCNumber            
            
             OutputVCBufferStatus(i,j,k,FlitsPassedFromVCOutput) = OutputVCBufferStatusTempAll(i,j,k,FlitsPassedFromVCOutput,2);  % update FlitsPassedFromVCOutput in OutputVCBufferStatus
             OutputVCBufferStatus(i,j,k,NextVCNumber) = OutputVCBufferStatusTempAll(i,j,k,NextVCNumber,2);  % update NextVCNumber in OutputVCBufferStatus
                % update MsgNumberInVC in OutputVCBufferStatus
             if OutputVCBufferStatusTempAll(i,j,k,MsgNumberInVC,1) ~= OutputVCBufferStatusTemp(i,j,k,MsgNumberInVC)
                 OutputVCBufferStatus(i,j,k,MsgNumberInVC) = OutputVCBufferStatusTempAll(i,j,k,MsgNumberInVC,1);
             else
                 if OutputVCBufferStatusTempAll(i,j,k,MsgNumberInVC,2) ~= OutputVCBufferStatusTemp(i,j,k,MsgNumberInVC)
                     OutputVCBufferStatus(i,j,k,MsgNumberInVC) = OutputVCBufferStatusTempAll(i,j,k,MsgNumberInVC,2);
                 else
                     if OutputVCBufferStatusTempAll(i,j,k,MsgNumberInVC,3) ~= OutputVCBufferStatusTemp(i,j,k,MsgNumberInVC)
                         OutputVCBufferStatus(i,j,k,MsgNumberInVC) = OutputVCBufferStatusTempAll(i,j,k,MsgNumberInVC,3);
                     end
                 end
             end
        end
    end
end

for i = 1:SwitchTotal
    for j = 2:MaxPortNumber
        for k = 1:MaxOutputVCNumber 
             OutputVCBufferStatus(i,j,k,FlitsPassedFromVCOutput) = OutputVCBufferStatusTempAll(i,j,k,FlitsPassedFromVCOutput,2);  % update FlitsPassedFromVCOutput in OutputVCBufferStatus
        end
    end
end
for i = 1:SwitchTotal
    for k = 1:MaxOutputVCNumber 
        OutputVCBufferStatus(i,1,k,FlitsPassedFromVCOutput) = OutputVCBufferStatusTempAll(i,1,k,FlitsPassedFromVCOutput,3); 
    end
end
        
