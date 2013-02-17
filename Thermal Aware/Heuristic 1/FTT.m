function [TaskMap,T_Q,E_List,Power_Map] = FTT(Therm_Cur,Therm_Fut,TaskQ,Cur_Alloc,Event_List,Time)
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
    p = 1;
    n = 1;

    % Calculate the Weight for each idle core.
    for i = 1:N_core
        if Cur_Alloc(i) < 0
           a = Therm_Fut(i) - Therm_Cur(i);
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
    
    Selection_Set = [];
    if numel(Twp) ~= 0
        temp1 = min(Twp(2,:));
        Selection_Set = Twp(1,find(Twp(2,:) == temp1));
    end
    if numel(Twn) ~= 0
        temp2 = min(Twn(2,:));
        Selection_Set = [Selection_Set Twn(1,find(Twn(2,:) == temp2))];
    end
    if numel(Selection_Set) ~= 0
        Sel_core = Selection_Set(randi(numel(Selection_Set)));
        Cur_Alloc(Sel_core) = TaskQ(1,t);
        Power_Map(Sel_core) = TaskQ(2,t);
        
%         Update the Event List here
        Event_List(1,ce+1) = Time;
        Event_List(2,ce+1) = TaskQ(2,t);
        Event_List(3,ce+1) = Sel_core;
        [re ce] = size(Event_List);
%         TaskQ(:,t) = -1;
    end
     
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
