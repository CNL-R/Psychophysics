clear all

conditions = [1 2 3];
%1 = A
%2 = V
%3 = AV
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

minimum = 50;
tripleSequencesPool = repmat(tripleSequences, minimum, 1);
numberTripleSequences = size(tripleSequencesPool,1);
shuffler = randperm(numberTripleSequences);
tripleSequencesPool = tripleSequencesPool(shuffler, :);
trialMatrix = [];
for i = 1:numberTripleSequences
    trialMatrix = [trialMatrix tripleSequencesPool(i,:)];
end 
numberTrials = size(trialMatrix, 2);

counterMatrix = zeros(3,3,3);
for i = 3:numberTrials
    nm2 = trialMatrix(i - 2);
    nm1 = trialMatrix(i - 1);
    n = trialMatrix(i);
    counterMatrix(nm2, nm1, n) = counterMatrix(nm2, nm1, n) + 1;
end 

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
