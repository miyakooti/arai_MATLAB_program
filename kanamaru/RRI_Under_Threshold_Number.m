%----------------------------------------------------------
% RRIの心拍間隔において，恐怖時と非恐怖時を合わせた平均値を閾値とする
% 恐怖時と非恐怖時のそれぞれにおいて，閾値よりも心拍間隔が狭くなっているデータの個数を出力する
% 被験者，映像毎にSCLの平均値に関して両側検定を行う
% 2019/6/19 Sekikawa
%----------------------------------------------------------

function [RRI_F_Under_Threshold_Number, RRI_NF_Under_Threshold_Number, Interval_Fear, Interval_No_Fear, Threshold] = RRI_Under_Threshold_Number(player_Number, video_Number)
    %% データのインポート
    fear = [];
    nofear = [];
    [fear, nofear] = fear_nofear_data_import(player_Number, video_Number);

    %% RRIのデータのみ横一列にして取り出す
    Data_is_Exist = true;
    if(length(fear) <= 200)
        Data_is_Exist = false;
        RRI_F_Under_Threshold_Number = 0;
        RRI_NF_Under_Threshold_Number = 0;
        Interval_Fear = [0 0];
        Interval_No_Fear = [0 0];
        Threshold = 0;
    else
        RRI_Fear = fear(:,8)';
        RRI_No_Fear = nofear(:,8)';
    end
    
    %% 自動化できなかったところ
    
    if( (player_Number == 11) || (player_Number == 13))
       RRI_Fear = -1 .* RRI_Fear;
       RRI_No_Fear = -1 .* RRI_No_Fear;
    end
    
    if(Data_is_Exist)
        %% 今追加したところ -> 多項式近似
        [p,s,mu] = polyfit((1:numel(RRI_Fear)),RRI_Fear,6);
        f_y = polyval(p,(1:numel(RRI_Fear)),[],mu);
        RRI_Fear = RRI_Fear - f_y;

        [p,s,mu] = polyfit((1:numel(RRI_No_Fear)),RRI_No_Fear,6);
        nf_y = polyval(p,(1:numel(RRI_No_Fear)),[],mu);
        RRI_No_Fear = RRI_No_Fear - nf_y;

        RRI_All = horzcat(RRI_Fear, RRI_No_Fear);
        
        %% RRIの間隔を求めて格納する
        Interval_All = [];
        Interval_Fear = [];
        Interval_No_Fear = [];

        [pks,locs] = findpeaks(RRI_All,'MinPeakHeight', 400, "MinPeakDistance", 200);
        for i = 1 : (length(locs) - 1)
            Interval_All(end + 1) = locs(i + 1) - locs(i);
        end

        % Fearに関して
        [pks,locs] = findpeaks(RRI_Fear,'MinPeakHeight', 400, "MinPeakDistance", 200);
        for i = 1 : (length(locs) - 1)
            Interval_Fear(end + 1) = locs(i + 1) - locs(i);
        end

        % No_Fearに関して
        [pks,locs] = findpeaks(RRI_No_Fear,'MinPeakHeight', 400, "MinPeakDistance", 200);
        for i = 1 : (length(locs) - 1)
            Interval_No_Fear(end + 1) = locs(i + 1) - locs(i);
        end

        %%
        RRI_Interval_Fear_Ave = mean(Interval_Fear);
        RRI_Interval_NoFear_Ave = mean(Interval_No_Fear);
        
        
        %% RRI_ALLに関して20%推定区間を出力する
        [h,p,ci,stats] = ttest(Interval_All, 0, "Dim", 2, "Tail", "right", "Alpha", 0.20);
        Threshold = ci(1);

        %% FearとNo_Fearに関して，閾値を下回った個数を計算する
        RRI_F_Under_Threshold_Number = 0;
        RRI_NF_Under_Threshold_Number = 0;

        % 恐怖時のデータの数の計算
        for i = 1 : length(Interval_Fear)
            if( Threshold > Interval_Fear(i) )
                RRI_F_Under_Threshold_Number =  RRI_F_Under_Threshold_Number + 1;
            end
        end
        % 非恐怖時のデータの数の計算
        for i = 1 : length(Interval_No_Fear)
            if(Threshold > Interval_No_Fear(i))
                RRI_NF_Under_Threshold_Number = RRI_NF_Under_Threshold_Number + 1;
            end
        end
    end
end