function [DAG,cut] = layer_by_layer(num,k,p)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% global cut ;

layer = zeros(1,num) ;
layer(1,1:k) = 1:k ;
layer(1,k+1:num) = randi([1,k],1,num-k) ;
layer = sort(layer);

cut = length(find(layer==mode(layer))) ;

DAG = zeros(num);

l = 2 ;
layer_s = 1 ;
layer_d = length(find(layer==1));
for i=1:num
    if  layer(i) == l
        x = randi([layer_s,layer_d]);
        DAG(x,i) = 1 ;
        if i == num
            break ;
        elseif layer(i+1) == l+1
            l=l+1;
            layer_s = layer_d+1 ;
            layer_d = i;
        end    
    end    
end    

% layer = zeros(1,num) ;
% node_s = 0 ;
% cnt = 1;
% n = num ;
% for i=k:-1:1 
%     node_d = randi([1,n-(i-1)]);
%     layer(1,node_s+1:node_s+node_d) = cnt ;
%     cnt = cnt+1 ;
%     node_s = node_s+node_d ;
%     n = n - node_d ;
% end

for i=1:num
    for j=1:num
        if layer(1,j) > layer(1,i)
            if rand < p
                DAG(i,j) = 1 ;
            end
        end    
    end    
end    


end