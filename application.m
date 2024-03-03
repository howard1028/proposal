function [App,dead,reward,x,ft] = application(filename)
% 用於讀取描述應用程序的檔案

%application檔案設計
%第一行為應用程序數量
%第二行為各個應用程序中的子任務數量
%第三行為deadline
%第四行為報酬
%第五行為第一個子任務的傳輸資料大小
%第六行開始為應用程序的DAG
%若 i == j , 為子任務的工作量
%   i != j , 為子任務的傳輸資料大小 , 同時代表 i 與 j 有依賴關係 , i 為前項子任務 j 為後項子任務


% y 是應用程式數量，依資料做更改
y = dlmread(filename,' ',[0 0 0 0]) ;

% 每個應用程式中子任務的數量
x = dlmread(filename,' ',[1 0 1 y-1]);

% deadline
dead = dlmread(filename,' ',[2 0 2 y-1]);

% 報酬
reward = dlmread(filename,' ',[3 0 3 y-1]);

% 初始傳輸
ft = dlmread(filename,' ',[4 0 4 y-1]);

%cell(1,y)中的 y 是指應用程式的數量 (1不用改動)
App = cell(1,y);
a = 4;
for i=1:y
    App{i} = dlmread(filename,' ',[1+a 0 x(i)+a x(i)-1]);
    a = a + x(i);
end    
%{
for i=1:3
    if i==1
        A{i} = dlmread(filename,' ',[1 0 x(1) x(1)-1]);
    else    
        A{i} = dlmread(filename,' ',[1+x(i-1) 0 x(i-1)+x(i) x(i)-1]);
    end
end
%}

end