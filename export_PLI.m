% 事前にrawdataを読み込んでおく。８はECG_CH

if contains(subject, "rest") 
    
    PLI_data=PLI(60:length(PLI),ASSR_CH_index);
    
    % num2cell()により、配列データをcell配列に変換できる
    Vname = {'FC3','FC4','FCz'};
    data = [num2cell(PLI_data)];
    C = [Vname;data];
    path = "csv/PLI_"+subject+".csv";
    writecell(C,path)% 出力
    
else    
    PLI40_data=PLI40(60:length(PLI40),ASSR_CH_index);
    concentration_data=concentration(60:length(concentration),ASSR_CH_index);
    
    % num2cell()により、配列データをcell配列に変換できる
    Vname = {'FC3','FC4','FCz'};
    PLI40_data = [num2cell(PLI40_data)];
    concentration_data = [num2cell(concentration_data)];
    C1 = [Vname;PLI40_data];
    C2 = [Vname;concentration_data];
    path1 = "csv/PLI40_"+subject+".csv";
    path2 = "csv/concentration_"+subject+".csv";
    writecell(C1,path1)% 出力
    writecell(C2,path2)% 出力
    
end


