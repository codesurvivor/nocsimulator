clear all;
clc;

load FFTRandom.mat;

C = zeros(64,64);
for i =1:64
    for j=1:64
        if i == j
            C(i,j) = 0;
        elseif(diste(i,j,8,8)==1)
            C(i,j) = 1;
        else
            C(i,j) = Inf;
        end
    end
end
Conn = xlsread('WiNoCTest_13WI.xls');

%LinkEn has link energy
% Put small world network
L_En = zeros(64,64);
for i = 1:64
    for j = 1:64
        if (LinkEn(i,j) > 0) %Conn(i,j) == 1  % % for small world network put conn(i,j) == 1
            source = i;
            dest = j;
            path = dest;
            [d,p] = dijkstra(64,source,C);
            while(dest ~= source)
                path = [p(dest) path];
                dest = p(dest);
            end
            for iPath = 1:(length(path)-1)
                L_En(path(iPath),path(iPath+1)) = L_En(path(iPath),path(iPath+1)) + (LinkEn(i,j)/d(j));
%                 L_En(path(iPath),path(iPath+1)) = L_En(path(iPath),path(iPath+1)) + 1;
            end
            
        end
    end
end
for i = 1:64
    for j = i:64
        L_En(i,j) = L_En(i,j) + L_En(j,i);
        L_En(j,i) = L_En(i,j);
    end
end
LinkOut = [];

S = struct();
for i = 1:63
        str = ['Link' num2str(i-1) '_' num2str(i)];
        S.(str) = L_En(i,i+1);
end
for i = 1:8
    prev = i;
    next = i + 8;
    while next < 64
            str = ['Link' num2str(prev-1) '_' num2str(next-1)];
            S.(str) = L_En(prev,next);
            prev = next;
            next = next + 8;
    end
end
% S will have the links as needed.

