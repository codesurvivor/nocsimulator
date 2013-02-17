function Tn = Estimate(Tc,tn,tc,E,LUT)

dT = zeros(1,length(Tc));
[r c] = size(E);
for ae = 1:c
    inc = LUT(tn-E(1,ae),:)-LUT(tc-E(1,ae),:)
    dT = dT + inc;
end
Tn = Tc + dT;
end