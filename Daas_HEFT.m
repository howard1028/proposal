function [MaxR] = Daas_HEFT(app,x)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

global App H rank a dead c

MaxC = 0 ;
for i=1:a(app)
    if App{app}(i,x) ~= 0 && x ~= i
        C = App{app}(i,x)/c ;
        if C > MaxC
            MaxC = C ;
        end    
    end    
end

MaxR = 0 ;
for i=1:a(app)
    if App{app}(i,x) ~= 0 && x ~= i
        %C = App{app}(i,x); 
        %R = rank{app}(1,i);
%         R = ((H(1,x) + App{app}(i,x)/c) / dead(1,app)) + rank{app}(1,i) ; %一開始的寫法
        R = ((H(1,x) + MaxC) / dead(1,app)) + rank{app}(1,i) ;
        if R > MaxR
            MaxR = R ;
        end  
    end
end

if MaxR == 0
    MaxR = H(1,x) / dead(1,app) ;
end    

end