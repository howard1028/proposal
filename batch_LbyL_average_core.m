%目標：任務完成率
%伺服器數量：10
%核心數量：1、2、4、6、8、10
%應用程序數量：100

%設定全域變數 App、dead、cores、topo、ft
global App dead cores topo ft

app_x = 100; %應用程序數量
fprintf('%s %d\n','應用程序數量 = ',app_x);

x = [1 2 4 6 8 10]; %每個伺服器核心的數量
fprintf('不同伺服器的核心的數量 = [%s]\n', num2str(x, ' %d'));

%這些矩陣用於存儲實驗結果，每個矩陣的列數為6，對應於核心數量從1到10的情境
%完工時間的結果矩陣
y1_1 = zeros(1,6);
y2_1 = zeros(1,6);
y3_1 = zeros(1,6);

%獎勵比率的結果矩陣
y1_2 = zeros(1,6);
y2_2 = zeros(1,6);
y3_2 = zeros(1,6);

%排程方法DTSMCS的結果矩陣
y4_1 = zeros(1,6);
y4_2 = zeros(1,6);

%排程方法Daas的結果矩陣
y5_1 = zeros(1,6);
y5_2 = zeros(1,6);

%prorosal排程方法NewMethod的結果矩陣
y6_1 = zeros(1,6);
y6_2 = zeros(1,6);


%這些矩陣是用於存儲實驗結果的總和，將用於計算平均值
y1_1a = zeros(1,6);
y1_2a = zeros(1,6);

y2_1a = zeros(1,6);
y2_2a = zeros(1,6);

y3_1a = zeros(1,6);
y3_2a = zeros(1,6);

y4_1a = zeros(1,6);
y4_2a = zeros(1,6);

y5_1a = zeros(1,6);
y5_2a = zeros(1,6);

%proposal
y6_1a = zeros(1,6);
y6_2a = zeros(1,6);

cnt = 0;
fprintf('紀錄的次數 = %d\n',cnt);

average_cnt = 1; %實驗的平均次數
fprintf('實驗的平均次數 = %d\n',average_cnt);

%外迴圈控制實驗的平均次數，內迴圈則執行各個不同情境的實驗
for j=1:average_cnt
    fprintf('\n第%d次實驗：\n',j);
    fprintf('生成應用程序和執行排程...\n');
    LbyL_generate_DX(app_x) %生成應用程序和執行排程
    cnt = 0;
    fprintf("cnt=%d\n",cnt)

    for i=1:6
        % cc:核心數量
        if i == 1
            cc = 1 ;
        elseif i > 1
            cc = 2*(i-1) ;
        end   

        %網路拓樸，包含server、core
        str_n = "fullnetwork10_core" + cc + ".txt";
        %應用程式
        str_a = "app_LbyL" + app_x + ".txt";


        %執行了 HEFT 演算法生成優先度，並將其用於 MAR、PDAGTO、DA、DTSMCS 和 Daas 等排程方法
        fprintf('HEFT(%s , %s)\n',str_n,str_a);
        [rank,reward , priority_NewMethod , priority_proposal,priority_PDAGTO,priority_DA,resultname,first,priority_n,priority_rank] = HEFT(str_n,str_a);
        
        disp('Priority_NewMethod:');
        disp(priority_NewMethod);
        disp('Priority_Rank:');
        disp(priority_rank);


        fprintf('schedule_MAR\n');
        [server_proposal,app_proposal,complete_proposal,reward_ratio_proposal] = schedule_MAR(priority_proposal,rank,App,topo,reward,first,1); %first之後用自動生成，這裡只是測試

        fprintf('schedule_PDAGTO_origin\n');
        [server_PDAGTO,app_PDAGTO,complete_PDAGTO,reward_ratio_PDAGTO] = schedule_PDAGTO_origin(priority_PDAGTO,App,topo,reward,first,1);

        fprintf('schedule\n');
        [server_DA,app_DA,complete_DA,reward_ratio_DA] = schedule(priority_DA,rank,App,topo,reward,first,1);

        fprintf('schedule_DX\n');
        [server_rank,app_rank,complete_rank,reward_ratio_rank] = schedule_DX(priority_rank,rank,App,topo,reward,first,1) ;

        %proposal 排程方法 NewMethod
        fprintf('schedule_NewMethod\n');
        [server_NewMethod, app_NewMethod, complete_NewMethod, reward_ratio_NewMethod] = schedule_NewMethod(priority_NewMethod, rank, App, topo, reward, first, 1);

        fprintf('Daas\n');
        [rank,reward,resultname,priority_Daas] = Daas(str_n,str_a); %進行比較實驗時不需要first
        fprintf('schedule_Daas\n');
        [server_Daas,app_Daas,complete_Daas,reward_ratio_Daas] = schedule_Daas(priority_Daas,App,topo,reward,first,1);



    
        cnt=cnt+1;

        %每次實驗結束後，將實驗結果存儲在相應的矩陣中
        y1_1(1,cnt) = complete_proposal;
        y2_1(1,cnt) = complete_PDAGTO;
        y3_1(1,cnt) = complete_DA;
        y1_2(1,cnt) = reward_ratio_proposal;
        y2_2(1,cnt) = reward_ratio_PDAGTO;
        y3_2(1,cnt) = reward_ratio_DA;
        y5_1(1,cnt) = complete_Daas;
        y5_2(1,cnt) = reward_ratio_Daas;

        y4_1(1,cnt) = complete_rank;
        y4_2(1,cnt) = reward_ratio_rank;

        y1_1a(1,cnt) = y1_1a(1,cnt)+complete_proposal;
        y1_2a(1,cnt) = y1_2a(1,cnt)+reward_ratio_proposal;
        y2_1a(1,cnt) = y2_1a(1,cnt)+complete_PDAGTO;
        y2_2a(1,cnt) = y2_2a(1,cnt)+reward_ratio_PDAGTO;
        y3_1a(1,cnt) = y3_1a(1,cnt)+complete_DA;
        y3_2a(1,cnt) = y3_2a(1,cnt)+reward_ratio_DA;
        y5_1a(1,cnt) = y5_1a(1,cnt)+complete_Daas;
        y5_2a(1,cnt) = y5_2a(1,cnt)+reward_ratio_Daas;

        y4_1a(1,cnt) = y4_1a(1,cnt)+complete_rank;
        y4_2a(1,cnt) = y4_2a(1,cnt)+reward_ratio_rank;

        %proposal
        y6_1(1,cnt) = complete_NewMethod;
        y6_2(1,cnt) = reward_ratio_NewMethod;
        y6_1a(1,cnt) = y6_1a(1,cnt) + complete_NewMethod;
        y6_2a(1,cnt) = y6_2a(1,cnt) + reward_ratio_NewMethod;

    end    
end

%計算平均結果
for j=1:6
        y1_1a(1,j) = y1_1a(1,j)/average_cnt;
        y1_2a(1,j) = y1_2a(1,j)/average_cnt;
        y2_1a(1,j) = y2_1a(1,j)/average_cnt;
        y2_2a(1,j) = y2_2a(1,j)/average_cnt;
        y3_1a(1,j) = y3_1a(1,j)/average_cnt;
        y3_2a(1,j) = y3_2a(1,j)/average_cnt;
        y5_1a(1,j) = y5_1a(1,j)/average_cnt;
        y5_2a(1,j) = y5_2a(1,j)/average_cnt;
        y4_1a(1,j) = y4_1a(1,j)/average_cnt;
        y4_2a(1,j) = y4_2a(1,j)/average_cnt;

        y6_1a(1,j) = y6_1a(1,j)/average_cnt;
        y6_2a(1,j) = y6_2a(1,j)/average_cnt;        
end    

%繪製圖表
figure(5)
    plot(x,y1_1a , x,y2_1a , x,y3_1a , x,y4_1a , x,y5_1a , x,y6_1a)
    legend('MAR','PDAGTO','EDF','DTSMCS','Daas','NewMethod');


%保存結果到文件(還沒改by wu)
fid = fopen('core1_complete.txt','wt');
fprintf(fid,' MAR PDAGTO EDF DTSMCS Daas NewMethod\n');

for i=1:6
    if i == 1
        cc = 1 ;
    elseif i > 1
        cc = 2*(i-1) ;
    end
    fprintf(fid,'%d %d %d %d %d %d %d\n',cc,y1_1a(1,i)*100,y2_1a(1,i)*100,y3_1a(1,i)*100,y4_1a(1,i)*100,y5_1a(1,i)*100 , y6_1a(1,i)*100);
end

fclose(fid);
