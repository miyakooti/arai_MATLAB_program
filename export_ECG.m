% 事前にrawdataを読み込んでおく。８はECG_CH
ecg_data=rawdata(:,8);


% num2cell()により、配列データをcell配列に変換できる
Vname = {'ECG'};
data = [num2cell(ecg_data)];
C = [Vname;data];

path = "csv/temp/ECG_"+subject+".csv";

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
    elseif contains(subject, "mori")
        folder_name = "6_mori";
    elseif contains(subject, "hochi")
        folder_name = "7_hochi";
    elseif contains(subject, "yamada")
        folder_name = "8_yamada";
    elseif contains(subject, "takei")
        folder_name = "9_takei";
    elseif contains(subject, "tenshin")
        folder_name = "10_tenshin";
    elseif contains(subject, "masanori")
        folder_name = "11_masanori";
    elseif contains(subject, "enoki")
        folder_name = "12_enoki";
    elseif contains(subject, "ito")
        folder_name = "13_ito";
    elseif contains(subject, "yoshioka")
        folder_name = "14_yoshioka";
    elseif contains(subject, "chizuru")
        folder_name = "15_chizuru";
    end
end




