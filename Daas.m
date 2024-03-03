function [rank,reward,resultname,priority_Daas,first] = Daas(filename_t,filename_a) %進行比較實驗時不需要first
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

global App H rank a dead c cores topo ft n_a n_b b

%這個函式要放在所有priority後面，因為rank計算方式不同

[cores,topo] = network1(filename_t) ;
[App,dead,reward,a,ft] = application(filename_a) ;

s1 = strrep(filename_a, '.txt', '') ;
s2 = strrep(filename_t, '.txt', '') ;
%resultname = s1 + "_" + s2 + ".xls";
resultname = s1 + "_" + s2 + "p.xls";

%a = dlmread(filename_a,' ',[0 0 0 2]) ;
n_a = length(a) ;
b = cores ;
%b = dlmread(filename_t,' ',[0 0 0 2]) ;
n_b = length(b) ;

rank = cell(1,n_a) ;
% ranktime = cell(1,n_a) ;
% priority_proposal = zeros(1,n_a) ;
% priority_PDAGTO = zeros(1,n_a) ;
% priority_DA = zeros(1,n_a) ;
% priority_n = zeros(1,n_a) ;

%first = zeros(1,n_a) ; 
%first = randi([1,n_b],1,n_a); %Daas 單獨測試時需要

for i = 1:n_a
    H = zeros(1,a(i)) ;
    %comm = zeros(a(i));

    for j = 1:a(i)

        %計算workload、communication
        h = 0 ;
        for k=1:n_b
            tmph = (App{i}(j,j)/topo(k,k))*b(k);
            h = h + tmph ;   
        end
        H(1,j) = h / sum(b) ;

        
        link = 0 ;
        c = 0 ;
        for k=1:n_b
            for m = 1:n_b
                if k ~= m && topo(k,m) ~= 0
                    tmpC = topo(k,m) ;
                    c = c + tmpC ;
                    link = link + 1 ;
                end
            end
        end
        c = c / link ;
        
        rank{i}(1,j) = Daas_HEFT(i,j);
    end    
end    

priority_Daas = rank ;

end