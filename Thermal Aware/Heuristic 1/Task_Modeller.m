function Task_Queue = Task_Modeller(T)
% T is an array of Powers of each thread/Task
% Additionally second row of T can denote the completion if possible
[r c] = size(T);
% r gives number of rows and decides if completions are present or not
% c gives the number of threads.
Tm = [];
if(r == 1)
   Tm(:,1) = (1:c)';   
   Tm(:,2) = T';
%    Tm(:,3) = T_times';
   Task_Queue = sortrows(Tm,-2);
   Task_Queue = Task_Queue';
else
%     Future Code here to modulate completions if possible
end

end
