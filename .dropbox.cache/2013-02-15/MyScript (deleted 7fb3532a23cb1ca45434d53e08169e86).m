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
        if Conn(i,j) == 1  %(LinkEn(i,j) > 0) % for small world network put conn(i,j) == 1
            source = i;
            dest = j;
            path = dest;
            [d,p] = dijkstra(64,source,C);
            while(dest ~= source)
                path = [p(dest) path];
                dest = p(dest);
            end
            for iPath = 1:(length(path)-1)
                %L_En(path(iPath),path(iPath+1)) = L_En(path(iPath),path(iPath+1)) + (LinkEn(i,j)/d(j));
                L_En(path(iPath),path(iPath+1)) = L_En(path(iPath),path(iPath+1)) + 1;
            end
            
        end
    end
end
