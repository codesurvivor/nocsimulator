function Tn = Thermal_Map_Gen(T_Map_Current,Time_New,Time_Current,Event_List,LUT)
dT = zeros(1,length(T_Map_Current));
[r c] = size(Event_List);
for ae = 1:c
    
    inc = LUT(Time_New-Event_List(1,ae)+1,:,Event_List(3,ae))-LUT(Time_Current-Event_List(1,ae)+1,:,Event_List(3,ae));
    if Event_List(2,ae) < 0 
        sigma = 0.995;
    else
        sigma = 1;
    end
    dT = dT + sigma * Event_List(2,ae)*inc;
end
Tn = T_Map_Current + dT;
end