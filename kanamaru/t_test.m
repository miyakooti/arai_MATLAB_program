player = "player1";
if (player == "player1")
    playerNum = 1;
    fear_num = [2 3];
    load('sub01ansei.mat');
    load('sub01fear2.mat');
    load('sub01fear3.mat');
    load('sub01nofear2.mat');
    load('sub01nofear3.mat');
%     load('sub01fear2EEG.mat');
%     load('sub01fear3EEG.mat');
%     load('sub01nofear2EEG.mat');
%     load('sub01nofear3EEG.mat');    
end
if (player == "player2")
    playerNum = 2;
    fear_num = [1 2];
    load('sub02ansei.mat');
    load('sub02fear1.mat');
    load('sub02fear2.mat');
    load('sub02nofear1.mat');
    load('sub02nofear2.mat'); 
end
if (player == "player4")
    playerNum = 4;
    fear_num = 3;
    load('sub04ansei.mat');
    load('sub04fear3.mat');
    load('sub04nofear3.mat'); 
end
if (player == "player5")
    playerNum = 5;
    fear_num = [1 2];
    load('sub05ansei.mat');
    load('sub05fear1.mat');
    load('sub05fear2.mat');
    load('sub05nofear1.mat');
    load('sub05nofear2.mat'); 
end
if (player == "player2")
    playerNum = 2;
    fear_num = [1 2];
    load('sub02ansei.mat');
    load('sub02fear1.mat');
    load('sub02fear2.mat');
    load('sub02nofear1.mat');
    load('sub02nofear2.mat'); 
end
if (player == "player6")
    playerNum = 6;
    fear_num = 1;
    load('sub06ansei.mat');
    load('sub06fear1.mat');
    load('sub06nofear1.mat'); 
end
if (player == "player7")
    playerNum = 7;
    fear_num = 2;
    load('sub07ansei.mat');
    load('sub07fear2.mat');
    load('sub07nofear2.mat'); 
end

load('sub07ansei');
%% データインポートをした後
%動画スタートから恐怖オブジェクト出現までの脳波の切り出しのプログラムを書く
fear_EEG=sub02fear23;
nofear_EEG = nofearkanamaru;
%% 短時間フーリエ変換
%末尾にfはfear, nfはnofear
for ch=1:5
    Tf = fear_EEG(:,ch);
    [Sf,wf,tf,psf]=spectrogram(Tf,500,[],500,500); 
        %[S,w,t] Sデータ w周波数 tデータ時間
        %s = spectrogram(EEGdata,windowの数,noverlapデータのオーバーラップ,何Hzごとに出すか,サンプリング周波数)
    fear_EEG_fftdata(ch,:,:)=psf(2:41,:);
end
for ch=1:5
    Tnf = nofear_EEG(:,ch);
    [Snf,wnf,tnf,psnf]=spectrogram(Tnf,500,[],500,500); 
        %[S,w,t] Sデータ w周波数 tデータ時間
        %s = spectrogram(EEGdata,windowの数,noverlapデータのオーバーラップ,何Hzごとに出すか,サンプリング周波数)
    nofear_EEG_fftdata(ch,:,:)=psnf(2:41,:);
end
%================================================
%% 各周波数帯域ごとに分ける
    %theta = 4~8 Hz
    %alpha = 8~14 Hz
    %beta = 14~38 Hz
%追加でミュー律動を見るかも
for ch=1:5
for n=1:length(tf)
    fear_theta_data = mean(fear_EEG_fftdata(ch,4:8,n));
    fear_alpha_data = mean(fear_EEG_fftdata(ch,9:14,n));
    fear_beta_data = mean(fear_EEG_fftdata(ch,14:38,n));
    
    %各周波数帯の指定時間ごとの平均値を順番にグラフ用配列に格納
    fear_theta_graph(ch,n) = fear_theta_data;
    fear_alpha_graph(ch,n) = fear_alpha_data;
    fear_beta_graph(ch,n) = fear_beta_data;
end
end
for ch=1:5
for n=1:length(tnf)
    nofear_theta_data = mean(nofear_EEG_fftdata(ch,4:8,n));
    nofear_alpha_data = mean(nofear_EEG_fftdata(ch,9:14,n));
    nofear_beta_data = mean(nofear_EEG_fftdata(ch,14:38,n));
    
    %各周波数帯の指定時間ごとの平均値を順番にグラフ用配列に格納
    nofear_theta_graph(ch,n) = nofear_theta_data;
    nofear_alpha_graph(ch,n) = nofear_alpha_data;
    nofear_beta_graph(ch,n) = nofear_beta_data;
end
end




%% AVERAGE,頭頂部と後頭部のデータに分割
%列方向に平均を持ってくる
%ch毎のデータの平均値がわかる
Ave_F_theta = mean(fear_theta_graph,2);
Ave_F_beta = mean(fear_beta_graph,2);
Ave_F_alpha = mean(fear_alpha_graph,2);
Ave_NF_theta = mean(nofear_theta_graph,2);
Ave_NF_beta = mean(nofear_beta_graph,2);
Ave_NF_alpha = mean(nofear_alpha_graph,2);

SUM_F_theta = [];
SUM_F_alpha = [];
SUM_F_beta = [];
SUM_NF_theta = [];
SUM_NF_alpha = [];
SUM_NF_beta = [];

%sizeの中身の行と列成分の大きさを持ってくる
[row,column]=size(fear_theta_data);

%後頭部、頭頂部データ加算平均
for i =1:column
    SUM_F_theta(1,i) = (fear_theta_data(1,i)+fear_theta_data(2,i)+fear_theta_data(3,i))/3;
    SUM_F_theta(2,i) = (fear_theta_data(4,i)+fear_theta_data(5,i)+fear_theta_data(6,i))/3;
    SUM_F_alpha(1,i) = (fear_alpha_data(1,i)+fear_alpha_data(2,i)+fear_alpha_data(3,i))/3;
    SUM_F_alpha(2,i) = (fear_alpha_data(4,i)+fear_alpha_data(5,i)+fear_alpha_data(6,i))/3;
    SUM_F_beta(1,i) = (fear_beta_data(1,i)+fear_beta_data(2,i)+fear_beta_data(3,i))/3;
    SUM_F_beta(2,i) = (fear_beta_data(4,i)+fear_beta_data(5,i)+fear_beta_data(6,i))/3;
end
for i = 1:length(nofear_theta_data)
    SUM_NF_theta(1,i) = (nofear_theta_data(1,i)+nofear_theta_data(2,i)+nofear_theta_data(3,i))/3;
    SUM_NF_theta(2,i) = (nofear_theta_data(4,i)+nofear_theta_data(5,i)+nofear_theta_data(6,i))/3;
    SUM_NF_alpha(1,i) = (nofear_alpha_data(1,i)+nofear_alpha_data(2,i)+nofear_alpha_data(3,i))/3;
    SUM_NF_alpha(2,i) = (nofear_alpha_data(4,i)+nofear_alpha_data(5,i)+nofear_alpha_data(6,i))/3;
    SUM_NF_beta(1,i) = (nofear_beta_data(1,i)+nofear_beta_data(2,i)+nofear_beta_data(3,i))/3;
    SUM_NF_beta(2,i) = (nofear_beta_data(4,i)+nofear_beta_data(5,i)+nofear_beta_data(6,i))/3;
end
%% T検定(頭頂部と後頭部に関して)
SUM_theta_h=[];
SUM_theta_p=[];
SUM_alpha_h=[];
SUM_alpha_p=[];
SUM_beta_h=[];
SUM_beta_p=[];

for ch=1:2 %ch設定
    SUM_NF_Theta = SUM_NF_theta(ch,:);
    SUM_F_Theta = SUM_F_theta(ch,:);

    SUM_NF_Alpha = SUM_NF_alpha(ch,:);
    SUM_F_Alpha = SUM_F_alpha(ch,:);

    SUM_NF_Beta = SUM_NF_beta(ch,:);
    SUM_F_Beta = SUM_F_beta(ch,:);


% t検定 theta
    if vartest2(SUM_F_Theta,SUM_NF_Theta) == 0
        %abs(var(r_data_theta)-var(p_data_theta)) <= 1 %分散が大きいか小さいか
         [h,p,ci,stats] = ttest2(SUM_F_Theta,SUM_NF_Theta,'Dim',2,'Tail','both','Vartype','equal');
    else
         [h,p,ci,stats] = ttest2(SUM_F_Theta,SUM_NF_Theta,'Dim',2,'Tail','both','Vartype','unequal');
    end

    SUM_theta_h(ch)=h;
    SUM_theta_p(ch)=p;

    % t検定 alpha
    if vartest2(SUM_F_Alpha,SUM_NF_Alpha) == 0
        %abs(var(r_data_alpha)-var(p_data_alpha)) <= 1 %分散が大きいか小さいか
        [h,p,ci,stats] = ttest2(SUM_F_Alpha,SUM_NF_Alpha,'Dim',2,'Tail','both','Vartype','equal');
    else
        [h,p,ci,stats] = ttest2(SUM_F_Alpha,SUM_NF_Alpha,'Dim',2,'Tail','both','Vartype','unequal');
    end

    SUM_alpha_h(ch)=h;
    SUM_alpha_p(ch)=p;

    % t検定 beta
    if vartest2(SUM_F_Beta,SUM_NF_Beta) == 0
        %abs(var(r_data_beta)-var(p_data_beta)) <= 1 %分散が大きいか小さいか
        [h,p,ci,stats] = ttest2(SUM_F_Beta,SUM_NF_Beta,'Dim',2,'Tail','both','Vartype','equal');
    else
        [h,p,ci,stats] = ttest2(SUM_F_Beta,SUM_NF_Beta,'Dim',2,'Tail','both','Vartype','unequal');
    end

    SUM_beta_h(ch)=h;
    SUM_beta_p(ch)=p;

end
%% 結果の格納
%result_allはalpha,beta,thetaの有意差の結果、alpha,beta,thetaの確率の順で格納

result_all(1,:,playerNum) = SUM_alpha_h;
result_all(2,:,playerNum) = SUM_beta_h;
result_all(3,:,playerNum) = SUM_theta_h;
result_all(4,:,playerNum) = SUM_alpha_p;
result_all(5,:,playerNum) = SUM_beta_p;
result_all(6,:,playerNum) = SUM_theta_p;

%result_aveは恐怖、非恐怖のalpha,beta,thetaの順でavarageを格納
result_ave(1,:,playerNum) = Ave_F_alpha;
result_ave(2,:,playerNum) = Ave_F_beta;
result_ave(3,:,playerNum) = Ave_F_theta;
result_ave(4,:,playerNum) = Ave_NF_alpha;
result_ave(5,:,playerNum) = Ave_NF_beta;
result_ave(6,:,playerNum) = Ave_NF_theta;