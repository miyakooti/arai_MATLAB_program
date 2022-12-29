% 事前にrawdataを読み込んでおく。８はECG_CH
ecg_data=rawdata(:,8);


% num2cell()により、配列データをcell配列に変換できる
Vname = {'ECG'};
data = [num2cell(ecg_data)];
C = [Vname;data];

path = "csv/ECG_"+subject+".csv";

writecell(C,path)% 出力