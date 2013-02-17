clc;
clear all;

load config.mat;
load LUT.mat;

Init_Tmap = Config(:,2)';
Init_Alloc = 1:64;
Init_TaskQ = Config(:,1)';
n_c = 64;

Steady = 800;
F = xlsread('F_Data.xlsx','In Order - fij');
F = F./sum(sum(F));
load H.mat
alpha = 1;

Alloc_Map = -ones(1,n_c);
Pmap = [];
% Generate temperory Event list.
Event_List = [];
for c = 1:n_c
   Event_List(3,c) = c;
   Event_List(2,c) = Init_TaskQ(c);
   Event_List(1,c) = Steady;
end

Future_Tmap = Thermal_Map_Gen(Init_Tmap,Steady+2,Steady,Event_List,LUT);
Task_Queue = Task_Modeller(Init_TaskQ);
x = find(Event_List(2,:)>0);
Event_List(2,x) = -Event_List(2,x);
Event_List(1,x) = Steady;
[Alloc_Map,Task_Queue,Event_List,Pmap] = FTT_Lat(Init_Tmap,Future_Tmap,Task_Queue,Alloc_Map,Event_List,Steady,F,H,alpha);

Future_Tmap = Thermal_Map_Gen(Init_Tmap,Steady+800,Steady,Event_List,LUT);
Event_List(:,find(Event_List(2,:) < 0)) = [];

FTmap = Thermal_Map_Gen1(Init_Tmap,Event_List,LUT);
Pmap = Pmap';
Alloc_Map = Alloc_Map';
Future_Tmap = Future_Tmap';
FTmap = FTmap';




