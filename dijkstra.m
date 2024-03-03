function [d] = dijkstra(app,source,topo,n_b)
%UNTITLED15 Summary of this function goes here
%   Detailed explanation goes here

% n_b = 5 ;
visit = zeros(1,n_b); 
d = ones(1,n_b)*9999;
parent = zeros(1,n_b);
w = topo ;

for i = 1 : n_b
    for j = 1 : n_b
        if i == j
            w(i,j) = 0 ;
        end
        w(i,j) = app / topo(i,j) ;
    end    
end    

d(1,source) = 0;
parent(1,source) = source ;

for k = 1:n_b
    a=-1;
    b=-1;
    min = 9999;
    
    for i = 1:n_b
        if visit(1,i)==0 && d(1,i)<min
            a=i;
            min = d(1,i);
        end    
    end

    if a == -1
        break ;
    end

    visit(1,a) = 1 ;

    for b = 1:n_b
        if visit(1,b) == 0 && d(1,a) + w(a,b) < d(1,b)
            d(1,b) = d(1,a) + w(a,b);
            parent(1,b) = a ;
        end    
    end

end    

end