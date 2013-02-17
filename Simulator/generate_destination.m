function [Destination] = generate_destination(CoreNumber, traffic)
% This function generates the destination address of a message for a
% particular core depending on the traffic

% Global Simulation Numbers
global UniformRandom; % value = 1
global HotSpot; % value = 2
global MaxCoreNumber; % the number of cores in the architecture
global HotSpotCore;
global HotSpotOrUniform;
global Transpose;
global FFTDist;
global FFTTraffic;
global MatrixMiltTraffic;
global MatrixMultiplication;
global DestinationArbitStatus;

 if(traffic == UniformRandom)
     Destination = ceil(rand*(MaxCoreNumber-1)); % picking 1 out of N-1 options
     if(Destination >= CoreNumber)
         Destination = Destination + 1;
     end
 end
 
 % for hotspot traffic 
 if (traffic == HotSpot)
    if CoreNumber == HotSpotCore
        Destination = ceil(rand*(MaxCoreNumber-1)); % picking 1 out of N-1 options
         if(Destination >= CoreNumber)
             Destination = Destination + 1;
         end
    else
        if HotSpotOrUniform(CoreNumber) == 20
            Destination = HotSpotCore;
            HotSpotOrUniform(CoreNumber) = 1;

        else
            Destination = ceil(rand*(MaxCoreNumber-1)); % picking 1 out of N-1 options
             if(Destination >= CoreNumber)
                 Destination = Destination + 1;
             end
             HotSpotOrUniform(CoreNumber) = HotSpotOrUniform(CoreNumber) + 1;
        end
    end
end


% for transpose traffic distribution
if (traffic == Transpose)
    TransposeMatrix = [64 9 17 25 33 41 49 57 2 55 18 26 34 42 50 58 3 11 46 27 35 43 51 59 4 12 20 37 36 44 52 60 5 13 21 29 28 45 53 61 6 14 22 30 38 19 54 62 7 15 23 31 39 47 10 63 8 16 24 32 40 48 56 1];
    Destination = TransposeMatrix(CoreNumber);
end


% for FFT traffic distribution
if (traffic == FFTDist)
    
    DestinationArbitStatus(CoreNumber) = 1 + mod(DestinationArbitStatus(CoreNumber),MaxCoreNumber);
    while (FFTTraffic(CoreNumber,DestinationArbitStatus(CoreNumber)) == 0)
        DestinationArbitStatus(CoreNumber) = 1 + mod(DestinationArbitStatus(CoreNumber),MaxCoreNumber);
    end
    Destination = DestinationArbitStatus(CoreNumber);
end


% for Matrix Multiplication traffic pattern
if (traffic == MatrixMultiplication)
    
    DestinationArbitStatus(CoreNumber) = 1 + mod(DestinationArbitStatus(CoreNumber),MaxCoreNumber);
    while (MatrixMiltTraffic(CoreNumber,DestinationArbitStatus(CoreNumber)) == 0)
        DestinationArbitStatus(CoreNumber) = 1 + mod(DestinationArbitStatus(CoreNumber),MaxCoreNumber);
    end
    Destination = DestinationArbitStatus(CoreNumber);
end

end
         