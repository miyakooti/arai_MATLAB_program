
%% 自作PLI算出用プログラム(一秒毎のPLIを算出する)
% rest(平常時PLIを求める => PLI_rとする)
% ただし、今回はEEG電極が5つ、トリガー(40Hzクリック音), フォトディテクタの7つの場合
%% EEGを読み込む

task=[];
task(:,:)=rawdata(:,:);% ここで読み込み
% バンドパスフィルタをかける
%for i=1:6
%    task(:,i) = bandpass(rawdata(:,i),[35,45],500);% bandpass filter
%    task(:,i) = highpass(rawdata(:,i),1.0,500, 'ImpulseResponse','fir');
%end
% バンドパス
disp('load rawdata');

%% チャネル設定 これをデータに合わせて変更する
EX1_CH_index = 9;
EX2_CH_index = 10;

%% トリガーを出力して、視覚的に閾値(どの値以上がクリック音の始まりか?)を見つける
subplot(2,1,1);
plot(task(:,EX1_CH_index)); % EX1 40Hzクリック音
subplot(2,1,2);
plot(task(:,EX2_CH_index)); % EX2 フォトディテクタ

%% 閾値を設定
trg_time_t=[];% トリガーの始まりの行数を取得する
th_s=-1230;% ここに閾値を入れる% 小さいほうに合わせる(一発目のトリガーだけに引っかかるだけでよさそう)
% rawdataの赤いやつ

%% 分析する全てのトリガーを取得
for i=2:length(task)
    % 閾値がマイナスの場合は、ここの2つの不等号が逆になる
    if(task(i,7) < th_s && task(i-1,7) > th_s)% 閾値より大きくかつ、前のデータが閾値未満であれば、それをトリガーの開始とする
        trg_time_t=[trg_time_t i];
    end
end
% トリガーが出ている範囲を明らかにしている

disp(trg_time_t(1));% for debug
disp(trg_time_t(end));%for debug
disp("trg length = " + length(task));

% 500step(=1s)刻みの値をトリガータイムとして追加(クリック音が1s毎に繰り返されるため)
for i=2:length(task)/500+1
    trg_time_t(i+1)=trg_time_t(i)+500;
end

% 5min(=300s)間の分析を想定したコードとする。
%trg_time_t(920:930)=[]; %% よくない 本当はデータをみてタイミングがずれているトリガは削除
trg_time_t(301:end)=[]; %% 300s以降は切り捨てる
plot(trg_time_t(2:end)-trg_time_t(1:end-1)); %% trigger確認 % トリガー間のデータ数が全て500step(1s)になっているかを視覚的に確認する
xlim([0,300]);% 0~300(5min)までで打ち切る(分析にはここまでしか必要ないから)
% ラストのトリガーは実質使用しない(それより後のデータが無いため、PLIを求められないから)
%% epoch（1秒区切り）
freq=500;%% サンプリング周波数(EEGの)
div_sec=1;%% どのくらいの長さで区切るか? => 今回は1s毎に区切る
% task(end,:)=[]; %最終行にNaNが含まれる場合に使用

EEG_task=task(:,1:6);% EEGデータだけ抜き取る
EEG_task(end+1:155000,1:6)=0;%% プラス10sしている(恐らくプログラムが止まらないようにするため)((300 + 10)s * 500hz)
div_EEG_task=[];% 1s毎の脳波データを取得するところ % また、3次元目が毎回60であるが、これは60s間のデータを持っている為(PLI算出には60s間のデータが必要)
PLI_r=[];

%% PLI算出 60~になっているのは、PLIは1minの間の脳波を使って求めているので、60s立たないと最初のPLIを算出できないから
for n=60:length(trg_time_t)
%for n=60:300
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
        PLI_r(:,ch_num,:,n)=squeeze(abs(mean(squeeze(FT(:,ch_num,:))./abs(squeeze(FT(:,ch_num,:))),2)));
        % toukei(ch_num, :) = squeeze(FT(41,ch_num,:))./abs(squeeze(FT(41,ch_num,:)));
    end
end
% PLI_t => 第一引数: Hz, 第二引数: チャンネル(電極), 第三引数: ?(1のみ), 第四引数: 時間(60~1200(s))
% PLIを周波数別に見てみる(横軸はHz)
figure(2);
plot(PLI_r(2:500,4,1,200));% 1:周波数成分, 2:チャンネル(電極), 3:良く分からん(1のみ), 4:時間(60~420)

%% 時間単位でのPLIを出力(40Hz部分だけ抽出する)
PLI(1:300,6) = 0;% for output(40Hz)
for i = 60:300
    PLI(i, 1:6) = PLI_r(41, 1:6, 1, i);% 「1:6」の所を「2」とかにすれば、1つの電極だけのデータが出る
end
% output
figure(3);
plot(PLI(:,3));

% output mean
disp("mean1(まぶた) : " + mean(PLI(60:300,1)));
disp("mean2 : " + mean(PLI(60:300,2)));
disp("mean3 : " + mean(PLI(60:300,3)));
disp("mean4 : " + mean(PLI(60:300,4)));
disp("mean5 : " + mean(PLI(60:300,5)));
disp("mean6 : " + mean(PLI(60:300,6)));
disp("meanAll : " + mean(mean(PLI(60:300,:))));
