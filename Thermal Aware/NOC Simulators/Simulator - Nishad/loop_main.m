clc;
clear all;

global SimulationResultHistory; 
SimulationResultHistory=[];

for i=1:1:2
    SimulationResultHistory=[SimulationResultHistory
        simulator_main_mesh_function()];
end

