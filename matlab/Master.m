clear all;close all; home               % Initalisation
% [a, MSGID] = lastwarn();
% warning('off', MSGID)
%Note: Most standard players are taken from the lecture http://www.socio.ethz.ch/education/fs11/igt/notes/Evolution_von_Kooperation_2011.pdf

tic                                     % start time measurement
N = 20000                               % Number of turns
maxplayers = 20;                        % Maximum number of players
K = zeros(maxplayers,maxplayers,N );    % Contains the information about the players true decisions: 1=Cooperate   2=Betray
K2 = zeros(maxplayers,maxplayers,N );   % Contains the information about the players decision disturbed by noise
minNoise1 = 0                          % The chance that cooperation gets recieved as betrayal goes from the value minNoise1 to maxNoise1
maxNoise1 = 0.15
minNoise2 = 0                           % The chance that betrayal gets recieved as cooperation goes from the value minNoise2 to maxNoise2
maxNoise2 = 0.15
NoiseInc=0.05;                          % Noise increment with each simulation
maxX=(maxNoise1-minNoise1)/NoiseInc+1+10^-15;  % number of points of the x-axis, the last addition is to prevent floating point errors
maxY=(maxNoise2-minNoise2)/NoiseInc+1+10^-15;  % number of points of the y-axis
player = 'player';                       % Name of the player functions
Rewardmatrix=zeros(maxplayers,maxplayers,maxX,maxY); % Matrix that tracks how many points the players get out of each encounter
Reward=zeros(2,1);                      % Rewards that the players get in an encounter
Points=zeros(maxplayers);               % Total amount of points of a player
AverageCoop=zeros(maxX,maxY,maxplayers,maxplayers); % The average cooperation at a given noise for a given matchup
SysAvRew=zeros(maxX,maxY);              % The average reward in the whole system for a given noise 

Winner=0;                               % most succesful player

list = playerlist(player, maxplayers);

Noise(1,1:maxX)=(minNoise1:NoiseInc:maxNoise1);
Noise(2,1:maxY)=(minNoise2:NoiseInc:maxNoise2);

for x=1:maxX
    Noise1=(x-1)*NoiseInc+minNoise1;
    for y=1:maxY
        Noise2=(y-1)*NoiseInc+minNoise2;
        %create the players
        for i=1:maxplayers
            if list(i)==1
                i2=int2str(i);
                eval(['P' i2 '=player' i2 '(' num2str(maxplayers) ');']);
                Names{i}=eval(['P' i2 '.name']);
                Shorts{i}=eval(['P' i2 '.short']);
            end
        end
        for i=1:N % loop trough all turns
            for j=1:maxplayers % loop trough all players
                for k=1:j      % let each player interact with all other players
                    j2=int2str(j);    
                    k2=int2str(k);                    
                    if list(j)==1 && list(k)==1
                        K(j,k,i)=eval(['P' j2 '.decide(K2,k,i)']);  % player j decides how to behave to player k
                        K(k,j,i)=eval(['P' k2 '.decide(K2,j,i)']);  % player k decides how to behave to player j
                        Reward=win([K(j,k,i) K(k,j,i)]); % Rewards are calculated
                        if (j == k)
                            Reward=Reward/2; % otherwise the interaction with itself get counted double
                        end
                        Points(j) = Points(j) + Reward(1);  % Points get updated
                        Points(k) = Points(k) + Reward(2);
                        Rewardmatrix(j,k,x,y) = Rewardmatrix(j,k,x,y) + Reward(1);
                        Rewardmatrix(k,j,x,y) = Rewardmatrix(k,j,x,y) + Reward(2);
                        % noise/miscommunication
                        if (K(j,k,i) == 1) %player j cooperates
                            if (rand > Noise1) %transmission correct
                                K2(j,k,i) = 1; 
                            else % miscommunication
                                K2(j,k,i) = 2;
                            end
                        else %player j betrays
                            if (rand > Noise2) %transmission correct
                                K2(j,k,i) = 2; 
                            else % miscommunication
                                K2(j,k,i) = 1;
                            end
                        end
                        if (K(k,j,i) == 1) %player k cooperates
                            if (rand > Noise1) %transmission correct
                                K2(k,j,i) = 1; 
                            else % miscommunication
                                K2(k,j,i) = 2;
                            end
                        else % player k betrays
                            if (rand > Noise2) %transmission correct
                                K2(k,j,i) = 2; 
                            else % miscommunication
                                K2(k,j,i) = 1;
                            end
                        end
                    end
                end 
            end
        end
        %delete players
        for i=1:maxplayers
            if list(i)==1
                i2=int2str(i);
                eval(['clear P' i2]);
            end
        end
        %Output Cooperation and average Reward in the system
        for i=1:maxplayers
            for j=1:maxplayers
                AverageCoop(x,y,i,j)=2-mean(mean(K(i,j,:)));
            end
            SysAvRew(x,y)=mean(mean(Rewardmatrix(:,:,x,y)))/N;
        end
        %output progress
        Noise1
        Noise2
        toc
    end
end

save simulation2 Rewardmatrix N Names Noise AverageCoop Shorts;
toc % end time measurement

