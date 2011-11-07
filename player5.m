function [ decision ] = player5(K,op,turn)
%Friedmann
if (turn == 1)
    decision = 1; %cooperate in turn 1
else
    if (max(K(op,5,:)) == 2) % was betrayed once
        decision = 2;
    else
        decision = 1;
    end
end

end
