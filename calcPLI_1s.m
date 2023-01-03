%calcPLI_1s_mainに呼ばれて実行される
%これ単体では動かないので注意

task=[];
%task(フレーム,チャネル)
%1ch:'FpZ',2ch:'FC3',3ch:'FCz',4ch:'FC4',5ch:'O1',6ch:'O2'
%7ch:'trigger',8ch:未使用

%% チャネル設定 これを脳波計データに合わせて変更する
EEG_CH_index = 1:7; % 脳波
FC3_index = 2;
FC4_index = 3;
FCz_index = 4;
ASSR_CH_index = 2:4;

ECG_CH_index = 8; % 心電図
EX1_CH_index = 9; % トリガー
EX2_CH_index = 10; % フォトディテクタ

%% トリガ前処理
%理想的な音声刺激は0から約-1200くらいまで立ち上がって
%0.1秒間(50フレーム)-1200が続き，また0に戻る
%現実的には-1200に届かなかったり，0.1秒間の間に0に戻ったりするので
%初めて-600を下回ったタイミングから50フレームを強制的に-1200にする
th_s = -600;
for i=2:length(rawdata)
    % 閾値がプラスの場合は、ここの2つの不等号が逆になる
    if(rawdata(i,7) < th_s && rawdata(i-1,7) > th_s)% 閾値より大きくかつ、前のデータが閾値未満であれば、それをトリガーの開始とする
        x = min(i+50, length(rawdata));
        rawdata(i:x, 7) = -1239;
    end
end

%上の前処理でカバーしきれなかった部分を手直し
if subject == "nakamura_task4"
    th_s = -239;
elseif subject == "kanamaru_rest1"
    th_s = -198;
elseif subject == "kanamaru_task3"
    th_s = -287;
    rawdata(472553:472605, 7) = 0;
elseif subject == "naraha_task1"
    rawdata(300956:500:306456, 7) = -1239;
    rawdata(368953:500:372453, 7) = -1239;
    rawdata(374451:500:377051, 7) = -1239;
    rawdata(383451, 7) = -1239;
    th_s= -186;
elseif subject == "naraha_task3"
    rawdata(141183:500:152183, 7) = -1239;
    rawdata(166683:500:171183, 7) = -1239;
    rawdata(176181:500:179183, 7) = -1239;
    rawdata(188678:500:190178, 7) = -1239;
end

%% フィルタ処理
%rawdata(フレーム, チャンネル)
task(:,:)=rawdata(:,:);

%分析開始点
firstTime = M(subject);

% 関東の電源ノイズフィルタをかける
%サンプリングレートが1000Hzの場合
%{
load('bandstop50_1000.mat')
for i=1:6
    task(:,i)=filtfilt(Num,1,task(:,i));
end
%}
for i=1:6
    task(:,i)=bandstop(task(:,i), [49.9 50.1], 500);
end
% ノイズフィルタ終了

%% Kinectとの時間同期
%分析開始点前のデータをカット
%-3してるのは，ちょうどだと最初の立ち上がりを認識しない可能性があるため．
task(1:firstTime-3,:)=[];

% %% トリガの抽出
% trg_time_t=[];
% % 閾値より大きくかつ、前のデータが閾値未満であれば、それをトリガーの開始とする
% for i=2:length(task)
%     if(task(i,7) < th_s && task(i-1,7) > th_s)
%         trg_time_t=[trg_time_t i];
%         x = min(i+50, length(task));
%         task(i:x, 7) = -1239;
%     end
% end

%% 閾値を設定
trg_time_t=[];% トリガーの始まりの行数を取得する
th_s=-2000;% ここに閾値を入れる% 小さいほうに合わせる(一発目のトリガーだけに引っかかるだけでよさそう)

%% 分析する全てのトリガーを取得
for i=2:length(task)
    % 閾値がマイナスの場合は、ここの2つの不等号が逆になる
    if(task(i,EX1_CH_index) < th_s && task(i-1,EX1_CH_index) > th_s)% 閾値より大きくかつ、前のデータが閾値未満であれば、それをトリガーの開始とする
        trg_time_t=[trg_time_t i];
    end
end
% トリガーが出ている範囲を明らかにしている

disp("----------------------------------------")
disp("initial trigger time = " + trg_time_t(1));% for debug
disp("end of trigger time = " + trg_time_t(end));% for debug
disp("trg length = " + length(task));
disp("----------------------------------------")

%トリガタイミングのずれを可視化
diff = 500-(trg_time_t(2:end)-trg_time_t(1:end-1));
figure(1)
plot(diff); 
disp([sum(abs(diff)) sum(diff)]);

%% トリガタイミングから脳波を1秒の幅に分割
freq=500;%% EEGのサンプリング周波数
div_sec=1;%% どのくらいの長さで区切るか? => 今回は1s毎に区切る

EEG_task=task(:,1:6);% EEGデータだけ抜き取る
% div_EEG_task(フレーム,チャンネル,試行)
div_EEG_task=[];
PLI_t=[];

for i=1:length(trg_time_t)
    if(trg_time_t(i)+500 < length(EEG_task))
        div_EEG_task(:,:,i)=EEG_task(trg_time_t(i):trg_time_t(i)+freq*div_sec-1,:);
    end
end

%% フーリエ変換して周波数情報を取得

Phase = [];
%Phase(チャネル,試行)FC3,FCz,FC4の41Hzの位相情報を保存
%1sごとにフーリエ変換してFT,P,Phaseに代入
for i=1:size(div_EEG_task,3)
     Y = fft(div_EEG_task(:,:,i));
     FT(:,:,i)=Y;
     P(:,:,i)= sqrt(Y.*conj(Y));
     Phase(:,i) = FT(41,2:4,i)./abs(FT(41,2:4,i));
end
csvwrite("Phase/" + subject + ".csv",transpose(Phase));