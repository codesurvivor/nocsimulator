clc;
clear all;


% Get Inputs here
n_c = 64;       % Number of Cores
LName = '\5W_TransientData\hotspotUImesh_';     % The Name of folder and files for LUT.
Thermal_Map = 45 * ones(1,n_c);
% T_in = randi(20,1,64);

T_in = [15 15 15 15 15 15 16 17 17 2 3 14 15 9 10 4 15 19 12 12 15 15 15 1 2 8 15 15 15 15 16 17 18 18 18 12 14 15 12 12 14 19 14 14 14 13 12 15 15 15 15 15 15 12 12 15 15 15 13 12 13 16 12 11 17];




% Send to Modellers.
Task_Queue = Task_Modeller(T_in);
Current_Tmap = Thermal_Map_Modeller(Thermal_Map);
Future_Tmap = Current_Tmap;

% LUT = [];
% tmp = [];
% for i = 1:n_c
%    tmp = xlsread([LName num2str(i-1) '_5W.xls'],'TTRACE');
%    tmp = tmp./5;
%    LUT(:,:,i) = tmp(1:2505,1:64);
% end
load LUT.mat



% Global Variables
Event_List = [];
Alloc_Map =-ones(1,n_c);
Sim_Time = 1;
% Sim_Dur = 2000 ;
Steady_Time = 1000;
Trig = 0;
Threshold = 20;


% Run FTT to allocate tasks to all cores.
[Alloc_Map,Task_Queue,Event_List] = FTT(Current_Tmap,Future_Tmap,Task_Queue,Alloc_Map,Event_List,Sim_Time);
Sim_Time = Sim_Time + 1;
Current_Tmap = Thermal_Map_Gen(Current_Tmap,2,1,Event_List,LUT);
Future_Tmap = Thermal_Map_Gen(Current_Tmap,3,2,Event_List,LUT);
figure;

while Sim_Time < 5000
   Current_Tmap = Thermal_Map_Gen(Current_Tmap,Sim_Time,Sim_Time - 1,Event_List,LUT);
   if Trig < 0
%        Event_List = [];
       Alloc_Map =-ones(1,n_c);
       Future_Tmap = Thermal_Map_Gen(Current_Tmap,Sim_Time+1,Sim_Time,Event_List,LUT);
       [Alloc_Map,Task_Queue,Event_List] = FTT(Current_Tmap,Future_Tmap,Task_Queue,Alloc_Map,Event_List,Sim_Time);
       Current_Tmap = Thermal_Map_Gen(Current_Tmap,Sim_Time+1,Sim_Time,Event_List,LUT);
       Trig = 0;
   end
       
       
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
   
   if max(Current_Tmap) - min(Current_Tmap) > Threshold
       Trig = -1;
       Event_List(2,:) = -Event_List(2,:);
   end
   Sim_Time = Sim_Time + 1
   surf(reshape(Current_Tmap,8,8)');
   refresh;     
    
end



