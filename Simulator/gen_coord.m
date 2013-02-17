function O = gen_coord(m,n)
    k = 1;
    O = zeros(m*n,3);
    O(:,1) = 1:(m*n);
    for i = 1:m
        for j = 1:n
          O(k,2) = i;
          O(k,3) = j;
          k = k +1;
        end
    end
    
end