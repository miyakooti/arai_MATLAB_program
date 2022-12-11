%% ワークロードを算出するプログラム(正常時PLI - タスク時PLI)
% あらかじめ、PLI_r(正常時PLI)を別途出す必要がある(calcPLI_rest.m)で算出可能
% まぶた用電極も入れた8chでの分析用プログラム
%% EEGを読み込む

task=[];
task(:,:)=rawdata(:,:);% ここで読み込み
%EEG_data(:,1:6) = rawdata(:,1:6);
% ハイパスフィルタをかける(また、EEG部分のみ取り出す)
%for i=1:6
%    task(:,i) = highpass(rawdata(:,i),1.0,500,'ImpulseResponse','fir');% 第二引数が周波数(1.0Hz)、第三引数がサンプリング周波数
    %EEG_data(:,i) = highpass(rawdata(:,i),1,500);
%end
% ハイパスフィルタ終了
%% infomaxの時
% task(:,1:6) = independence(:,:);

%% 時間同期用に最初の部分を切る(データをなくす)
% Kinectとの時間同期後に数値を変える(時間同期まとめ.mdの数値を参考に変更する)
%task(1:7634,:)=[];% この場合、1~7634までのデータをなくす

disp('load rawdata');

%% トリガーを出力して、視覚的に閾値(どの値以上がクリック音の始まりか?)を見つける
figure(1);
subplot(2,1,1);
plot(task(:,7)); % EX1 40Hzクリック音
subplot(2,1,2);
plot(task(:,8)); % EX2 フォトディテクタ

%% 閾値を設定
trg_time_t=[];% トリガーの始まりの行数を取得する
th_s=-1238;% ここに閾値を入れる% 小さいほうに合わせる(一発目のトリガーだけに引っかかるだけでよさそう)

%% 分析する全てのトリガーを取得
for i=2:length(task)
    % 閾値がプラスの場合は、ここの2つの不等号が逆になる
    if(task(i,7) < th_s && task(i-1,7) > th_s)% 閾値より大きくかつ、前のデータが閾値未満であれば、それをトリガーの開始とする
        trg_time_t=[trg_time_t i];
    end
end

disp(trg_time_t(1));% for debug
disp(trg_time_t(end));%for debug
length(task);

% 500step(=1s)刻みの値をトリガータイムとして追加(クリック音が1s毎に繰り返されるため)
for i=2:length(task)/500+1
    trg_time_t(i+1)=trg_time_t(i)+500;
end

% Kinectとの時間同期の為に不要なデータを取り除く 
firstTime = 3207; %% <=「時間同期まとめ.md」にメモしてある数値を入れる %%
diff = firstTime - trg_time_t(1);
firstIndex = diff / 500 + 1;
trg_time_t(1:firstIndex-1) = [];% 不要な部分を消去

% 20min(=1200s)間の分析を想定したコードとする。
%trg_time_t(920:930)=[]; %% よくない 本当はデータをみてタイミングがずれているトリガは削除
trg_time_t(1201:end)=[];
plot(trg_time_t(2:end)-trg_time_t(1:end-1)); %% trigger確認 % トリガー間のデータ数が全て500step(1s)になっているかを視覚的に確認する
xlim([0,1200]);% 0~1200(12min)までで打ち切る(分析にはここまでしか必要ないから)
% ラストのトリガーは実質使用しない(それより後のデータが無いため、PLIを求められないから)
%% epoch（1秒区切り）
freq=500;%% サンプリング周波数(EEGの)
div_sec=1;%% どのくらいの長さで区切るか? => 今回は1s毎に区切る
% task(end,:)=[]; %最終行にNaNが含まれる場合に使用

EEG_task=task(:,1:6);% EEGデータだけ抜き取る
EEG_task(end+1:605000,1:6)=0;%% プラス10sしている(恐らくプログラムが止まらないようにするため)((1200 + 10)s * 500hz)
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
plot(PLI_t(2:500,4,1,180));
% for debug => やはり、41が40Hzを表していた。
%disp("40 : " + PLI_t(40,4,1,180));
%disp("41 : " + PLI_t(41,4,1,180));

%% 時間単位でのPLIを出力(40Hz部分だけ抽出する)
PLI40(1:1200, 6) = 0;% for output(40Hz)
for i = 60:1200
    PLI40(i, 1:6) = PLI_t(41, 1:6, 1, i);% 「1:5」の所を「2」とかにすれば、1つの電極だけのデータが出る
end
% output
figure(3);
title("PLI 40Hzのみ");
plot(PLI40(:,4));
disp("mean1(まぶた) : " + mean(PLI40(60:1200,1)));
disp("mean2 : " + mean(PLI40(60:1200,2)));
disp("mean3 : " + mean(PLI40(60:1200,3)));
disp("mean4 : " + mean(PLI40(60:1200,4)));
disp("mean5 : " + mean(PLI40(60:1200,5)));
disp("mean6 : " + mean(PLI40(60:1200,6)));
disp("meanAll : " + mean(mean(PLI40(60:1200,:))));

%% PLI_rの平均を求める(60s ~ => 60s以前は全て0のため)
% mean(PLI_r(41,1:5,1,60:300), 4);% この一行で求められたので、下に直接ぶち込んだ
%% rest-taskの時間変異(workloadを算出する)(PLI_r必要)
concentration(1:1200)=0;
for i=60:1200
    concentration(i,1:6)=mean(PLI_r(41,1:6,1,60:300), 4) - PLI_t(41,1:6,1,i);
end

% C3, Cz, C4を平均して、workloadとしても良い
% 以下は、全ての電極のワークロードをプロットする
figure(4);
title("workload 電極2");
plot(concentration(:,2));
figure(5);
title("workload 電極3");
plot(concentration(:,3));
figure(6);
title("workload 電極4");
plot(concentration(:,4));