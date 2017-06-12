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

nconds = 4;                                           %14 conditions (0=error, 1=click, 2=audio only, 3=visual only, 4=audiovisual only....)
removethresh = 100;                                    %ms threshold for physiologically possible responses
data = [];                                             %create empty data array, this will hold all the data in the order of the files, then stimuli, as presented
indcell = {};                                          %placeholder for incoming individual participant data, will be stored in cell array as different participants will have different numbers of trials
inddata = [];                                          %place holder for incoming mean individual data, this is a standard array as each participant will have 1 mean, 1 std for each condition.
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
    
    indremoveidx = find(indalltrials(:,2)<removethresh); %NOTE: WE ARE STILL INSIDE THE INDIVIDUAL PARTICIPANT LOOP; for this participant, find the trials where the response was less than removethresh
    indpossible = indalltrials;                          %create a new array that will only have realistic responses
    indpossible(indremoveidx,:) = [];                    %remove the unrealistic responses
    
    indcell{j} = indpossible;                            %store the individual participant realistic data in the growing "indcell" cell array, which will contain all individual trial data for all participants
    
    for k = 1:nconds                                     %calculate the mean reaction times across participants for each condition
        indcondidx = find(indpossible(:,1)==k-1);
        inddata(j,k,:) = [mean(indpossible(indcondidx,2)) std(indpossible(indcondidx,2)) length(indcondidx)]; %store the mean reaction times for each participant for each condition in the inddata array
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
    allcondidx = find(allpossibledata(:,1)==i-1);
    allmeandata(i,:) = [mean(allpossibledata(allcondidx,2)) std(allpossibledata(allcondidx,2)) length(allcondidx)]; %take the mean of the data for each condition (first column), the SD (second column, and give the n (third)
end

%%%%%%%%%%%%
%%PHASE II%%
%%%%%%%%%%%%

% With the data extracted from the .log files, it is now time to sort
% the individual participant data into their respective conditions
% the cells below contain, for each participant, all of the trials with
% realistic reaction times for that condition, sorted by participant

for i = 1:length(indcell)
    pureAcell{i} = indcell{i}(find(indcell{i}(:,1)==2),:);
    pureVcell{i} = indcell{i}(find(indcell{i}(:,1)==3),:);
    pureAVcell{i} = indcell{i}(find(indcell{i}(:,1)==4),:);
    V2Acell{i} = indcell{i}(find(indcell{i}(:,1)==5),:);
    AV2Acell{i} = indcell{i}(find(indcell{i}(:,1)==6),:);
    A2Acell{i} = indcell{i}(find(indcell{i}(:,1)==7),:);
    V2Vcell{i} = indcell{i}(find(indcell{i}(:,1)==8),:);
    AV2Vcell{i} = indcell{i}(find(indcell{i}(:,1)==9),:);
    A2Vcell{i} = indcell{i}(find(indcell{i}(:,1)==10),:);
    V2AVcell{i} = indcell{i}(find(indcell{i}(:,1)==11),:);
    AV2AVcell{i} = indcell{i}(find(indcell{i}(:,1)==12),:);
    A2AVcell{i} = indcell{i}(find(indcell{i}(:,1)==13),:);
    mixAcell{i} = vertcat(V2Acell{i}, AV2Acell{i}, A2Acell{i});
    mixVcell{i} = vertcat(V2Vcell{i}, AV2Vcell{i}, A2Vcell{i});
    mixAVcell{i} = vertcat(V2AVcell{i}, AV2AVcell{i}, A2AVcell{i});
    switchAVcell{i} = vertcat(V2AVcell{i}, A2AVcell{i});
end
