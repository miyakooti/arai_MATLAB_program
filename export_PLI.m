
if contains(subject, "rest") && not(contains(subject, "restart"))
    
    PLI_data=PLI(60:length(PLI),ASSR_CH_index);
    
    % num2cell()により、配列データをcell配列に変換できる
    Vname = {'FC3','FC4','FCz'};
    data = [num2cell(PLI_data)];
    C = [Vname;data];
    folder_name = findFolderName(subject);
    path = "csv/"+folder_name+"/PLIdata/PLI_"+subject+".csv";
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
    folder_name = findFolderName(subject);
    path1 = "csv/"+folder_name+"/PLIdata/PLI_"+subject+".csv";
    path2 = "csv/"+folder_name+"/PLIdata/concentration_"+subject+".csv";
    writecell(C1,path1)% 出力
    writecell(C2,path2)% 出力
    
end


function folder_name = findFolderName(subject)
    if contains(subject, "kumakura")
        folder_name = "0_kumakura";
    elseif contains(subject, "kim")
        folder_name = "1_kim";
    elseif contains(subject, "souma")
        folder_name = "2_souma";
    elseif contains(subject, "fujii")
        folder_name = "3_fujii";
    elseif contains(subject, "tubota")
        folder_name = "4_tubota";
    elseif contains(subject, "toki")
        folder_name = "5_toki";
    end
end





