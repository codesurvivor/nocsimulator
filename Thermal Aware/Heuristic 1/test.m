clc;
clear all;

h = xlsread('H_Data.xlsx','connections');
[r c] = size(h);
temp = zeros(r,c);
for i = 1:r
    for j = 1:c
        if i ~= j
            if h(i,j) > 0
                temp(i,j) = 1;
            else
                temp(i,j) = inf;
            end
        end     
    end
end
H =[];
for i = 1:r
    H(i,:) = dijkstra(64,i,temp);
end

