S = struct();
for i = 1:64
    for j = i:64
        if L(i,j)~=0
            str  = ['Link' num2str(i) 'to' num2str(j)];
            S.(str) = L(i,j);
        end
    end
end
