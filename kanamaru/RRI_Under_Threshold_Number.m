%----------------------------------------------------------
% RRI�̐S���Ԋu�ɂ����āC���|���Ɣ񋰕|�������킹�����ϒl��臒l�Ƃ���
% ���|���Ɣ񋰕|���̂��ꂼ��ɂ����āC臒l�����S���Ԋu�������Ȃ��Ă���f�[�^�̌����o�͂���
% �팱�ҁC�f������SCL�̕��ϒl�Ɋւ��ė���������s��
% 2019/6/19 Sekikawa
%----------------------------------------------------------

function [RRI_F_Under_Threshold_Number, RRI_NF_Under_Threshold_Number, Interval_Fear, Interval_No_Fear, Threshold] = RRI_Under_Threshold_Number(player_Number, video_Number)
    %% �f�[�^�̃C���|�[�g
    fear = [];
    nofear = [];
    [fear, nofear] = fear_nofear_data_import(player_Number, video_Number);

    %% RRI�̃f�[�^�̂݉����ɂ��Ď��o��
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
    
    %% �������ł��Ȃ������Ƃ���
    
    if( (player_Number == 11) || (player_Number == 13))
       RRI_Fear = -1 .* RRI_Fear;
       RRI_No_Fear = -1 .* RRI_No_Fear;
    end
    
    if(Data_is_Exist)
        %% ���ǉ������Ƃ��� -> �������ߎ�
        [p,s,mu] = polyfit((1:numel(RRI_Fear)),RRI_Fear,6);
        f_y = polyval(p,(1:numel(RRI_Fear)),[],mu);
        RRI_Fear = RRI_Fear - f_y;

        [p,s,mu] = polyfit((1:numel(RRI_No_Fear)),RRI_No_Fear,6);
        nf_y = polyval(p,(1:numel(RRI_No_Fear)),[],mu);
        RRI_No_Fear = RRI_No_Fear - nf_y;

        RRI_All = horzcat(RRI_Fear, RRI_No_Fear);
        
        %% RRI�̊Ԋu�����߂Ċi�[����
        Interval_All = [];
        Interval_Fear = [];
        Interval_No_Fear = [];

        [pks,locs] = findpeaks(RRI_All,'MinPeakHeight', 400, "MinPeakDistance", 200);
        for i = 1 : (length(locs) - 1)
            Interval_All(end + 1) = locs(i + 1) - locs(i);
        end

        % Fear�Ɋւ���
        [pks,locs] = findpeaks(RRI_Fear,'MinPeakHeight', 400, "MinPeakDistance", 200);
        for i = 1 : (length(locs) - 1)
            Interval_Fear(end + 1) = locs(i + 1) - locs(i);
        end

        % No_Fear�Ɋւ���
        [pks,locs] = findpeaks(RRI_No_Fear,'MinPeakHeight', 400, "MinPeakDistance", 200);
        for i = 1 : (length(locs) - 1)
            Interval_No_Fear(end + 1) = locs(i + 1) - locs(i);
        end

        %%
        RRI_Interval_Fear_Ave = mean(Interval_Fear);
        RRI_Interval_NoFear_Ave = mean(Interval_No_Fear);
        
        
        %% RRI_ALL�Ɋւ���20%�����Ԃ��o�͂���
        [h,p,ci,stats] = ttest(Interval_All, 0, "Dim", 2, "Tail", "right", "Alpha", 0.20);
        Threshold = ci(1);

        %% Fear��No_Fear�Ɋւ��āC臒l��������������v�Z����
        RRI_F_Under_Threshold_Number = 0;
        RRI_NF_Under_Threshold_Number = 0;

        % ���|���̃f�[�^�̐��̌v�Z
        for i = 1 : length(Interval_Fear)
            if( Threshold > Interval_Fear(i) )
                RRI_F_Under_Threshold_Number =  RRI_F_Under_Threshold_Number + 1;
            end
        end
        % �񋰕|���̃f�[�^�̐��̌v�Z
        for i = 1 : length(Interval_No_Fear)
            if(Threshold > Interval_No_Fear(i))
                RRI_NF_Under_Threshold_Number = RRI_NF_Under_Threshold_Number + 1;
            end
        end
    end
end