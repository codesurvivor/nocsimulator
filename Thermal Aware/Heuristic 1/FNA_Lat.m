function [TaskMap,T_Q,E_List,Power_Map] = FNA_Lat(Therm_Cur,Therm_Fut,TaskQ,Cur_Alloc,Event_List,Time,F,H,alpha)
% Descrirtion of the variables used.
% N_core - Number of cores
% Therm_Cur - 1D array of Current thermal map. Temperature of core i.
% Therm_Fut - 1D array of Future thermal map. Temperature of core i.
% TaskQ -
% Cur_Alloc - 1D array giving allocation of of core i
% TaskQ - 2D array of Tasks Powers. Row 1 denotes the Id of the task. Row 2
% denotes the power expected to be dissipated by the task.
N_core = length(Therm_Cur);
[r c] = size(TaskQ);
[re ce] = size(Event_List);
T_Q = [];
E_List = [];
Power_Map = [];

for t = 1:c
    Nic = 0;
    Wt = [];
    k = 1;
    % Calculate the Weight for each idle core.
    for i = 1:N_core
        if Cur_Alloc(i) < 0
            window = zeros(1,9);
            Nic = 8;
            Nfe = 0;
            if ~(i <= 8||mod(i,8) == 1)
                window(1) = Therm_Cur(i-9);
                Nic = Nic - numel(find(Cur_Alloc == (i-9)));
            end
            if ~(i <= 8)
                window(2) = Therm_Cur(i-8);
                Nic = Nic -  numel(find(Cur_Alloc == (i-8)));
                Nfe = Nfe + numel(find(Cur_Alloc == (i-8)));
            end
            if ~(i <= 8||mod(i,8) == 0)
                window(3) = Therm_Cur(i-7);
                Nic = Nic -  numel(find(Cur_Alloc == (i-7)));
            end
            if ~(mod(i,8) == 1)
                window(4) = Therm_Cur(i-1);
                Nic = Nic -  numel(find(Cur_Alloc == (i-1)));
                Nfe = Nfe + numel(find(Cur_Alloc == (i-1)));
            end
            window(5) = Therm_Cur(i);
            Nic = Nic -  numel(find(Cur_Alloc == (i)));
            if ~(mod(i,8) == 0)
                window(6) = Therm_Cur(i+1);
                Nic = Nic -  numel(find(Cur_Alloc == (i+1)));
                Nfe = Nfe + numel(find(Cur_Alloc == (i+1)));
            end
            if ~(i >= 57||mod(i,8)==1)
                window(7) = Therm_Cur(i+7);
                Nic = Nic -  numel(find(Cur_Alloc == (i+7)));
            end
            if ~(i >= 57)
                window(8) = Therm_Cur(i+8);
                Nic = Nic -  numel(find(Cur_Alloc == (i+8)));
                Nfe = Nfe + numel(find(Cur_Alloc == (i+8)));
            end
            if ~(i >=57 || mod(i,8) == 0)
                window(9) = Therm_Cur(i+9);
                Nic = Nic -  numel(find(Cur_Alloc == (i+9)));
            end
            N = [window(2) window(4) window(6) window(8)];
            D = [window(1) window(3) window(7) window(9)];
            Tan = sum(N)/(4 - numel(find(N == 0)));
            Tad = sum(D)/(4 - numel(find(D == 0)));


            Wt(1,k) = i;
            Wt(2,k) = 0.45 * window(5) + 0.25*Tan + 0.15*Tad + 5.1*Nfe + 2.2*Nic;
            k = k + 1;
            
        end
    end
    WSet = Wt;
    WSet = sortrows(WSet',2)';
    WSet(3,:) = 0;
    for i = 1:numel(WSet(1,:))
        
        for j = Cur_Alloc(find(Cur_Alloc > 0))
               WSet(3,i) = WSet(3,i) + H(WSet(1,i),j)*F(WSet(1,i),j);
        end 
    end
%     To choose only thermal aware, we take the minimum weight from the
%     second row of selection set. For purely architecture aware, we take
%     the minimum weight from the third row of the selection set. For
%     combined effect, try a combination.

    for i = 1:numel(WSet(1,:))
        WSet(2,i) = WSet(2,i)/sum(WSet(2,:));
        WSet(3,i) = WSet(3,i)/sum(WSet(3,:));
        WSet(4,i) = alpha*WSet(2,i) + (1 - alpha)*WSet(3,i);
    end
    
    
    
    if t == 1
        Sel_core = WSet(1,1);
    else
       Sel_core = WSet(1,find(WSet(4,:) == min(WSet(4,:))));
    end
    
    
        Sel_core
    


        Cur_Alloc(Sel_core) = TaskQ(1,t);
        Power_Map(Sel_core) = TaskQ(2,t);
        
%         Update the Event List here
        Event_List(1,ce+1) = Time;
        Event_List(2,ce+1) = TaskQ(2,t);
        Event_List(3,ce+1) = Sel_core;
        [re ce] = size(Event_List);
%         TaskQ(:,t) = -1;
     
end

TaskMap = Cur_Alloc;
n = 1;
% for i = 1:c
%     if TaskQ(2,i) ~= -1
%         T_Q(:,n) = TaskQ(:,i);
%     end
%     n = n+1;
% end
T_Q = TaskQ;
E_List = Event_List;


end