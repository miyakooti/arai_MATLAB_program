%% ワークロードを算出するプログラム(正常時PLI - タスク時PLI)
% あらかじめ、PLI_r(正常時PLI)を別途出す必要がある(calcPLI_rest.m)で算出可能
% まぶた用電極も入れた8chでの分析用プログラム

%% EEGを読み込む
task=[];
task(:,:)=rawdata(:,:);
disp('load rawdata');

%% チャネル設定 これを脳波計データに合わせて変更する
EEG_CH_index = 1:7; % 脳波
FC3_index = 2;
FC4_index = 3;
FCz_index = 4;
ASSR_CH_index = 2:4;

ECG_CH_index = 8; % 心電図
EX1_CH_index = 9; % トリガー
EX2_CH_index = 10; % フォトディテクタ

%% サンプリング周波数
freq=500;

%% トリガーを出力して、視覚的に閾値(どの値以上がクリック音の始まりか?)を見つける
figure(1)
subplot(2,1,1);
plot(task(:,EX1_CH_index)); % EX1 40Hzクリック音
title('Trigger')

subplot(2,1,2);
plot(task(:,EX2_CH_index)); % EX2 フォトディテクタ
title('photo detector')

%% 閾値を設定
trg_time_t=[];% トリガーの始まりの行数を取得する
th_s=-2000;% ここに閾値を入れる% 小さいほうに合わせる(一発目のトリガーだけに引っかかるだけでよさそう)

%% 分析する全てのトリガーを取得
for i=2:length(task)
    % 閾値がプラスの場合は、ここの2つの不等号が逆になる
    if(task(i,EX1_CH_index) < th_s && task(i-1,EX1_CH_index) > th_s)% 閾値より大きくかつ、前のデータが閾値未満であれば、それをトリガーの開始とする
        trg_time_t=[trg_time_t i];
    end
end

disp(trg_time_t(1)); % for debug
disp(trg_time_t(end)); %for debug
length(task);

% 500step(=1s)刻みの値をトリガータイムとして追加(クリック音が1s毎に繰り返されるため)
for i=2:length(task)/500+1
    trg_time_t(i+1)=trg_time_t(i)+500;
end

% Kinectとの時間同期の為に不要なデータを取り除く 
% firstTime = 3207; %% <=「時間同期まとめ.md」にメモしてある数値を入れる %%
% diff = firstTime - trg_time_t(1);
% firstIndex = diff / 500 + 1;
% trg_time_t(1:firstIndex-1) = [];% 不要な部分を消去
% これはゲーム開始後にトリガーをスタートしているので、大丈夫だと思う

% 20min(=calc_times)間の分析を想定したコードとする。
% これを改良して、calc_time間の分析をできるようにする
if contains(subject, "ultra") 
    calc_time = 180; % 3 min
elseif contains(subject, "practice")
    calc_time = 160;
else    
    calc_time = 300; % 5 min
end

trg_time_t(calc_time+1:end)=[];
plot(trg_time_t(2:end)-trg_time_t(1:end-1)); %% trigger確認 % トリガー間のデータ数が全て500step(1s)になっているかを視覚的に確認する
xlim([0,calc_time]);% 0~calc_timeまでで打ち切る(分析にはここまでしか必要ないから)

%% epoch（1秒区切り）
div_sec=1;% どのくらいの長さで区切るか? => 今回は1s毎に区切る
EEG_task=task(:,EEG_CH_index);% EEGデータだけ抜き取る
EEG_task(end+1:605000,EEG_CH_index)=0;%% プラス10sしている(恐らくプログラムが止まらないようにするため)((1200 + 10)s * 500hz)
div_EEG_task=[];% 1s毎の脳波データを取得するところ % また、3次元目が毎回60であるが、これは60s間のデータを持っている為(PLI算出には60s間のデータが必要)
PLI_t=[];

%% PLI算出 60~になっているのは、PLIは1minの間の脳波を使って求めているので、60s立たないと最初のPLIを算出できないから
for n=60:length(trg_time_t)
%for n=60:1200
    for i=1:60
        time=i+n-60;
        div_EEG_task(:,:,i)=EEG_task(trg_time_t(time):trg_time_t(time)+freq*div_sec-1,:);% 60s間の脳波データを取得
    end
    
    %% フーリエ変換して周波数情報を取得
    FT = fft(div_EEG_task);
    POWER=abs(FT).^2;
    len =length(FT);
    f=freq/2*linspace(0,1,len/2+1);
    
    %% PLIを計算
    % size(FT,2) = 6になるはず => チャンネル数(電極数)
    for ch_num=1:size(FT,2)
        PLI_t(:,ch_num,:,n)=squeeze(abs(mean(squeeze(FT(:,ch_num,:))./abs(squeeze(FT(:,ch_num,:))),2)));
    end
end
% PLI_t => 第一引数: Hz, 第二引数: チャンネル(電極), 第三引数: ?(1のみ), 第四引数: 時間(60~1200(s))

%% 結果プロット
figure(2);
title("PLIの周波数成分");
plot(PLI_t(2:500,4,1,calc_time)); %2-500Hz
% for debug => やはり、41が40Hzを表していた。

%% 時間単位でのPLIを出力(40Hz部分だけ抽出する)
PLI40(1:calc_time, 6) = 0;% for output(40Hz)
for i = 60:calc_time
    PLI40(i, EEG_CH_index) = PLI_t(41, EEG_CH_index, 1, i);% チャネルインデックスは自由に変更してOK
end

% output　ここから出力される値は、rest状態の差分とか関係ない
figure(3);
title("PLI 40Hzのみ");
plot(PLI40(1:calc_time,ASSR_CH_index));
disp("mean_CH1(まぶた) : " + mean(PLI40(60:calc_time,1)));
disp("mean_FC3 : " + mean(PLI40(60:calc_time,2)));
disp("mean_FC4 : " + mean(PLI40(60:calc_time,3)));
disp("mean_FCz : " + mean(PLI40(60:calc_time,4)));
disp("mean_O1 : " + mean(PLI40(60:calc_time,5)));
disp("mean_O2 : " + mean(PLI40(60:calc_time,6)));
disp("mean_まぶた : " + mean(PLI40(60:calc_time,7)));
disp("meanAll : " + mean(mean(PLI40(60:calc_time,:))));
disp("mean FC2,FC3,FCz : " + mean(mean(PLI40(60:calc_time,ASSR_CH_index))));

%% PLI_rの平均を求める(60s ~ => 60s以前は全て0のため)
% mean(PLI_r(41,1:5,1,60:300), 4);% この一行で求められたので、下に直接ぶち込んだ
%% rest-taskの時間変異(workloadを算出する)(PLI_r必要)
concentration(1:calc_time)=0;
for i=60:calc_time
    concentration(i,EEG_CH_index)=mean(PLI_r(41,EEG_CH_index,1,60:calc_time), 4) - PLI_t(41,EEG_CH_index,1,i);
end

% C3, Cz, C4を平均して、workloadとしても良い
% 以下は、全ての電極のワークロードをプロットする
figure(4);
plot(concentration(1:calc_time,FC3_index));
title("workload FC3");

figure(5);
plot(concentration(1:calc_time,FC4_index));
title("workload FC4");

figure(6);
plot(concentration(1:calc_time,FCz_index));
title("workload FCz");
