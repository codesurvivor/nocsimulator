% Traffic pattern generation for N-point radix-2 FFT Algorithm in N cores
function FFTTraffic = fft_traffic_dist(N)

% N is also the number of subnets

FFTTraffic = zeros(N,N);

for i = 1:log2(N), % number of steps (1-3)
    m = 2^i; % nos in a group
    k = 1;
    while(k<N)
        j = 0;
        while(j<m/2)
            FFTTraffic(k+j,k+j+m/2) = FFTTraffic(k+j,k+j+m/2) + 1;
            FFTTraffic(k+j+m/2,k+j) = FFTTraffic(k+j+m/2,k+j) + 1;
            j = j + 1;
        end
        k = k + m;
    end
end
FFTTraffic = FFTTraffic*(100/log2(N));