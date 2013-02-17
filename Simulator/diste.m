function d = diste(a,b,m,n)
    D = gen_coord(m,n);
    x1 = D(a,2);
    x2 = D(b,2);
    y1 = D(a,3);
    y2 = D(b,3);
    d = sqrt(((x1-x2)^2) + ((y1-y2)^2));
end