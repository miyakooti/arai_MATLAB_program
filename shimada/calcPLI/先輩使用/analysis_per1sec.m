%% task analysis per 1 second
%% How to Import

% 数値行列，C5(か6):K(end)　以下内訳
    % 脳波データ8ch C5(か6):J(end)　
    % トリガデータ K5(か6):K(end)
    
% 以下のtask選択から1つ選んで実行後，find triger task以下を実行し，saveで該当データを保存

%% task選択
%% test1
            %task=[];
            %task(:,:)=test1(:,:);
            task = rawdata;
            disp('TASK test1');
%% test2
            %task=[];
            %task(:,:)=test2(:,:);
            %disp('TASK test2');

%% read
           %task=[];
           %task(:,:)=read(:,:);
           %disp('TASK read');
           
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% find trigger task

plot(task(:,9));
%% 目で見て閾値を設定
trg_time_t=[];
th_s=-1940;%% これが閾値

%%
%for i=2:length(task)
%    if(task(i,9) > th_s && task(i-1,9) < th_s)
%        trg_time_t=[trg_time_t i];
%        disp("trg : " + trg_time_t);
%    end
%end

% coded by shimada % 下の閾値に合わせた
for i=2:length(task)
    if(task(i,9) < th_s && task(i-1,9) > th_s)
        trg_time_t=[trg_time_t i];
        %disp("trg : " + trg_time_t);
    end
end

disp(trg_time_t(1));
disp(trg_time_t(end));
length(task);
for i=2:length(task)/500+1
    trg_time_t(i+1)=trg_time_t(i)+500;
end

%trg_time_t(920:930)=[]; %% よくない 本当はデータをみてタイミングがずれているトリガは削除
trg_time_t(901:end)=[];
plot(trg_time_t(2:end)-trg_time_t(1:end-1)); %% trigger確認 %% 全ての間を示している(つまり全て1s間になっているかを確認できる)
xlim([0,900]);% ここで、分析範囲を指定している(この人は15分だったので、900/60 = 15となる)
% 上記理由 : トリガー同士の間が1秒あるので、それが900ステップで900秒ということ
 %% 最後のトリガより後ろのデータがないので最後のトリガは使わない


%% epoch（1秒区切り）
freq=500;
div_sec=1;
% task(end,:)=[]; %最終行にNaNが含まれる場合に使用

EEG_task=task(:,1:8);% 第二引数の「1:8」でrawdataの列を指定(脳波データだけ送る)
EEG_task(end+1:455000,1:8)=0;% よく分からんが、0を後ろにつけ足している
div_EEG_task=[];
PLI_t=[];

% 恐らくこいつは、60 ~ 900までを分析に使おうとしていた?
%for n=1:length(trg_time_t)
for n=60:length(trg_time_t)
%for n=60:900
    for i=1:60
        time=i+n-60;
        div_EEG_task(:,:,i)=EEG_task(trg_time_t(time):trg_time_t(time)+freq*div_sec-1,:);
    end
    %for i=1:60
    %    div_EEG_task(:,:,i)=EEG_task(trg_time_t(n):trg_time_t(n)+freq*div_sec-1,:);
    %end
    
    %% フーリエ変換して周波数情報を取得
    FT = fft(div_EEG_task);
    POWER=abs(FT).^2;
    len =length(FT);
    f=freq/2*linspace(0,1,len/2+1);
    
    %% PLIを計算 (n(第4引数)が時間軸, 恐らく第一引数がHzを表していて、41 => 40Hzを表していると思われる)
    for ch_num=1:size(FT,2)
        PLI_t(:,ch_num,:,n)=squeeze(abs(mean(squeeze(FT(:,ch_num,:))./abs(squeeze(FT(:,ch_num,:))),2)));
    end
end

%% 結果プロット
figure(2);
%plot(PLI_t(2:51,4,1,180)); %60sから最後まで選択して表示
plot(PLI_t(2:500,4,1,64)); %60sから最後まで選択して表示

%% task中の40hz帯の時間変化
% 40hz=[];
% for i=60:length(trg_time_t)
%     40hz(i,1:8)=-PLI_t(41,1:8,1,i);
% end
% 40hz(conc(60:end,5))

%% rest-taskの時間変異
concentration(1:900)=0;
%for i=60:900
for i=60:64
    %concentration(i,1:8)=PLI_r(41,1:8)-PLI_t(41,1:8,1,i);
    concentration(i,1:8)=PLI_t(41,1:8)-PLI_t(41,1:8,1,i);
end

% 頭頂部のrest-taskの平均
workload_per_s=[];
workload_per_s(:,:)=(concentration(:,3)+concentration(:,4)+concentration(:,5))*(1/3);

%workload_per_s(:,:)=concentration(:,3);%09は３のみ
figure(3);
plot(workload_per_s(:,:));

% NaN処理!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

min_isnan_wps=900;
for i=900:-1:60
    if isnan(workload_per_s(i))
        min_isnan_wps=i;
    else
        break
    end
end

for i=min_isnan_wps:900
    workload_per_s(i)=workload_per_s(i-1);
end

workload_per_s = fillmissing(workload_per_s,'linear');

% 1分毎加算平均

workload_per_m=[];
for i=1:15
    workload_per_m(i)=mean(workload_per_s((i-1)*60+1:i*60));
end

workload_per_10s=[];
for i=1:90
    workload_per_10s(i)=mean(workload_per_s((i-1)*10+1:i*10));
end
    
%% 確認
subplot(3,1,1);
plot(workload_per_s);
subplot(3,1,2);
plot(workload_per_m);
subplot(3,1,3);
plot(workload_per_10s);
%% SAVE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%% test1
            wps_test1=[];
            wps_test1=workload_per_s(1:900);
            wpm_test1=workload_per_m(1:15);
            wp10s_test1 = workload_per_10s(1:90);
            disp('SAVE test1');
%% test2
            wps_test2=[];
            wps_test2=workload_per_s(1:900);
            wpm_test2=workload_per_m(1:15);
            wp10s_test2 = workload_per_10s(1:90);
            disp('SAVE test2');
%% read
            wps_read=[];
            wps_read=workload_per_s(1:900);
            wpm_read=workload_per_m(1:15);
            wp10s_read = workload_per_10s(1:90);
            disp('SAVE read');
%% All 確認
            Zwps_test1(1:60)=0;
            Zwps_test1(61:900)=zscore(wps_test1(61:900));
            Zwps_test2(1:60)=0;
            Zwps_test2(61:900)=zscore(wps_test2(61:900));
            Zwps_read(1:60)=0;
            Zwps_read(61:900)=zscore(wps_read(61:900));
            
            th=1.8; %% 閾値設定！！！！！！！！！！！！！！！！！！！！！！！
            
            figure();
            subplot(2,1,1);
            plot(Zwps_test1);
            hold on
            plot(Zwps_test2);
            plot(Zwps_read);
            hline = refline([0 th]);
            hline.Color='r';
            hline = refline([0 -th]);
            hline.Color='r';
            hold off
            legend('test1','test2','read');

            subplot(2,1,2);
            Zwpm_test1=zscore(wpm_test1);
            Zwpm_test2=zscore(wpm_test2);
            Zwpm_read=zscore(wpm_read);
            plot(Zwpm_test1);
            hold on;
            plot(Zwpm_test2);
            plot(Zwpm_read);
            hold off;
            legend('test1','test2','read');
            