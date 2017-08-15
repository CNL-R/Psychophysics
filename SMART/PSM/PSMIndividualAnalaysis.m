%For running after PureSwitchNM2Analysis.m

%Writing all Individuals' data to excel sheet. 
xlswrite('C:\Users\achen52\Documents\SMART\PSMn12.xlsx', inddata(:,[3,4,5,6,8,9,11,23,24,33,34,35,37,49,50,52,53,57,58,63,64],1),2,'C2')

%t-tests to see who has significant switch costs. conds have to be ++1 because inddata starts indexing at cond 0
%Auditory Switch Costs
for i = 1:size(inddata,1)
    [hA(i),pA(i)] = ttest2(indcell{i}(find(indcell{i}(:,1) == 7),2),indcell{i}(find(indcell{i}(:,1) == 5),2));
end
%Visual Switch Costs
for i = 1:size(inddata,1)
    [hV(i),pV(i)] = ttest2(indcell{i}(find(indcell{i}(:,1) == 8),2),indcell{i}(find(indcell{i}(:,1) == 10),2));
end
%Writing to excel
xlswrite('C:\Users\achen52\Documents\SMART\PSMn12.xlsx', pA',2,'C23:C34');
xlswrite('C:\Users\achen52\Documents\SMART\PSMn12.xlsx', pV',2,'C40:C51');


%t-tests to test colavita effect and unexpectancy
%Auditory Colavita
for i = 1:size(inddata,1)
    [hAC(i),pAC(i)] = ttest2(indcell{i}(find(indcell{i}(:,1) == 2),2),indcell{i}(find(indcell{i}(:,1) == 22),2));
end
%Auditory Unexpectancy
for i = 1:size(inddata,1)
    [hAU(i),pAU(i)] = ttest2(indcell{i}(find(indcell{i}(:,1) == 22),2),indcell{i}(find(indcell{i}(:,1) == 5),2));
end
xlswrite('C:\Users\achen52\Documents\SMART\PSMn12.xlsx', pAC',2,'I23:I34');
xlswrite('C:\Users\achen52\Documents\SMART\PSMn12.xlsx', pAU',2,'J23:J34');
%Visual Colavita
for i = 1:size(inddata,1)
    [hVC(i),pVC(i)] = ttest2(indcell{i}(find(indcell{i}(:,1) == 3),2),indcell{i}(find(indcell{i}(:,1) == 23),2));
end
%Auditory Unexpectancy
for i = 1:size(inddata,1)
    [hVU(i),pVU(i)] = ttest2(indcell{i}(find(indcell{i}(:,1) == 23),2),indcell{i}(find(indcell{i}(:,1) == 10),2));
end
xlswrite('C:\Users\achen52\Documents\SMART\PSMn12.xlsx', pVC',2,'I40:I51');
xlswrite('C:\Users\achen52\Documents\SMART\PSMn12.xlsx', pVU',2,'J40:J51');