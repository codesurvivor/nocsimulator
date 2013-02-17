function x = check(Lat_Core,Arch,C)
    x = 1;
    for i = 1:length(Lat_Core)
        if Lat_Core(i) > -1
            if Arch(C,i) > Lat_Core(i)
                x = 0;
            end
        end
    end    
end