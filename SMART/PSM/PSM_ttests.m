%To be run in conjunction with PureSwitchNM2Analysis. Uses inddata for ttest
cond1 = 8;
cond2 = 10;

group1 = inddata(:,cond1 + 1,1);
group2 = inddata(:,cond2 + 1,1);

[h,p] = ttest(group1, group2)

%% Difference Analysis
condA1 = 3;
condA2 = 8;
groupA = inddata(:,condA2 + 1, 1) - inddata(:,condA1 + 1,1);

condB1 = 22;
condB2 = 5;
groupB = inddata(:,condB2 + 1, 1) - inddata(:,condB1 + 1,1);

[h,p] = ttest(groupA, groupB)
