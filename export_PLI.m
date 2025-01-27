
disp("--------------------------")
disp(subject);

ASSR_CH_index_fixed = [1,2,3,4,5,6,7];

if contains(subject, "rest") && not(contains(subject, "restart"))
    
    run("calcPLI_rest");
    PLI_data=PLI(60:length(PLI),[1,2,3,4,5,6,7]);
    
    % num2cell()により、配列データをcell配列に変換できる
%     Vname = {'FC3','FC4','FCz'};
    Vname = {'FpZ','FC3','FC4','FCz','O1','O2','Fp2'};
    data = [num2cell(PLI_data)];
    C = [Vname;data];
    folder_name = findFolderName(subject);
    phase_number = findPhaseNumber(subject);
    path = "csv/"+folder_name+"/PLIdata/PLI_"+phase_number+"_"+subject+".csv";
    writecell(C,path)% 出力
    
else    
    
    run("calcWorkload");
    PLI40_data=PLI40(60:length(PLI40),[1,2,3,4,5,6,7]);
    concentration_data=concentration(60:length(concentration),[1,2,3,4,5,6,7]);
    
    % num2cell()により、配列データをcell配列に変換できる
%     Vname = {'FC3','FC4','FCz'};
    Vname = {'FpZ','FC3','FC4','FCz','O1','O2','Fp2'};
    PLI40_data = [num2cell(PLI40_data)];
    concentration_data = [num2cell(concentration_data)];
    C1 = [Vname;PLI40_data];
    C2 = [Vname;concentration_data];
    folder_name = findFolderName(subject);
    phase_number = findPhaseNumber(subject);
    path1 = "csv/"+folder_name+"/PLIdata/PLI_"+phase_number+"_"+subject+".csv";
    path2 = "csv/"+folder_name+"/PLIdata/concentration_"+phase_number+"_"+subject+".csv";
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
    elseif contains(subject, "shoki")
        folder_name = "16_shoki";
    elseif contains(subject, "okada")
        folder_name = "17_okada";
    elseif contains(subject, "yuzuha")
        folder_name = "18_yuzuha";
    elseif contains(subject, "hasegawa")
        folder_name = "19_hasegawa";
    elseif contains(subject, "kanemoto")
        folder_name = "20_kanemoto";
    elseif contains(subject, "haruna")
        folder_name = "21_haruna";
    elseif contains(subject, "tamami")
        folder_name = "22_tamami";
    elseif contains(subject, "yoshikawa")
        folder_name = "23_yoshikawa";
    elseif contains(subject, "sugata")
        folder_name = "24_sugata";
    elseif contains(subject, "arai")
        folder_name = "25_arai";
    elseif contains(subject, "yamashita")
        folder_name = "26_yamashita";
    elseif contains(subject, "ayaka")
        folder_name = "27_ayaka";
    elseif contains(subject, "chihiro")
        folder_name = "28_chihiro";
    elseif contains(subject, "yuito")
        folder_name = "29_yuito";
    elseif contains(subject, "maiko")
        folder_name = "30_maiko";
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




