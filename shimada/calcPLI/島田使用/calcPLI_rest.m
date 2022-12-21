
%% ����PLI�Z�o�p�v���O����(��b����PLI���Z�o����)
% rest(���펞PLI�����߂� => PLI_r�Ƃ���)
% �������A�����EEG�d�ɂ�5�A�g���K�[(40Hz�N���b�N��), �t�H�g�f�B�e�N�^��7�̏ꍇ
%% EEG��ǂݍ���

task=[];
task(:,:)=rawdata(:,:);% �����œǂݍ���
% �o���h�p�X�t�B���^��������
%for i=1:6
%    task(:,i) = bandpass(rawdata(:,i),[35,45],500);% bandpass filter
%    task(:,i) = highpass(rawdata(:,i),1.0,500, 'ImpulseResponse','fir');
%end
% �o���h�p�X
disp('load rawdata');

%% �`���l���ݒ� ������f�[�^�ɍ��킹�ĕύX����
EEG_CH_index = 1:7;
ECG_CH_index = 8; % �S�d�}
EX1_CH_index = 9; % �g���K�[
EX2_CH_index = 10; % �t�H�g�f�B�e�N�^

%% �g���K�[���o�͂��āA���o�I��臒l(�ǂ̒l�ȏオ�N���b�N���̎n�܂肩?)��������
subplot(2,1,1);
plot(task(:,EX1_CH_index)); % EX1 40Hz�N���b�N��
subplot(2,1,2);
plot(task(:,EX2_CH_index)); % EX2 �t�H�g�f�B�e�N�^

%% 臒l��ݒ�
trg_time_t=[];% �g���K�[�̎n�܂�̍s�����擾����
th_s=-1230;% ������臒l������% �������ق��ɍ��킹��(�ꔭ�ڂ̃g���K�[�����Ɉ��������邾���ł悳����)
% rawdata�̐Ԃ����

%% ���͂���S�Ẵg���K�[���擾
for i=2:length(task)
    % 臒l���}�C�i�X�̏ꍇ�́A������2�̕s�������t�ɂȂ�
    if(task(i,EX1_CH_index) < th_s && task(i-1,EX1_CH_index) > th_s)% 臒l���傫�����A�O�̃f�[�^��臒l�����ł���΁A������g���K�[�̊J�n�Ƃ���
        trg_time_t=[trg_time_t i];
    end
end
% �g���K�[���o�Ă���͈͂𖾂炩�ɂ��Ă���

disp(trg_time_t(1));% for debug
disp(trg_time_t(end));%for debug
disp("trg length = " + length(task));

% 500step(=1s)���݂̒l���g���K�[�^�C���Ƃ��Ēǉ�(�N���b�N����1s���ɌJ��Ԃ���邽��)
for i=2:length(task)/500+1
    trg_time_t(i+1)=trg_time_t(i)+500;
end

% 5min(=300s)�Ԃ̕��͂�z�肵���R�[�h�Ƃ���B
%% ��������ǂ��āAcalc_time�Ԃ̕��͂�z�肷��B
calc_time = 300;
%trg_time_t(920:930)=[]; %% �悭�Ȃ� �{���̓f�[�^���݂ă^�C�~���O������Ă���g���K�͍폜
trg_time_t(calc_time+1:end)=[]; %% 300s�ȍ~�͐؂�̂Ă�
plot(trg_time_t(2:end)-trg_time_t(1:end-1)); %% trigger�m�F % �g���K�[�Ԃ̃f�[�^�����S��500step(1s)�ɂȂ��Ă��邩�����o�I�Ɋm�F����
xlim([0,calc_time]);% 0~300(5min)�܂łőł��؂�(���͂ɂ͂����܂ł����K�v�Ȃ�����)
% ���X�g�̃g���K�[�͎����g�p���Ȃ�(�������̃f�[�^���������߁APLI�����߂��Ȃ�����)
%% epoch�i1�b��؂�j
freq=500;%% �T���v�����O���g��(EEG��)
div_sec=1;%% �ǂ̂��炢�̒����ŋ�؂邩? => �����1s���ɋ�؂�
% task(end,:)=[]; %�ŏI�s��NaN���܂܂��ꍇ�Ɏg�p

EEG_task=task(:,EEG_CH_index);% EEG�f�[�^�����������B�S�d�}�̃f�[�^�͓���Ȃ��悤�ɂ���
EEG_task(end+1:155000,EEG_CH_index)=0;%% �v���X10s���Ă���(���炭�v���O�������~�܂�Ȃ��悤�ɂ��邽��)((300 + 10)s * 500hz)
div_EEG_task=[];% 1s���̔]�g�f�[�^���擾����Ƃ��� % �܂��A3�����ڂ�����60�ł��邪�A�����60s�Ԃ̃f�[�^�������Ă����(PLI�Z�o�ɂ�60s�Ԃ̃f�[�^���K�v)
PLI_r=[];

%% PLI�Z�o 60~�ɂȂ��Ă���̂́APLI��1min�̊Ԃ̔]�g���g���ċ��߂Ă���̂ŁA60s�����Ȃ��ƍŏ���PLI���Z�o�ł��Ȃ�����
for n=60:length(trg_time_t)
%for n=60:300
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
plot(PLI_r(2:500,4,1,200));% 1:���g������, 2:�`�����l��(�d��), 3:�ǂ��������(1�̂�), 4:����(60~420)

%% ���ԒP�ʂł�PLI���o��(40Hz�����������o����)
PLI(1:calc_time,ECG_CH_index-1) = 0;% for output(40Hz)
for i = 60:calc_time
    PLI(i, EEG_CH_index) = PLI_r(41, EEG_CH_index, 1, i);% �u1:6�v�̏����u2�v�Ƃ��ɂ���΁A1�̓d�ɂ����̃f�[�^���o��
end
% output
figure(3);
plot(PLI(:,3));

% output mean
disp("mean_CH1(�܂Ԃ�) : " + mean(PLI(60:calc_time,1)));
disp("mean_CH2 : " + mean(PLI(60:calc_time,2)));
disp("mean_CH3 : " + mean(PLI(60:calc_time,3)));
disp("mean_CH4 : " + mean(PLI(60:calc_time,4)));
disp("mean_CH5 : " + mean(PLI(60:calc_time,5)));
disp("mean_CH6 : " + mean(PLI(60:calc_time,6)));
disp("meanAll : " + mean(mean(PLI(60:calc_time,:))));
