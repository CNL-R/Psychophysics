%This script stimulates a trial history generation technique that aims to have the amount of trials for each type of triple sequence be as close to each other as possible 
%The strategy is to take the set of 27 possible triple sequences and generate a pool of triple sequences by multiplying by a scalar number, X to yield 27 * X triple sequences. 
%Then, triple sequences are removed from this pool one at a time and added to a growing trial history matrix. After each removal of a new triple sequence, the two additional 
%triple sequences created from the nm1, nm2, nm3 and nm2,nm3,nm4 trials are also removed from the pool. 

clear all

conditions = [1 2 3];
%1 = A
%2 = V
%3 = AV

%Generating tripleSequences, a 27x3 Matrix that classifies each triple sequence with its corresponding nm2, nm1, and n trial types
counter = 0;
tripleSequences = zeros(27,3);
for i = 1:3
    for j = 1:3
        for k = 1:3
            counter = counter + 1;
            tripleSequences(counter,:) = [conditions(i) conditions(j) conditions(k)];
        end
    end
end

%Generating tripleSequencesPool
minimum = 18;
tripleSequencesPool = repmat(tripleSequences, minimum*3, 1);
numberTripleSequences = size(tripleSequencesPool,1);
shuffler = randperm(numberTripleSequences);
tripleSequencesPool = tripleSequencesPool(shuffler, :);
tripleSequencesPoolCopy = tripleSequencesPool;

%Main loop to remove triple sequences from the tripleSequencesPool and add them to the growing trial history matrix, trialMatrix
trialMatrix = [];
for j = 1:minimum*27
    matchindcs = [];
    trialMatrix = [trialMatrix tripleSequencesPool(1,:)];
    for i = 0:2
        if numel(trialMatrix) > 3
            nm2 = trialMatrix(end - i - 2);
            nm1 = trialMatrix(end - i - 1);
            n = trialMatrix(end - i);
        elseif numel(trialMatrix) == 3
            nm2 = trialMatrix(end - 2);
            nm1 = trialMatrix(end - 1);
            n = trialMatrix(end);
        end
        [Lia Locb] = ismember([nm2 nm1 n], tripleSequencesPool, 'rows');
        matchindcs = Locb;
        if numel(matchindcs) > 0 && Locb > 0
            removeindx = matchindcs(1);
            tripleSequencesPool(removeindx, :) = [];
        end
    end
end
numberTrials = size(trialMatrix, 2);

%Counts the number of trials per each triple sequence type
counterMatrix = zeros(3,3,3);
for i = 3:numberTrials
    nm2 = trialMatrix(i - 2);
    nm1 = trialMatrix(i - 1);
    n = trialMatrix(i);
    counterMatrix(nm2, nm1, n) = counterMatrix(nm2, nm1, n) + 1;
end

%Plots a line graph of the number of trials per each triple sequence type
counter = 0;
xAxis = zeros(1,27);
yAxis = xAxis;
for i = 1:3
    for j = 1:3
        for k = 1:3
            counter = counter + 1;
            xAxis(counter) = counter;
            yAxis(counter) = counterMatrix(i, j, k);
        end
    end
end
figure;
plot(xAxis, yAxis);
drawnow;
%% Exporting as .txt file 
Outdir = uigetdir('C:\Users\achen52\Documents\SMART\triplesequence\','Select Output Directory for the .txts!'); 
trialsPerBlock = 54;
blocks = fix(size(trialMatrix,2)/trialsPerBlock);
block = 1;
%trialMatrix = trialMatrix';
for block = 1:blocks
    fileID = fopen([Outdir '\block' num2str(block) '.txt'],'w');
    for j = 1:trialsPerBlock
        fprintf(fileID,'%d\r\n',trialMatrix((block-1)*trialsPerBlock + j));
    end
    fclose(fileID)
end



