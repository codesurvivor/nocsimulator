function T_Map_C = Thermal_Map_Modeller(Tmap)
    [r c] = size(Tmap);
    if r == 1
%       The input is single vector with temperatures of each of the cores.
%       No need for any modelling; this can be used as is.
        T_Map_C = Tmap;
    else
%       The input is a matrix. Actual positional map. In this case we re
%       model the input to a vector as needed. we go in row major style or
%       reading.
        T_Map_C = reshape(Tmap,1,r*c);
    end
        
end