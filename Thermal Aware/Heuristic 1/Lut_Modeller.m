function LUT = Lut_Modeller(,ncore)
    LUT = [];
    
    for i = 1:ncore
       LUT(:,:,i) = xlsread([filename num2str(i-1) '_5W.xls'],'TTRACE');
       LUT(:,:,i) = LUT(:,:,i)./5;
    end
    
end