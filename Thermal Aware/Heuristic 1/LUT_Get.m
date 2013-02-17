% LName = '\5W_TransientData\hotspotUImesh_';     % The Name of folder and files for LUT.
% 
% LUT = [];
% tmp = [];
% for i = 1:64
%    tmp = xlsread([LName num2str(i-1) '_5W.xls'],'TTRACE');
%    tmp = (tmp-45)./5;
%    LUT(:,:,i) = tmp(1:2505,1:64);
% end
[r c t] = size(LUT);
for i = 1:t
    for j = 1:r-1
        
        if max(LUT(j+1,:,i)) > 2
            LUT(j+1,:,i) = LUT(j,:,i);
        end
    end
end