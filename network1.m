function [cores,topo] = network1(filename)
% 用於讀取描述系統拓樸的檔案

% 使用 dlmread 函數讀取檔案的第一行，x 為系統中的server數量
x = dlmread(filename,' ',[0 0 0 0]) ;

% 讀取檔案的第二行，cores 為每個server的核心數量
cores = dlmread(filename,' ',[1 0 1 x-1]);

% 讀取檔案的第三行及以後的部分，network DAG
topo = dlmread(filename,' ',2,0);

%network檔案設計
%第一行為server數量
%第二行為各個server的核心數量
%第三行開始為拓樸
%若 i == j , 代表CPU的能力
%   i != j , 代表與其他伺服器的傳輸速率

end