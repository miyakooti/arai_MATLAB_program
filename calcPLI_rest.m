%% rest(���펞PLI�����߂� => PLI_r�Ƃ���)

%% EEG��ǂݍ���

task=[];
task(:,:)=rawdata(:,:);% �����œǂݍ���
disp('load rawdata');

%% �`���l���ݒ� �����]�g�v�f�[�^�ɍ��킹�ĕύX����
EEG_CH_index = 1:7; % �]�g
FC3_index = 2;
FC4_index = 3;
FCz_index = 4;
ASSR_CH_index = 2:4;

ECG_CH_index = 8; % �S�d�}
EX1_CH_index = 9; % �g���K�[
EX2_CH_index = 10; % �t�H�g�f�B�e�N�^

%% �T���v�����O���g��
freq=500;

%% �g���K�[���o�͂��āA���o�I��臒l(�ǂ̒l�ȏオ�N���b�N���̎n�܂肩?)��������
figure(1)
subplot(2,1,1);
plot(task(:,EX1_CH_index)); % EX1 40Hz�N���b�N��
title('Trigger')

subplot(2,1,2);
plot(task(:,EX2_CH_index)); % EX2 �t�H�g�f�B�e�N�^
title('photo detector')




%% 臒l��ݒ�
trg_time_t=[];% �g���K�[�̎n�܂�̍s�����擾����
th_s=-1000;% ������臒l������% �������ق��ɍ��킹��(�ꔭ�ڂ̃g���K�[�����Ɉ��������邾���ł悳����)

%% ���͂���S�Ẵg���K�[���擾
for i=2:length(task)
    % 臒l���}�C�i�X�̏ꍇ�́A������2�̕s�������t�ɂȂ�
    if(task(i,EX1_CH_index) < th_s && task(i-1,EX1_CH_index) > th_s)% 臒l���傫�����A�O�̃f�[�^��臒l�����ł���΁A������g���K�[�̊J�n�Ƃ���
        trg_time_t=[trg_time_t i];
    end
end
% �g���K�[���o�Ă���͈͂𖾂炩�ɂ��Ă���

disp("----------------------------------------")
disp("initial trigger time = " + trg_time_t(1));% for debug
disp("end of trigger time = " + trg_time_t(end));% for debug
disp("trg length = " + length(task));
disp("----------------------------------------")

% 500step(=1s)���݂̒l���g���K�[�^�C���Ƃ��Ēǉ�(�N���b�N����1s���ɌJ��Ԃ���邽��)
for i=2:length(task)/500+1
    trg_time_t(i+1)=trg_time_t(i)+500;
end

% 5min(=300s)�Ԃ̕��͂�z�肵���R�[�h�Ƃ���B
%% ��������ǂ��āAcalc_time�Ԃ̕��͂�z�肷��B
calc_time = 300;
trg_time_t(calc_time+1:end)=[]; %% calc_time�ȍ~�͋�z��ŏ㏑�����Đ؂�̂Ă�
plot(trg_time_t(2:end)-trg_time_t(1:end-1)); %% trigger�m�F % �g���K�[�Ԃ̃f�[�^�����S��500step(1s)�ɂȂ��Ă��邩�����o�I�Ɋm�F����
xlim([0,calc_time]);% 0~300(5min)�܂łőł��؂�(���͂ɂ͂����܂ł����K�v�Ȃ�����)

%% epoch�i1�b��؂�ō쐬����j
div_sec=1;%% �ǂ̂��炢�̒����ŋ�؂邩? => �����1s���ɋ�؂�

EEG_task=task(:,EEG_CH_index);% EEG�f�[�^�����������B
EEG_task(end+1:155000,EEG_CH_index)=0;%% �v���X10s���Ă���(���炭�v���O�������~�܂�Ȃ��悤�ɂ��邽��)((300 + 10)s * 500hz)
div_EEG_task=[];% 1s���̔]�g�f�[�^���擾����Ƃ��� % �܂��A3�����ڂ�����60�ł��邪�A�����60s�Ԃ̃f�[�^�������Ă����(PLI�Z�o�ɂ�60s�Ԃ̃f�[�^���K�v)
PLI_r=[];

%% ���g�������ł�PLI�Z�o
for n=60:length(trg_time_t)
    for i=1:60
        time=i+n-60;
        div_EEG_task(:,:,i)=EEG_task(trg_time_t(time):trg_time_t(time)+freq*div_sec-1,:);% 60s�Ԃ̔]�g�f�[�^���擾
    end
    
    %% �t�[���G�ϊ����Ď��g�������擾
    FT = fft(div_EEG_task);
    POWER=abs(FT).^2;
    len =length(FT);
    f=freq/2*linspace(0,1,len/2+1);
    
    %% PLI���v�Z
    % size(FT,2) = 6�ɂȂ�͂� => �`�����l����(�d�ɐ�)
    for ch_num=1:size(FT,2)
        PLI_r(:,ch_num,:,n)=squeeze(abs(mean(squeeze(FT(:,ch_num,:))./abs(squeeze(FT(:,ch_num,:))),2)));
        % toukei(ch_num, :) = squeeze(FT(41,ch_num,:))./abs(squeeze(FT(41,ch_num,:)));
    end
end
% PLI_t => ������: Hz, ������: �`�����l��(�d��), ��O����: ?(1�̂�), ��l����: ����(60~1200(s))
% PLI�����g���ʂɌ��Ă݂�(������Hz)
figure(2);
plot(PLI_r(2:500,FC3_index,1,200));% 1:���g������, 2:�`�����l��(�d��), 3:�ǂ��������(1�̂�), 4:����(60~420)
title('���g����PLI');

%% ���ԕ����ł�PLI���o��(40Hz�����������o����)
PLI(1:calc_time,ECG_CH_index-1) = 0;% for output(40Hz)
for i = 60:calc_time
    PLI(i, EEG_CH_index) = PLI_r(41, EEG_CH_index, 1, i);% �u1:6�v�̏����u2�v�Ƃ��ɂ���΁A1�̓d�ɂ����̃f�[�^���o��
end
% output
figure(3);
plot(PLI(:,ASSR_CH_index));
title('PLI�̎��n��ω�');


% output mean
disp("mean_CH1(�܂Ԃ�) : " + mean(PLI(60:calc_time,1)));
disp("mean_FC3 : " + mean(PLI(60:calc_time,2)));
disp("mean_FC4 : " + mean(PLI(60:calc_time,3)));
disp("mean_FCz : " + mean(PLI(60:calc_time,4)));
disp("mean_O1 : " + mean(PLI(60:calc_time,5)));
disp("mean_O2 : " + mean(PLI(60:calc_time,6)));
disp("mean_�܂Ԃ� : " + mean(PLI(60:calc_time,7)));
disp("meanAll : " + mean(mean(PLI(60:calc_time,:))));
disp("mean FC2,FC3,FCz : " + mean(mean(PLI(60:calc_time,2:4))));

