%% CSV出力方法メモ

% 何らかのデータをロードする
task = normalize_mean(:,:);
task2 = normalize_FC3(:,:);

% CSV出力プログラム
% num2cell()により、配列データをcell配列に変換できる
Vname = {'Mean','FC3'};
data = [num2cell(task), num2cell(task2)];
C = [Vname;data];

writecell(C,'mydata1.csv')% 出力