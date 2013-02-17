function Tn = Thermal_Map_Gen1(T_Map_Current,Event_List,LUT)
dT = zeros(1,length(T_Map_Current));
[r c] = size(Event_List);
for ae = 1:c
    del = LUT(1000,:,Event_List(3,ae));
    if Event_List(2,ae) < 0 
        sigma = 0.995;
    else
        sigma = 1;
    end
    
    dT = dT + sigma*Event_List(2,ae)*del;
    
end
Tn = dT + 45 ;
end