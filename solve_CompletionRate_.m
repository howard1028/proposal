%設定全域變數 App、dead、cores、topo、ft
global App dead cores topo ft

app_x = 100 %應用程序數量
x = [1 2 4 6 8 10] %伺服器和核心的數量

%初始化結果矩陣
y1_1 = zeros(1,6)
y2_1 = zeros(1,6)
y3_1 = zeros(1,6)
y1_2 = zeros(1,6)
y2_2 = zeros(1,6)
y3_2 = zeros(1,6)
y4_1 = zeros(1,6)
y4_2 = zeros(1,6)
y5_1 = zeros(1,6)
y5_2 = zeros(1,6)