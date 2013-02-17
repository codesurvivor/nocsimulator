clc;
clear all;


% Get Inputs here
n_c = 64;       % Number of Cores
LName = '\5W_TransientData\hotspotUImesh_';     % The Name of folder and files for LUT.
Thermal_Map = 45 * ones(1,n_c);
% T_in = randi(15,1,64);
load Task.mat
% T_in = [15 15 15 4 4 4 16 17 17 2 3 14 15 9 10 4 15 19 12 12 15 15 15 1 2 8 10 10 10 10 16 17 18 18 18 12 14 15 12 12 14 19 14 14 14 13 12 15 15 15 15 15 15 12 12 15 15 15 13 12 13 16 12 11 17];


load LUT.mat;

% Send to Modellers.
Task_Queue = Task_Modeller(Task);
Current_Tmap = Thermal_Map_Modeller(Thermal_Map);
Future_Tmap = Current_Tmap;
Power_Map = [];
% LUT = [];
% tmp = [];
% for i = 1:n_c
%    tmp = xlsread([LName num2str(i-1) '_5W.xls'],'TTRACE');
%    tmp = tmp;
%    LUT(:,:,i) = tmp(1:2505,1:64);
% end




% Global Variables
Event_List = [];
Alloc_Map =[];
Alloc_Out = [];
Sim_Time = 2;
% Sim_Dur = 2000 ;
Steady_Time = 1000 ;
Trig = -1;
Threshold = 1;
Trig_Hold = 0;
Realloc = 0;
Pmap = [];
% Run FTT to allocate tasks to all cores.
% [Alloc_Map,Task_Queue,Event_List] = FTT(Current_Tmap,Future_Tmap,Task_Queue,Alloc_Map,Event_List,Sim_Time);
figure;
r = 1;
while Sim_Time < 1500
    
   if Trig < 0
%        Event_List = [];
       Alloc_Map =-ones(1,n_c);
       Future_Tmap = Thermal_Map_Gen(Current_Tmap,Sim_Time+3,Sim_Time,Event_List,LUT);
       [Alloc_Map,Task_Queue,Event_List,Pmap] = FTT(Current_Tmap,Future_Tmap,Task_Queue,Alloc_Map,Event_List,Sim_Time-1);
%        if Realloc < 0
%            Event_List = Event_List_Gen(Event_List,Current_Tmap,LUT,Sim_Time);
%        end
       Alloc_Out(r,:) = Alloc_Map;

       Current_Tmap = Thermal_Map_Gen(Current_Tmap,Sim_Time,Sim_Time-1,Event_List,LUT);
       Trig = 0;
       Trig_Hold = 0;
   else
       Current_Tmap = Thermal_Map_Gen(Current_Tmap,Sim_Time,Sim_Time-1,Event_List,LUT);
   end
   Power_Map = cat(1,Power_Map,Pmap);    
       
   [re ce] = size(Event_List);
   ae = 1;
   while ae <= ce
       if Sim_Time - Event_List(1,ae) > Steady_Time
           Event_List(:,ae) = [];
           [re ce] = size(Event_List);
       else
           ae = ae+1;
       end
       [re ce] = size(Event_List);
   end
   
   if max(Current_Tmap) - min(Current_Tmap) > Threshold && Trig_Hold > 800
       Trig = -1;
       Event_List(:,find(Event_List(2,1:64) < 0)) = [];
%        Realloc = -1;
       r = r+1;
       x = find(Event_List(2,:)>0);
       Event_List(2,x) = -Event_List(2,x);
       Event_List(1,x) = Sim_Time;
   end
   Trig_Hold = Trig_Hold + 1;
   Sim_Time = Sim_Time + 1
   surf(reshape(Current_Tmap,8,8)');
   refresh;     
    
end
xlswrite('ReAlloc1Mesh.xls',Power_Map,'PTRACE');
xlswrite('ReAlloc1Mesh.xls',Alloc_Out,'Allocations');


