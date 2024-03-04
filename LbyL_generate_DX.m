%用來生成應用程序的 DAG
function [] = LbyL_generate_DX(app_x)

%K 是一個儲存 cell 陣列，而 cut 是一個儲存數字的陣列
global K cut;
K = cell(1,app_x/10) ;
%cut = cell(1,app_x/10);
cut = zeros(1,app_x) ;
writeDAG = cell(1,app_x);

%節點數目 num、截止時間 deadline、獎勵 reward 和計算時間 compute
num = randi([1,40],1,app_x) ;
%deadline = randi([100,200],1,app_x)*0.0001 ;
deadline = randi([10,20],1,app_x)*0.001 ;
reward = randi([1,10],1,app_x)*10;
compute = randi([675,825],1,app_x)*0.000001 ;

%對每個應用程序生成 DAG
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

%對每個 i 生成一個應用程序文件，其中包含了節點數目、截止時間、獎勵、計算時間和相應的 DAG
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