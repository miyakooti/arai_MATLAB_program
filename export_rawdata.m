
    
data=data1(1:length(data1),1:8);
    
% num2cell()により、配列データをcell配列に変換できる
columns = {'FpZ' 'FC3' 'FC4' 'FcZ' 'O1' 'O2' 'Fp2','V6'};
% 生の心電図データ一応みておきたいので出力します

% あれ、rawdataってどんなフィルタ処理されてるっけ？

data = [num2cell(data)];
C = [columns;data];
folder_name = findFolderName(subject);
phase_number = findPhaseNumber(subject);
path = "csv/"+folder_name+"/EEG/filtered_data_"+phase_number+"_"+subject+".csv";
writecell(C,path)% 出力
    


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

function phase_number = findPhaseNumber(subject)
    if contains(subject, "rest") && not(contains(subject, "restart"))
        phase_number = "0";
    elseif contains(subject, "practice")
        phase_number = "1";
    elseif contains(subject, "boredom")
        phase_number = "2";
    elseif contains(subject, "ultra")
        phase_number = "4";
    elseif contains(subject, "flow")
        phase_number = "3";
    elseif contains(subject, "overload")
        phase_number = "5";
    end
end




