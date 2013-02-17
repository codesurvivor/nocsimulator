function [TaskMap,T_Q,E_List,Power_Map] = FTT_Lat(Therm_Cur,Therm_Fut,TaskQ,Cur_Alloc,Event_List,Time,F,H,alpha)
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
    Twp = [];
    Twn = [];
    wl = zeros(2,N_core);
    p = 1;
    n = 1;
    l = 1;
    % Calculate the Weight for each idle core.
    for i = 1:N_core
        if Cur_Alloc(i) < 0
           a = Therm_Fut(i)  - Therm_Cur(i);
           if a >= 0
               Twp(1,p) = i;
               Twp(2,p) = Therm_Cur(i)*a;
               p = p+1;
           else
               Twn(1,n) = i;
               Twn(2,n) = Therm_Cur(i)/a;
               n = n+1;
           end
           
           
        end
    end
    WSet = [];
    if numel(Twp) ~= 0
        Twp = sortrows(Twp',2)';
    end
    if numel(Twn) ~= 0
        Twn = sortrows(Twn',2)';
    end
    
    WSet = [Twn Twp];
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
