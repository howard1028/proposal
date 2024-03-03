function [] = LbyL_generate_DX(app_x)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

global K cut;
K = cell(1,app_x/10) ;
%cut = cell(1,app_x/10);
cut = zeros(1,app_x) ;
writeDAG = cell(1,app_x);

num = randi([1,40],1,app_x) ;

% num = round(6.5.*randn(1,app_x) + 20.5) ;
% 
% for i=1:app_x
%     if num(1,i) < 1
%         num(1,i) = 1;
% 
%     elseif num(1,i) > 40 
%         num(1,i) = 40 ;
%     end
% end    


% num1 = [1:40] ;
% num2 = [1:40] ;
% num3 = [1:40] ;
% num = [num1 num2 num3] ;
% index_n = randperm(size(num,2));
% num = num(:,index_n) ;

%deadline = randi([100,200],1,app_x)*0.0001 ;
deadline = randi([10,20],1,app_x)*0.001 ;
reward = randi([1,10],1,app_x)*10;
compute = randi([675,825],1,app_x)*0.000001 ;

for l=1:app_x
    DAG = zeros(num(1,l));
    k = randi([1,num(1,l)]);
    [DAG,ccc]= layer_by_layer(num(1,l),k,0.8);

    %K{i/10}(1,l) = k ;
    cut(1,l) = ccc ;
   
    V = randi([270,330],1,num(1,l))*0.001; %*0.001
    D = diag(V) ;
    outDAG = randi([675,825],num(1,l),num(1,l))*0.000001; %*0.000001
    outDAG = outDAG.*DAG ;
    outDAG = outDAG + D ;

    writeDAG{l} = outDAG ;

end


for i=10:10:app_x
    %str = "app_LbyL_reward" + i + ".txt" ;
    str = "app_LbyL" + i + ".txt" ;
    fid = fopen(str,'wt');
    fprintf(fid,'%d\n',i);

    %num = randi([1,40],1,i) ;    
    fprintf(fid,'%d ',num(1,1:i));
    fprintf(fid,'\n');
    %deadline = randi([100,200],1,i)*0.0001 ; %ms to s %原來數據
    %data = randi([10,20],1,i)*0.0001 ;
    fprintf(fid,'%f ',deadline(1,1:i));
    fprintf(fid,'\n');
    %reward = randi([10,100],1,i); %reward
    %data = ones(1,i) ;
    fprintf(fid,'%d ',reward(1,1:i));
    fprintf(fid,'\n');
    %compute = randi([675,825],1,i)*0.000001 ;
    fprintf(fid,'%f ',compute(1,1:i));
    fprintf(fid,'\n');

    %K{i/10} = zeros(1,i);
    
    for l = 1:i
        for j=1:num(1,l)
            fprintf(fid,'%f ',writeDAG{l}(j,:));
            fprintf(fid,'\n');
        end
    end        
    
    fclose(fid);

end    


end