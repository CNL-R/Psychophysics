
%%%%%%%%%%%
%%PHASE I%%
%%%%%%%%%%%

%The first part of the script will parse the behavioral data contained in the
%presentation log files. The script will iterate over a root folder containing
%folders for each individual participant.

clear all                                              %clear all workspace variables

direc = uigetdir;                                      %get the directory containing all of the participant folders
folders = dir(direc);
id = {folders([folders(:).isdir]).name};               %get the names of the folders in the root directory, ignore anything else
id(ismember(id,{'.','..'})) = [];                      %if the root folder is not actually a root (it almost always won't be), remove the "." and ".." entries.

nconds = 14;                                           %14 conditions (0=error, 1=click, 2=audio only, 3=visual only, 4=audiovisual only....)
ncondsSeparate = 30;                                    %number of separate analysis conditions, 1 = VVV, 2 = AVV, 3 = AAA, 4 = VAA
removethresh = 100;                                    %ms threshold for physiologically possible responses
data = [];                                             %create empty data array, this will hold all the data in the order of the files, then stimuli, as presented
indcell = {};                                          %placeholder for incoming individual participant data, will be stored in cell array as different participants will have different numbers of trials
inddata = [];                                          %place holder for incoming mean individual data, this is a standard array as each participant will have 1 mean, 1 std for each condition.
%Putting filtered data into indseqcondcell
indseqcondcell = cell(size(id,2),nconds,nconds);

for j = 1:size(id,2)                                   %loop iterating through individual data directories
    filelist = ls(fullfile(direc,id{j},'*log'));       %list the files in the directory that end with the .log extension
    indalltrials = [];                                 %placeholder for incoming data
    for i = 1:size(filelist,1)                         %loop to process files
        [struct, cond] = importPresentationLog(fullfile(direc,id{j},filelist(i,:))); %load the files
        
        if isfield(cond,'code')                        %make sure file actually has data by checking if the appropriate fields exist, if not do nothing, go to the next file
            responseidx = find(strcmp('1',cond.code)); %!!!my code looks for responses, not stimuli!!!
            
            if responseidx(1) == 1                     %if a response was the first thing in the file
                responseidx = responseidx(2:end);      %dump it, there was no preceding stimulus...
            end
            


            
            tempdata = [];                             %another temporary placeholder for incoming data
            tempdata(:,1) = str2double(cond.code(responseidx-1)); %take the event code from the event preceding the response (if a person clicks twice the second click is given a click code, not a stim!)
            tempdata(:,2) = cond.ttime(responseidx)/10;           %take the ttime from the response, divide by 10 to give in ms
            for p = 1:length(responseidx)                         %this loop manages the extraction of the ISI for each trial
                if responseidx(p) == 2                            %however, if it was the first stimulus, there was no ISI...
                    tempdata(p,3) = 0;                            %so set the ISI to zero
                else                                              %otherwise...
                    tempdata(p,3) = (cond.time(responseidx(p))-cond.time(responseidx(p)-2))/10; %The ISI is calculated from the time stamps on the events in the .log file.
                end
            end
            
            indalltrials = vertcat(indalltrials,tempdata); %concatenate temporary array to growing data array
            
            data = vertcat(data,tempdata);                 %concatenate the temporary data to the growing data array
        end
        
    end
    alltrials{j,:} = indalltrials; %Stores all individual trial data for each participant for each individual array the dimensions are - trials x [trigger-value reaction-time ISI-from-prev-stim]
    
                                                            %NOTE: WE ARE STILL INSIDE THE INDIVIDUAL PARTICIPANT LOOP; for this participant, find the trials where the response was less than removethresh
    indpossible = indalltrials;   
                  
    
    indpossibleSeparateIndex = 1;
    indpossibleSeparate = [];
    
    pureBlocks = [2,3,4];
    pureSwitchBlocks = [22,23;33,36;32,34];
    mixedBlocks = [5,7,8,10;48,49,51,52;56,57,62,63];
    
    removeindx = [];
    removeResponseIndx = [];
    
    %Loop to remove all 1's and 252s(from double responses)
    for i = 1:size(indpossible)
        if indpossible(i, 1) == 1 || indpossible(i, 1) == 252
            removeResponseIndx = [removeResponseIndx i];
        end 
    end
    indpossible(removeResponseIndx,:) = [];
    
    %Loop to remove all start of block outliers 
    for i = 2:size(indpossible)
            %Checking pureblocks for start of block outliers and building a list of indexes for those to be removed
            for pureBlocksIndx = 1:numel(pureBlocks)
                if indpossible(i, 1) == pureBlocks(pureBlocksIndx) && indpossible(i-1, 1) ~= pureBlocks(pureBlocksIndx)
                    removeindx = [removeindx i];
                end
            end
            
            %Checking pureswitchblocks for start of block outliers and building a list of indexes for those to be removed
            for pureSwitchIndx1 = 1:size(pureSwitchBlocks,1)
                for pureSwitchIndx2 = 1:size(pureSwitchBlocks,2)
                    if indpossible(i,1) == pureSwitchBlocks(pureSwitchIndx1,pureSwitchIndx2) && numel(find(pureSwitchBlocks(pureSwitchIndx1, :) == indpossible(i - 1, 1))) == 0
                        removeindx = [removeindx i];
                    end 
                end 
            end
            
            %Checking mixedblocks for start of block outliers and building a list of indexes for those to be removed
            for mixedBlocksIndx1 = 1:size(mixedBlocks,1)
                for mixedBlocksIndx2 = 1:size(mixedBlocks,2)
                    if indpossible(i,1) == mixedBlocks(mixedBlocksIndx1,mixedBlocksIndx2) && numel(find(mixedBlocks(mixedBlocksIndx1,:) == indpossible(i - 1,1))) == 0
                        removeindx = [removeindx i];
                    end
                end
            end
    end
    
    %removing using removeindx
    indpossibleCopy = indpossible; %making copy of indpossible for future reference
    indpossible(removeindx, :) = [];
    
    indremoveidx = find(indpossible(:,2)<removethresh);    %Removing stimuli below threshold down here because before, a below threshold stimulus was
    indpossible(indremoveidx,:) = [];                           %before precedence logic was checked, causing massive issues.
    
    %Extracting n-2 trials to indseqcondcell
    for k = 2:length(indpossible)
        cond = indpossible(k,1);
        previousCond = indpossible(k-1, 1);
        indseqcondcell{j,previousCond, cond} = [indseqcondcell{j, previousCond, cond}; indpossible(k, 2)];
    end
    

    %@LOOP TO EXTRACT n - 2 trials
    for i = 1:size(indpossible)
        if i > 1
            if (indpossible(i, 1) == 7) && (indpossible(i-1, 1) == 7) %@AAA
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 1;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 7) && (indpossible(i-1, 1)  == 5) %@VAA
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 2;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 5) && (indpossible(i-1, 1)  == 10) %@AVA
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 3;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 5) && (indpossible(i-1, 1)  == 8) %@VVA
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 4;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 7) && (indpossible(i-1, 1)  == 6) %@AV-A-A
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 5;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;       
            elseif (indpossible(i, 1) == 6) && (indpossible(i-1, 1)  == 13) %@A-AV-A
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 6;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 5) && (indpossible(i-1, 1)  == 9) %@AV-V-A
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 7;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 6) && (indpossible(i-1, 1)  == 11) %@V-AV-A
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 8;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 6) && (indpossible(i-1, 1)  == 12) %@AV-AV-A
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 9;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 8) && (indpossible(i-1, 1)  == 8) %@VVV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 11;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 8) && (indpossible(i-1, 1)  == 10) %@AVV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 12;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;   
            elseif (indpossible(i, 1) == 10) && (indpossible(i-1, 1)  == 5) %@VAV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 13;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;  
            elseif (indpossible(i, 1) == 10) && (indpossible(i-1, 1)  == 7) %@AAV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 14;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;    
            elseif (indpossible(i, 1) == 8) && (indpossible(i-1, 1)  == 9) %@AV-V-V
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 15;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;    
            elseif (indpossible(i, 1) == 9) && (indpossible(i-1, 1)  == 11) %@V-AV-V
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 16;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;  
            elseif (indpossible(i, 1) == 10) && (indpossible(i-1, 1)  == 6) %@AV-A-V
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 17;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;        
            elseif (indpossible(i, 1) == 9) && (indpossible(i-1, 1)  == 13) %@A-AV-V
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 18;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;     
            elseif (indpossible(i, 1) == 9) && (indpossible(i-1, 1)  == 12) %@AV-AV-V
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 19;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;    
            elseif (indpossible(i, 1) == 12) && (indpossible(i-1, 1) == 12) %@AV-AV-AV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 21;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 12) && (indpossible(i-1, 1)  == 13) %@A-AV-AV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 22;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 13) && (indpossible(i-1, 1)  == 6) %@AV-A-AV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 23;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 13) && (indpossible(i-1, 1)  == 7) %@A-A-AV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 24;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 12) && (indpossible(i-1, 1)  == 11) %@V-AV-AV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 25;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;       
            elseif (indpossible(i, 1) == 11) && (indpossible(i-1, 1)  == 9) %@AV-V-AV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 26;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 11) && (indpossible(i-1, 1)  == 8) %@V-V-AV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 27;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 11) && (indpossible(i-1, 1)  == 10) %@A-V-AV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 28;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;
            elseif (indpossible(i, 1) == 13) && (indpossible(i-1, 1)  == 5) %@V-A-AV
                indpossibleSeparate(indpossibleSeparateIndex, 1) = 29;
                indpossibleSeparate(indpossibleSeparateIndex, 2) = indpossible(i, 2);
                indpossibleSeparate(indpossibleSeparateIndex, 3) = indpossible(i, 3);
                indpossibleSeparate(indpossibleSeparateIndex, 4) = i;
                indpossibleSeparateIndex = indpossibleSeparateIndex + 1;                
            end
            
        end
    end
    
    %Removing physiologically impossible responses from indpossibleSeparate
    %for good mesasure
    indremoveidxSeparate = find(indpossibleSeparate(:,2)<removethresh);
    indpossibleSeparate(indremoveidxSeparate,:) = [];
    
    indcell{j} = indpossible;                            %store the individual participant realistic data in the growing "indcell" cell array, which will contain all individual trial data for all participants
    indcellSeparate{j} = indpossibleSeparate;                           %@creating indcellSeparate which is going to contain only trials of separate analysis we are interested in like VVV, AVV, etc...
    
    
    for k = 1:nconds                                     %calculate the mean reaction times across participants for each condition
        
        indcondidx = find(indpossible(:,1)==k-1);
        inddata(j,k,:) = [mean(indpossible(indcondidx,2)) std(indpossible(indcondidx,2)) length(indcondidx)]; %store the mean reaction times for each participant for each condition in the inddata array
    end
    
    for k = 1:ncondsSeparate                                     %@calculate the mean reaction times across participants for each Separate analysis condition (VVV, AAA, AVV, VAA, etc..)
        indcondidxSeparate = find(indpossibleSeparate(:,1)==k);
        inddataSeparate(j,k,:) = [mean(indpossibleSeparate(indcondidxSeparate,2)) std(indpossibleSeparate(indcondidxSeparate,2)) length(indcondidxSeparate)]; %store the mean reaction times for each participant for each condition in the inddata array
    end

    %virtualconditions - the next three loops manage the creation of what
    %I'm calling "virual conditions", these are merely lumping all of the
    %presentations of each stimulus type A, V, AV into a single respective
    %condition (i.e. I'm throwing out the trial history considerations, so
    %A-A, V-A, and AV-A, all get lumped into mixed-A). This occurs so that
    %a mean reaction time for the mixed conditions can be quickly computed
    %at the individual level and added to the "inddata" array.

end %THIS IS THE END OF THE INDIVIDUAL PARTICIPANT LOOP, once this loop completes all of the individual participant data has been extracted and organized.

allremoveidx = find(data(:,2)<removethresh);       %This removes unrealistic responses from the "data" array, which contains ALLLLLL of the trials from all participants, just a big 'ol pile 'o trials
allpossibledata = data;
allpossibledata(allremoveidx,:) = [];              %We're not going to do anything meaningful with this data yet, but it's cool to look at the data from this perspective (all trials drawn from one big distribution)


allmeandata = [];                                  %create array for averages, again this is for the pile 'o trials data, which we won't be doing much with
for i = 1:nconds                                   %for every condition
    allcondidx = find(indpossible(:,1)==i-1);
    allmeandata(i,:) = [mean(inddata(:,i,1)) std(inddata(:,i,1)) length(allcondidx)]; %take the mean of the data for each condition (first column), the SD (second column, and give the n (third)
end

for i = 1:ncondsSeparate

    groupmeandataSeparate(i, :) = [mean(inddataSeparate(:, i, 1)) std(inddataSeparate(:, i, 1))];
end
outputSeparate = groupmeandataSeparate;
outputSeparate(:, 3) = 1:size(outputSeparate, 1)
output = allmeandata;
output(:, 4) = 0:nconds - 1

filename = 'nm2AllConds.xlsx';
xlswrite(filename,outputSeparate(:,1:2),1,'B1:C30');
xlswrite(filename,output(:,1:2),1,'F1:G14');
xlswrite(filename,inddataSeparate(:,:,1),1,'J2:AM35');
xlswrite(filename,inddata(:,:,1),1,'J40:W73');