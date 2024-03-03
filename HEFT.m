% 名為 HEFT 的 MATLAB 函式，有兩個輸入參數，filename_t 和 filename_a，分別代表了拓撲檔、應用程式檔的檔名
function [rank,reward,priority_proposal,priority_PDAGTO,priority_DA,resultname,first,priority_n,priority_rank] = HEFT(filename_t,filename_a)

global App dead reward cores topo rank W comm a n_a b n_b ft
global priority_proposal priority_PDAGTO priority_DA priority_n priority_rank
global ranktime Wtime K cut

% 使用 network1 和 application 函式初始化網路和應用程式的相關變數
[cores,topo] = network1(filename_t) ;
[App,dead,reward,a,ft] = application(filename_a) ;

%a = dlmread(filename_a,' ',[0 0 0 2]) ;
n_a = length(a) ;
b = cores ;
%b = dlmread(filename_t,' ',[0 0 0 2]) ;
n_b = length(b) ;

% 將輸入的檔名進行一些處理，生成 resultname 作為結果文件的名稱
s1 = strrep(filename_a, '.txt', '') ;
s2 = strrep(filename_t, '.txt', '') ;
%resultname = s1 + "_" + s2 + ".xls";
resultname = s1 + "_" + s2 + "p.xls";


% 初始化用於存放結果和一些權重參數
rank = cell(1,n_a) ;
ranktime = cell(1,n_a) ;
priority_proposal = zeros(1,n_a) ;
priority_PDAGTO = zeros(1,n_a) ;  %0905之前的版本需要註解此行
priority_DA = zeros(1,n_a) ;
priority_n = zeros(1,n_a) ;
priority_rank = zeros(1,n_a);

dead_rank = zeros(n_a,2) ;

%first = zeros(1,n_a) ; 
first = randi([1,n_b],1,n_a);

%proposal 目前最佳 : alp = 0.3 ; bet = 0.7
alp = 0.6 ; %0.8 %0.5 %0.2
bet = 0.4 ; %0.2 %0.5 %0.8 %最佳 0.15 0.7 0.15
gam = 0 ; %適合單核心 %bet0.8 gam0.2

% 遍歷每個應用程式
for i=1:n_a
    W = zeros(1,a(i)) ;
    Wtime = zeros(1,a(i)) ;
    rank{i} = zeros(1,a(i));
    ranktime{i} = zeros(1,a(i));
    comm = zeros(a(i));

    %first(1,i) = randi([1,n_b]) ; %app初始位置

    % 在每個應用程式中，計算 workloads、communication 並初始化初始 rank
    for j=a(i):-1:1

        % 計算workload、communication
        w = 0 ;
        for k=1:n_b
            tmpW = (App{i}(j,j)/topo(k,k))*b(k);
            w = w + tmpW ;   
        end
        W(1,j) = w / sum(b) ;
        Wtime(1,j) = App{i}(j,j)/topo(first(1,i),first(1,i));

        
        c = 0 ;
        for l = 1:a(i)
            link = 0 ;
            for k=1:n_b
                for m = 1:n_b
                    if j ~= l && k ~= m && topo(k,m) ~= 0
                        tmpC = (App{i}(j,l)/topo(k,m)) ;
                        c = c + tmpC ;
                        link = link + 1 ;
                    end
                end
            end
            comm(j,l) = c / link ;
        end

         % 初始化rank
         G = 0 ;
         for l = 1:a(i)
             if App{i}(j,l) ~= 0
                G = G+1 ; 
             end   
         end
         if G == 1
             rank{i}(1,j) = W(1,j);
             ranktime{i}(1,j) = Wtime(1,j);
         end

        %rank{i}(1,j) = ranktest(i,j);
    end

    %計算rank
    for j=a(i):-1:1
        rank{i}(1,j) = ranktest(i,j);
        ranktime{i}(1,j) = ranktime_test(i,j);
    end    
    
    %priority_Daas = rank ;


    % DA [文獻11]
    priority_DA(1,i) = dead(1,i) ; %/ reward(1,i);

    % DTSMCS
    priority_rank(1,i) = ( abs(alp*( dead(1,i) - max(rank{i}(1,:)))) + bet*(dead(1,i)) ) ;
    
    % MAR
    priority_proposal(1,i) = 0.2*(dead(1,i))+0.8*max(rank{i}(1,:)) ; %這是學姊方法(MAR)

end

%PDAGTO
priority_PDAGTO = rank ;

end