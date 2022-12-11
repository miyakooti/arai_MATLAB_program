%% LFHFのプログラム
function [LF_HF_No_Fear, LF_HF_Fear] = LFHF(player_Number, video_Number)
    %% データのインポート
    [fear, nofear] = fear_nofear_data_import(player_Number, video_Number);
    RRI_Fear = fear(:,8);
    RRI_No_Fear = nofear(:,8);
    
    %% 自動化できなかったところ
    
    if( (player_Number == 11) || (player_Number == 13))
       RRI_Fear = -1 .* RRI_Fear;
       RRI_No_Fear = -1 .* RRI_No_Fear;
    end
    
    %% データがあるか判定する
    Data_Is_Exist = true;
    if((length(RRI_Fear) <= 15) || (length(RRI_No_Fear) <= 15))
        Data_Is_Exist = false;
        LF_HF_No_Fear = 0;
        LF_HF_Fear = 0;
    end
    
    if(Data_Is_Exist)
        %% Fearに関して
        [pks,locs_Fear] = findpeaks(RRI_Fear,'MinPeakHeight', 400, "MinPeakDistance", 200);
        Interval_Fear = [];
        locs_Fear = locs_Fear';
        for i = 1 : (length(locs_Fear) - 1)
            Interval_Fear(end + 1) = locs_Fear(i + 1) - locs_Fear(i);
        end
         %figure; plot(locs_Fear(1 : end-1), Interval_Fear);

        % スプライン補完
        time_Fear = 0 : 500 : 500 * fix(locs_Fear(end-1)/500);
        Interval_Fear_Approx = spline(locs_Fear(1 : end-1), Interval_Fear, time_Fear);
        % figure; plot(time_Fear, Interval_Fear_Approx);

        % フーリエ変換
        Interval_Fear_fft = fft(Interval_Fear_Approx);
        P_Interval_Fear_fft = sqrt(Interval_Fear_fft .* conj(Interval_Fear_fft));
        frequency_Fear = (1/2) * linspace(0, 1, (length(Interval_Fear_fft)/2) + 1);

        % LFのデータと，HFのデータを取り出す
        P_LF_Fear = [];
        P_HF_Fear = [];
        for i = 1 : length(frequency_Fear)
            if((0.04 < frequency_Fear(i)) && (frequency_Fear(i) <= 0.15))

                P_LF_Fear(end + 1) = P_Interval_Fear_fft(i);
            elseif((0.15 < frequency_Fear(i)) && (frequency_Fear(i) <= 0.40))
                P_HF_Fear(end + 1) = P_Interval_Fear_fft(i);
            end
        end

        % 積分の計算と，LF/HFの計算
        LF_Integral_Fear = cumtrapz(frequency_Fear(1 : length(P_LF_Fear)), P_LF_Fear);
        HF_Integral_Fear = cumtrapz(frequency_Fear(1 : length(P_HF_Fear)), P_HF_Fear);

        LF_HF_Fear = LF_Integral_Fear(end) / HF_Integral_Fear(end);

        %% No_Fearに関して
        Interval_No_Fear = [];
        [pks,locs_No_Fear] = findpeaks(RRI_No_Fear,'MinPeakHeight', 400, "MinPeakDistance", 200);
        for i = 1 : (length(locs_No_Fear) - 1)
            Interval_No_Fear(end + 1) = locs_No_Fear(i + 1) - locs_No_Fear(i);
        end
         %figure; plot(locs_No_Fear(1 : end-1), Interval_No_Fear);

        % スプライン補完
        time_No_Fear = 0 : 500 : 500 * fix(locs_No_Fear(end-1)/500);
        Interval_No_Fear_Approx = spline(locs_No_Fear(1 : end-1), Interval_No_Fear, time_No_Fear);
        % figure; plot(time_No_Fear, Interval_No_Fear_Approx);

        % フーリエ変換
        Interval_No_Fear_fft = fft(Interval_No_Fear_Approx);
        P_Interval_No_Fear_fft = sqrt(Interval_No_Fear_fft .* conj(Interval_No_Fear_fft));
        frequency_No_Fear = (1/2) * linspace(0, 1, (length(Interval_No_Fear_fft)/2) + 1);

        % LFのデータと，HFのデータを取り出す
        P_LF_No_Fear = [];
        P_HF_No_Fear = [];
        for i = 1 : length(frequency_No_Fear)
            if((0.04 < frequency_No_Fear(i)) && (frequency_No_Fear(i) <= 0.15))
                P_LF_No_Fear(end + 1) = P_Interval_No_Fear_fft(i);
            elseif((0.15 < frequency_No_Fear(i)) && (frequency_No_Fear(i) <= 0.40))
                P_HF_No_Fear(end + 1) = P_Interval_No_Fear_fft(i);
            end
        end

        % 積分の計算と，LF/HFの計算
        LF_Integral_No_Fear = cumtrapz(frequency_No_Fear(1 : length(P_LF_No_Fear)), P_LF_No_Fear);
        HF_Integral_No_Fear = cumtrapz(frequency_No_Fear(1 : length(P_HF_No_Fear)), P_HF_No_Fear);

        LF_HF_No_Fear = LF_Integral_No_Fear(end) / HF_Integral_No_Fear(end);
    end
end
