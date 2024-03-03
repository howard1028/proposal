function [output] = ranktime_test(app,x)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

global App Wtime ranktime a

if ranktime{app}(1,x) == 0 %rank(i,j) 需修改 (已修改
    MaxR = 0 ;
    for l = 1:a(app) %l = 1:a(app)
        if App{app}(x,l) ~= 0 && x ~= l %App{app}(x,l) ~= 0 && x ~= l
            R = ranktime_test(app,l) ; % R = comm(x,l) + ranktest(app,l)
            if R > MaxR
                MaxR = R ;
            end    
        end   
    end
    output = Wtime(x) + MaxR ;
else
    output = ranktime{app}(1,x) ;
end

end