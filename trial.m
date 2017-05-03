clc
noofOriginalJobs = input('Enter Number of Original Jobs: ');
noofStages = input('Enter Number of Stages: ');
noofMachines = zeros(1,noofStages);
for i=1:noofStages
    noofMachines(i) = input(sprintf('Enter number of Machines in stage %d: ',i));
end
totalMachines = sum(noofMachines);
%inputTime = zeros(noofOriginalJobs,totalMachines);inputEnergy = zeros(noofOriginalJobs,totalMachines);
%for i=1:noofOriginalJobs
%   for j=1:totalMachines
%     inputTime(i,j) = input(sprintf('Enter makespan of job %d and machine %d: ',i,j));
%     inputEnergy(i,j) = input(sprintf('Enter enery consumed by job %d and machine %d: ',i,j));
%   end
%end
inputTime
inputEnergy
maxMachines=cumsum(noofMachines);
minMachines=maxMachines-noofMachines+ones(1,noofStages);
position = rand(noofOriginalJobs,noofStages,50);

for i=1:50
    for j=1:int16(noofStages)
        position(:,j,i)=minMachines(j)+position(:,j,i)*[maxMachines(j)-minMachines(j)] + position(:,j,i);
    end
end

%get  encoded matrices
q = getQ(position);
p = getP(noofOriginalJobs,noofStages,inputTime,q);
e = getE(noofOriginalJobs,noofStages,inputEnergy,q);

%take break down values

b = input('Breakdown?\n1-Yes\n0-No\n');
if(b==1)
    breakMachine = input('Enter the machine number which breaks down');
    breakTime = input('Enter the Time at which machine breaks down');
    for i=1:50
        position(:,:,i)=breakdown(noofOriginalJobs,noofMachines,maxMachines,noofStages,position,p,i,breakMachine,breakTime);
        
    end
    q = getQ(position);
    p = getP(noofOriginalJobs,noofStages,inputTime,q);
    e = getE(noofOriginalJobs,noofStages,inputEnergy,q);
    
end


lambda=input('Enter the value of lambda: ');

fitness = zeros(1,50);
for i=1:50
    fitness(1,i) = getFitness(noofStages,noofOriginalJobs,noofMachines,position,maxMachines,p,e,lambda,i);
end

delta = ones(noofOriginalJobs,noofStages,50);
globalBestFitness=intmax('int64');
globalBestFitnessIndex=0;
velocity = rand(noofOriginalJobs,noofStages,50);
rCoeff = rand(1,5);
isSame = false;
positionOld = position;
for i=1:5000
    issame=0;
    delta = position - positionOld;
    if (sum(sum(sum(delta(:,:,:))))==0)
        issame = issame+1;
    end
    if (sum(sum(sum(delta(:,:,:))))==0 && issame>10)
        positionOld = position;
        position = mutate(position,noofMachines,0.4);
        delta = position - positionOld;
        q = getQ(position);
        p = getP(noofOriginalJobs,noofStages,inputTime,q);
        e = getE(noofOriginalJobs,noofStages,inputEnergy,q);
        if (b==1)
            for i=1:50
                position(:,:,i) = breakdown(noofOriginalJobs,noofMachines,maxMachines,noofStages,position,p,i,breakMachine,breakTime);
            end
            q = getQ(position);
            p = getP(noofOriginalJobs,noofStages,inputTime,q);
            e = getE(noofOriginalJobs,noofStages,inputEnergy,q);
        end
        
        for i=1:50
            fitness(1,i) = getFitness(noofStages,noofOriginalJobs,noofMachines,position,maxMachines,p,e,lambda,i);
        end
    end
    while(sum(sum(sum(delta(:,:,:))))~=0)
        [localBestFitness,localBestFitnessIndex] = min(fitness);
        if(localBestFitness<globalBestFitness)
            globalBestFitness = localBestFitness;
            globalBestFitnessIndex = localBestFitnessIndex;
        end
        positionOld = position;
        for j=1:50
            velocity(:,:,j) = rCoeff(1)*velocity(:,:,j) + rCoeff(2)*rCoeff(3)*(position(:,:,localBestFitnessIndex)-position(:,:,j)) + rCoeff(4)*rCoeff(5)*(position(:,:,globalBestFitnessIndex)-position(:,:,j));
            temp = position(:,:,j) - floor(position(:,:,j)) + velocity(:,:,j);
            for indI=1:noofOriginalJobs
                for indJ=1:noofStages
                    checkVariable = position(indI,indJ,j) + temp(indI,indJ);
                    if(checkVariable>maxMachines(indJ) || checkVariable<minMachines(indJ))
                        %DONT UPDATE
                    else
                        position(indI,indJ,j) = position(indI,indJ,j) + temp(indI,indJ);
                    end
                end
            end
        end
        q = getQ(position);
        p = getP(noofOriginalJobs,noofStages,inputTime,q);
        e = getE(noofOriginalJobs,noofStages,inputEnergy,q);
        if (b==1)
            for i=1:50
                position(:,:,i) = breakdown(noofOriginalJobs,noofMachines,maxMachines,noofStages,position,p,i,breakMachine,breakTime);
            end
            q = getQ(position);
            p = getP(noofOriginalJobs,noofStages,inputTime,q);
            e = getE(noofOriginalJobs,noofStages,inputEnergy,q);
        end
        
        for i=1:50
            fitness(1,i) = getFitness(noofStages,noofOriginalJobs,noofMachines,position,maxMachines,p,e,lambda,i);
        end
        delta = position - positionOld;
    end
end
%fitness
[localBestFitness,localBestFitnessIndex] = min(fitness)
q(:,:,localBestFitnessIndex)




