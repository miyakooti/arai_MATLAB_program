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
%% �f�[�^�C���|�[�g��������
%����X�^�[�g���狰�|�I�u�W�F�N�g�o���܂ł̔]�g�̐؂�o���̃v���O����������
fear_EEG=sub02fear23;
nofear_EEG = nofearkanamaru;
%% �Z���ԃt�[���G�ϊ�
%������f��fear, nf��nofear
for ch=1:5
    Tf = fear_EEG(:,ch);
    [Sf,wf,tf,psf]=spectrogram(Tf,500,[],500,500); 
        %[S,w,t] S�f�[�^ w���g�� t�f�[�^����
        %s = spectrogram(EEGdata,window�̐�,noverlap�f�[�^�̃I�[�o�[���b�v,��Hz���Ƃɏo����,�T���v�����O���g��)
    fear_EEG_fftdata(ch,:,:)=psf(2:41,:);
end
for ch=1:5
    Tnf = nofear_EEG(:,ch);
    [Snf,wnf,tnf,psnf]=spectrogram(Tnf,500,[],500,500); 
        %[S,w,t] S�f�[�^ w���g�� t�f�[�^����
        %s = spectrogram(EEGdata,window�̐�,noverlap�f�[�^�̃I�[�o�[���b�v,��Hz���Ƃɏo����,�T���v�����O���g��)
    nofear_EEG_fftdata(ch,:,:)=psnf(2:41,:);
end
%================================================
%% �e���g���ш悲�Ƃɕ�����
    %theta = 4~8 Hz
    %alpha = 8~14 Hz
    %beta = 14~38 Hz
%�ǉ��Ń~���[���������邩��
for ch=1:5
for n=1:length(tf)
    fear_theta_data = mean(fear_EEG_fftdata(ch,4:8,n));
    fear_alpha_data = mean(fear_EEG_fftdata(ch,9:14,n));
    fear_beta_data = mean(fear_EEG_fftdata(ch,14:38,n));
    
    %�e���g���т̎w�莞�Ԃ��Ƃ̕��ϒl�����ԂɃO���t�p�z��Ɋi�[
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
    
    %�e���g���т̎w�莞�Ԃ��Ƃ̕��ϒl�����ԂɃO���t�p�z��Ɋi�[
    nofear_theta_graph(ch,n) = nofear_theta_data;
    nofear_alpha_graph(ch,n) = nofear_alpha_data;
    nofear_beta_graph(ch,n) = nofear_beta_data;
end
end




%% AVERAGE,�������ƌ㓪���̃f�[�^�ɕ���
%������ɕ��ς������Ă���
%ch���̃f�[�^�̕��ϒl���킩��
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

%size�̒��g�̍s�Ɨ񐬕��̑傫���������Ă���
[row,column]=size(fear_theta_data);

%�㓪���A�������f�[�^���Z����
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
%% T����(�������ƌ㓪���Ɋւ���)
SUM_theta_h=[];
SUM_theta_p=[];
SUM_alpha_h=[];
SUM_alpha_p=[];
SUM_beta_h=[];
SUM_beta_p=[];

for ch=1:2 %ch�ݒ�
    SUM_NF_Theta = SUM_NF_theta(ch,:);
    SUM_F_Theta = SUM_F_theta(ch,:);

    SUM_NF_Alpha = SUM_NF_alpha(ch,:);
    SUM_F_Alpha = SUM_F_alpha(ch,:);

    SUM_NF_Beta = SUM_NF_beta(ch,:);
    SUM_F_Beta = SUM_F_beta(ch,:);


% t���� theta
    if vartest2(SUM_F_Theta,SUM_NF_Theta) == 0
        %abs(var(r_data_theta)-var(p_data_theta)) <= 1 %���U���傫������������
         [h,p,ci,stats] = ttest2(SUM_F_Theta,SUM_NF_Theta,'Dim',2,'Tail','both','Vartype','equal');
    else
         [h,p,ci,stats] = ttest2(SUM_F_Theta,SUM_NF_Theta,'Dim',2,'Tail','both','Vartype','unequal');
    end

    SUM_theta_h(ch)=h;
    SUM_theta_p(ch)=p;

    % t���� alpha
    if vartest2(SUM_F_Alpha,SUM_NF_Alpha) == 0
        %abs(var(r_data_alpha)-var(p_data_alpha)) <= 1 %���U���傫������������
        [h,p,ci,stats] = ttest2(SUM_F_Alpha,SUM_NF_Alpha,'Dim',2,'Tail','both','Vartype','equal');
    else
        [h,p,ci,stats] = ttest2(SUM_F_Alpha,SUM_NF_Alpha,'Dim',2,'Tail','both','Vartype','unequal');
    end

    SUM_alpha_h(ch)=h;
    SUM_alpha_p(ch)=p;

    % t���� beta
    if vartest2(SUM_F_Beta,SUM_NF_Beta) == 0
        %abs(var(r_data_beta)-var(p_data_beta)) <= 1 %���U���傫������������
        [h,p,ci,stats] = ttest2(SUM_F_Beta,SUM_NF_Beta,'Dim',2,'Tail','both','Vartype','equal');
    else
        [h,p,ci,stats] = ttest2(SUM_F_Beta,SUM_NF_Beta,'Dim',2,'Tail','both','Vartype','unequal');
    end

    SUM_beta_h(ch)=h;
    SUM_beta_p(ch)=p;

end
%% ���ʂ̊i�[
%result_all��alpha,beta,theta�̗L�Ӎ��̌��ʁAalpha,beta,theta�̊m���̏��Ŋi�[

result_all(1,:,playerNum) = SUM_alpha_h;
result_all(2,:,playerNum) = SUM_beta_h;
result_all(3,:,playerNum) = SUM_theta_h;
result_all(4,:,playerNum) = SUM_alpha_p;
result_all(5,:,playerNum) = SUM_beta_p;
result_all(6,:,playerNum) = SUM_theta_p;

%result_ave�͋��|�A�񋰕|��alpha,beta,theta�̏���avarage���i�[
result_ave(1,:,playerNum) = Ave_F_alpha;
result_ave(2,:,playerNum) = Ave_F_beta;
result_ave(3,:,playerNum) = Ave_F_theta;
result_ave(4,:,playerNum) = Ave_NF_alpha;
result_ave(5,:,playerNum) = Ave_NF_beta;
result_ave(6,:,playerNum) = Ave_NF_theta;