function Event_List = Event_List_Gen(E,Current_Tmap,LUT,Time)
    Event_List = []
    n_c = length(Current_Tmap);
    for c = 1:n_c
        x = find(E(3,:)==c);
        for i = 1:length(x)
            if E(2,x(i)) < 0
                Pp = -E(2,x(i));
            else
                Pn = E(2,x(i));
            end
        end
        Tc = Current_Tmap(c);
        x = Tc / (LUT(end,c,c)+45);
        Event_List(2,c) = Pn-x;
        Event_List(1,c) = Time-1;
        Event_List(3,c) = c;
       
       
    end
end