function [output] = ranktest(app,x) %ranktest(app,x) %ranktest(app,x,App,W,comm,rank)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here

global App W comm rank a

if rank{app}(1,x) == 0 %rank(i,j) 需修改 (已修改
    MaxR = 0 ;
    for l = 1:a(app) %l = 1:a(app)
        if App{app}(x,l) ~= 0 && x ~= l %App{app}(x,l) ~= 0 && x ~= l
            R = comm(x,l) + ranktest(app,l) ; % R = comm(x,l) + ranktest(app,l)
            if R > MaxR
                MaxR = R ;
            end    
        end   
    end
    output = W(x) + MaxR ;
else
    output = rank{app}(1,x) ;
end

end