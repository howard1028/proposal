function [server_sch,app_sch,complete,reward_ratio] = schedule_NewMethod(priority,rank,App,topo,reward,first,parti)
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here

%此函數用的全域
global App topo n_a n_b a cores dead ft reward cut

% struct 初始建構(未完成)
server_sch(1).core(1).idle(1,:) = [0,0] ; % server idle time (建立)
server_sch(1).core(1).idle(1,:) = [] ; % server idle time (初始化)
server_sch(1).core(1).last = [0,0] ; % server last task
app_sch(1).task(1).part(1,:) = [0,0,0,0] ; % task schedule (建立)
app_sch(1).task(1).part(1,:) = [] ;  % task schedule (初始化)

%超過期限的數量
loss = 0 ;

get_reward = 0 ;

for m = 1:n_b
    for r = 1:cores(m)
        server_sch(m).core(r).idle(1,:) = [0,0] ;
        server_sch(m).core(r).idle(1,:) = [] ;
        server_sch(m).core(r).last = [0,0] ;
        %app_sch(1).task(1).part(1,:) = [] ;
        server_sch(m).core(r).schedule(1,:) = [0,0,0,0] ; %struct 新增部分
        server_sch(m).core(r).schedule(1,:) = [] ; %struct 新增部分
    end
end

for i=1:n_a
    for j=1:a(i)
        app_sch(i).task(j).part(1,:) = [0,0,0,0] ;
        %app_sch(i).task(j).part(1,:) = [] ;
    end
end    

server_un = server_sch ; % server status of unschedule

% 排程
while any(priority)
    [x,k] = min(priority) ;
    %first = 1 ; %選擇app後開始排程，用來隨機分發app一開始所在的server
    %first = randi([1,n_b]) ; %app一開始所在server
    get_reward = get_reward + reward(1,k) ; %該app的報酬
    while any(rank{k})
        [b,l]=max(rank{k});

        comm = zeros(size(rank{k},1),n_b);
        pre = 0 ; %predecessor
        prede = [] ;
        f_sch = 999 ;
        m_sch = 0 ;
        r_sch = 0 ;
        ID_sch = 0;
        ID = 0 ;
        f_min = f_sch ;

        % 找前項子任務
        for j = 1:a(k)
            if App{k}(j,l) ~= 0 && l ~= j
                %需要dijkstra 找傳遞路徑
                %如果有辦法只找一次最好
                %但是 傳輸大小 不固定，再想辦法
                %用 dijkstra 存路徑?
                comm(j,:) = dijkstra(App{k}(j,l),app_sch(k).task(j).part(1,1),topo,n_b);
                pre = pre + 1 ;
                prede(pre) = j ;
            end                  
        end


        %無前項子任務
        if pre == 0
            comm(1,:) = dijkstra(ft(1,k),first(1,k),topo,n_b);
        end

%         selectm = [] ;
%         if pre == 0
%             for cc = 1:n_b
%                 if comm(1,cc) < 0.0000486
%                     if ~ismember(cc,selectm)
%                         selectm = [selectm cc];
%                     end
%                 end    
%             end            
%         else    
%             for j = 1:pre
%                 for cc = 1:n_b
%                     if comm(j,cc) < 0.0000486
%                         if ~ismember(cc,selectm)
%                             selectm = [selectm cc];
%                         end
%                     end    
%                 end    
%             end
%         end

        %server
        for m = 1:n_b %1:n_b
            %同個server傳輸時間相同
            prede_stmp = -1 ;
            for i = 1:pre
                if app_sch(k).task(prede(i)).part(1,4) + comm(prede(i),m) > prede_stmp
                    prede_stmp = app_sch(k).task(prede(i)).part(1,4) + comm(prede(i),m) ;
                end    
            end

            %無前項子任務
            if pre == 0
                prede_stmp = comm(1,m) ;
            end

            omega = App{k}(l,l)/topo(m,m) ;

            for r = 1:cores(m) %core
                % sortrows
                % ID = x => 使用第 x 個 idle time 排程
                ID = 0 ;
                %omega = App{k}(l,l)/topo(m,m) ;
                %ID = 0 ;
                %stmp = prede_stmp ;
                %想一想 idle time 為空 時 條件怎麼寫
                % idle time 排程
                if size(server_sch(m).core(r).idle,1) ~= 0

                    for i = 1:size(server_sch(m).core(r).idle,1)            

                        stmp = max([prede_stmp server_sch(m).core(r).idle(i,1)]) ;
                        ftmp = stmp + omega ;

                        if stmp >= server_sch(m).core(r).idle(i,1) && ftmp <= server_sch(m).core(r).idle(i,2)
                            ID = i ;
                            break ;
                        end    
                    end
                end    
                
                if ID == 0
                    % 非idle time 的排程
                    stmp = max([prede_stmp server_sch(m).core(r).last(1,2)]) ; 
                    ftmp = stmp + omega ;
                    ID = 0 ;

                end
    

                if ftmp < f_sch
                    s_sch = stmp ;
                    f_sch = ftmp ;
                    m_sch = m ;
                    r_sch = r ;
                    ID_sch = ID ;
                    %app_sch(k).task(l).part(1,:) = [m,r,s_sch,f_sch] ;
                    
                    %struct 新增部分
                    %ss = size(server_sch(m_sch).core(r_sch).schedule,1);
                    %server_sch(m_sch).core(r_sch).schedule(ss+1,:) = [k,l,s_sch,f_sch] ;
%                 elseif ftmp - f_sch < 0.0006 && pre == 0 && cut(1,k) > mean(cut) %0.001兩者接近
%                     if cores(m) > cores(m_sch)
%                         s_sch = stmp ;
%                         f_sch = ftmp ;
%                         m_sch = m ;
%                         r_sch = r ;
%                         ID_sch = ID ;
%                     end    
                end

            end    
        end

        %========選擇server======
        f_min = f_sch ;

        if cut(1,k) > mean(cut) %&& pre == 0
            %多core選擇
            for m = 1:n_b %1:n_b
                %同個server傳輸時間相同
                prede_stmp = -1 ;
                for i = 1:pre
                    if app_sch(k).task(prede(i)).part(1,4) + comm(prede(i),m) > prede_stmp
                        prede_stmp = app_sch(k).task(prede(i)).part(1,4) + comm(prede(i),m) ;
                    end    
                end
    
                %無前項子任務
                if pre == 0
                    prede_stmp = comm(1,m) ;
                end
    
                omega = App{k}(l,l)/topo(m,m) ;
    
                for r = 1:cores(m) %core
                    % sortrows
                    % ID = x => 使用第 x 個 idle time 排程
                    ID = 0 ;
                    %omega = App{k}(l,l)/topo(m,m) ;
                    %ID = 0 ;
                    %stmp = prede_stmp ;
                    %想一想 idle time 為空 時 條件怎麼寫
                    % idle time 排程
                    if size(server_sch(m).core(r).idle,1) ~= 0
    
                        for i = 1:size(server_sch(m).core(r).idle,1)            
    
                            stmp = max([prede_stmp server_sch(m).core(r).idle(i,1)]) ;
                            ftmp = stmp + omega ;
    
                            if stmp >= server_sch(m).core(r).idle(i,1) && ftmp <= server_sch(m).core(r).idle(i,2)
                                ID = i ;
                                break ;
                            end    
                        end
                    end    
                    
                    if ID == 0
                        % 非idle time 的排程
                        stmp = max([prede_stmp server_sch(m).core(r).last(1,2)]) ; 
                        ftmp = stmp + omega ;
                        ID = 0 ;
    
                    end
        
                    if ftmp - f_min < 0.0008  %0.0006
                        if cores(m) >= cores(m_sch)
                            if r == 1
                                s_sch = stmp ;
                                f_sch = ftmp ;
                                m_sch = m ;
                                r_sch = r ;
                                ID_sch = ID ;
                            elseif ftmp < f_sch
                                s_sch = stmp ;
                                f_sch = ftmp ;
                                m_sch = m ;
                                r_sch = r ;
                                ID_sch = ID ;                               
                            end    
                        end
                    end    
    
    %                 if ftmp < f_sch
    %                     s_sch = stmp ;
    %                     f_sch = ftmp ;
    %                     m_sch = m ;
    %                     r_sch = r ;
    %                     ID_sch = ID ;
    %                     app_sch(k).task(l).part(1,:) = [m,r,s_sch,f_sch] ;
    %                     
    %                     struct 新增部分
    %                     ss = size(server_sch(m_sch).core(r_sch).schedule,1);
    %                     server_sch(m_sch).core(r_sch).schedule(ss+1,:) = [k,l,s_sch,f_sch] ;
    %                 elseif ftmp - f_sch < 0.0006 && pre == 0 && cut(1,k) > mean(cut) %0.001兩者接近
    %                     if cores(m) > cores(m_sch)
    %                         s_sch = stmp ;
    %                         f_sch = ftmp ;
    %                         m_sch = m ;
    %                         r_sch = r ;
    %                         ID_sch = ID ;
    %                     end    
    %                 end
    
                end    
            end        
        end

        %確認是否超過deadline
        if f_sch <= dead(1,k)
            app_sch(k).task(l).part(1,:) = [m_sch,r_sch,s_sch,f_sch] ;
            %struct 新增部分
            ss = size(server_sch(m_sch).core(r_sch).schedule,1);
            server_sch(m_sch).core(r_sch).schedule(ss+1,:) = [k,l,s_sch,f_sch] ;

            if ID_sch ~= 0
                nID = size(server_sch(m_sch).core(r_sch).idle,1) ;
                % new idle time --- task finish time & old idle finish time
                server_sch(m_sch).core(r_sch).idle(nID+1,:) = [ app_sch(k).task(l).part(1,4) , server_sch(m_sch).core(r_sch).idle(ID_sch,2) ] ; 
                % update old idle time
                server_sch(m_sch).core(r_sch).idle(ID_sch,2) = app_sch(k).task(l).part(1,3) ;

                if server_sch(m_sch).core(r_sch).idle(nID+1,1) == server_sch(m_sch).core(r_sch).idle(nID+1,2)
                    server_sch(m_sch).core(r_sch).idle(nID+1,:) = [] ;

                elseif server_sch(m_sch).core(r_sch).idle(ID_sch,1) == server_sch(m_sch).core(r_sch).idle(ID_sch,2)
                    server_sch(m_sch).core(r_sch).idle(ID_sch,:) = [] ;
                end    
            else
                if app_sch(k).task(l).part(1,3) > server_sch(m_sch).core(r_sch).last(1,2)
                    nID = size(server_sch(m_sch).core(r_sch).idle,1) ;
                    server_sch(m_sch).core(r_sch).idle(nID+1,:) = [ server_sch(m_sch).core(r_sch).last(1,2) , app_sch(k).task(l).part(1,3) ] ;
                end

                server_sch(m_sch).core(r_sch).last(1,:) = [ app_sch(k).task(l).part(1,3) , app_sch(k).task(l).part(1,4) ];
            end
            rank{k}(1,l) = NaN ;
            server_sch(m_sch).core(r_sch).idle = sortrows(server_sch(m_sch).core(r_sch).idle,1) ;
            server_sch(m_sch).core(r_sch).schedule = sortrows(server_sch(m_sch).core(r_sch).schedule,3);

        else
            server_sch = server_un ;
            %app_sch(k) = app_sch(k)*NaN ;
            for i=1:a(k)
                for j=1:size(app_sch(k).task(i).part,1)
                    app_sch(k).task(i).part(j,:) = [NaN,NaN,NaN,NaN] ;
                end
            end

            rank{k} = rank{k}*NaN ;
            loss = loss+1;
            get_reward = get_reward - reward(1,k);
        end
        
        if parti == 2
            % partition 預計部分
            [app_sch,server_sch]=partition(app_sch,server_sch,k,prede,pre);
        end    

    end
    server_un = server_sch ;
    priority(k) = NaN ;
end    

% %sheet定位
% sht = mode*2 ;
% %清空輸出結果
% str = "" ;
% writematrix(str,'result.xls','Sheet',sht,'WriteMode','overwritesheet') ;
% writematrix(str,'result.xls','Sheet',sht+1,'WriteMode','overwritesheet') ;
% 
% %server schedule 輸出
% cnt = 1 ;
% for i=1:size(server_sch,2)
%     str = "server" + i ;
%     range = "A" + cnt ;
%     writematrix(str,'result.xls','Sheet',sht,'Range',range) ;
%     cnt = cnt+1 ;
%     for j=1:size(server_sch(i).core,2)
%         str = "core" + j ;
%         range = "A" +  cnt;
%         writematrix(str,'result.xls','Sheet',sht,'Range',range) ;
%         range = "E" + cnt ;
%         writematrix(server_sch(i).core(j).last,'result.xls','Sheet',sht,'Range',range) ;
%         for k=1:size(server_sch(i).core(j).idle,1)
%             range = "B" +  cnt;
%             writematrix(server_sch(i).core(j).idle(k,:),'result.xls','Sheet',sht,'Range',range) ;
%             cnt = cnt + 1 ;
%         end
% 
%         if size(server_sch(i).core(j).idle,1) == 0
%             cnt = cnt + 1 ;
%         end    
%     end
%     cnt = cnt + 1 ;
% end
% 
% %app schedule 輸出
% cnt = 1 ;
% for i=1:size(app_sch,2)
%     str = "app" + i ;
%     range = "A" + cnt ;
%     writematrix(str,'result.xls','Sheet',sht+1,'Range',range) ;
%     cnt = cnt+1;
%     for j=1:size(app_sch(i).task,2)
%         str = "task" + j ;
%         range = "A" +  cnt;
%         writematrix(str,'result.xls','Sheet',sht+1,'Range',range) ;
%         for k=1:size(app_sch(i).task(j).part,1)
%             range = "B" +  cnt;
%             writematrix(app_sch(i).task(j).part(k,:),'result.xls','Sheet',sht+1,'Range',range) ;
%             cnt = cnt + 1 ;
%         end
% 
%         if size(app_sch(i).task(j).part,1) == 0
%             cnt = cnt + 1 ;
%         end
%     end
%     cnt = cnt + 1 ;
% end    

%比較指標
complete = (n_a-loss)/n_a ;
%reward_ratio = get_reward / sum(reward) ;
reward_ratio = get_reward;

DFD = 1 ;

%是否要加入complete time
%可能會比較partition前後

end