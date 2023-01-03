%% ���[�N���[�h���Z�o����v���O����(���펞PLI - �^�X�N��PLI)
% ���炩���߁APLI_r(���펞PLI)��ʓr�o���K�v������(calcPLI_rest.m)�ŎZ�o�\
% �܂Ԃ��p�d�ɂ����ꂽ8ch�ł̕��͗p�v���O����

%% EEG��ǂݍ���
task=[];
task(:,:)=rawdata(:,:);
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
th_s=-2000;% ������臒l������% �������ق��ɍ��킹��(�ꔭ�ڂ̃g���K�[�����Ɉ��������邾���ł悳����)

%% ���͂���S�Ẵg���K�[���擾
for i=2:length(task)
    % 臒l���v���X�̏ꍇ�́A������2�̕s�������t�ɂȂ�
    if(task(i,EX1_CH_index) < th_s && task(i-1,EX1_CH_index) > th_s)% 臒l���傫�����A�O�̃f�[�^��臒l�����ł���΁A������g���K�[�̊J�n�Ƃ���
        trg_time_t=[trg_time_t i];
    end
end

disp(trg_time_t(1)); % for debug
disp(trg_time_t(end)); %for debug
length(task);

% 500step(=1s)���݂̒l���g���K�[�^�C���Ƃ��Ēǉ�(�N���b�N����1s���ɌJ��Ԃ���邽��)
for i=2:length(task)/500+1
    trg_time_t(i+1)=trg_time_t(i)+500;
end

% Kinect�Ƃ̎��ԓ����ׂ̈ɕs�v�ȃf�[�^����菜�� 
% firstTime = 3207; %% <=�u���ԓ����܂Ƃ�.md�v�Ƀ������Ă��鐔�l������ %%
% diff = firstTime - trg_time_t(1);
% firstIndex = diff / 500 + 1;
% trg_time_t(1:firstIndex-1) = [];% �s�v�ȕ���������
% ����̓Q�[���J�n��Ƀg���K�[���X�^�[�g���Ă���̂ŁA���v���Ǝv��

% 20min(=calc_times)�Ԃ̕��͂�z�肵���R�[�h�Ƃ���B
% ��������ǂ��āAcalc_time�Ԃ̕��͂��ł���悤�ɂ���
calc_time = 200; % 180=3min, 300=5min
trg_time_t(calc_time+1:end)=[];
plot(trg_time_t(2:end)-trg_time_t(1:end-1)); %% trigger�m�F % �g���K�[�Ԃ̃f�[�^�����S��500step(1s)�ɂȂ��Ă��邩�����o�I�Ɋm�F����
xlim([0,calc_time]);% 0~calc_time�܂łőł��؂�(���͂ɂ͂����܂ł����K�v�Ȃ�����)

%% epoch�i1�b��؂�j
div_sec=1;% �ǂ̂��炢�̒����ŋ�؂邩? => �����1s���ɋ�؂�
EEG_task=task(:,EEG_CH_index);% EEG�f�[�^�����������
EEG_task(end+1:605000,EEG_CH_index)=0;%% �v���X10s���Ă���(���炭�v���O�������~�܂�Ȃ��悤�ɂ��邽��)((1200 + 10)s * 500hz)
div_EEG_task=[];% 1s���̔]�g�f�[�^���擾����Ƃ��� % �܂��A3�����ڂ�����60�ł��邪�A�����60s�Ԃ̃f�[�^�������Ă����(PLI�Z�o�ɂ�60s�Ԃ̃f�[�^���K�v)
PLI_t=[];

%% PLI�Z�o 60~�ɂȂ��Ă���̂́APLI��1min�̊Ԃ̔]�g���g���ċ��߂Ă���̂ŁA60s�����Ȃ��ƍŏ���PLI���Z�o�ł��Ȃ�����
for n=60:length(trg_time_t)
%for n=60:1200
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
        PLI_t(:,ch_num,:,n)=squeeze(abs(mean(squeeze(FT(:,ch_num,:))./abs(squeeze(FT(:,ch_num,:))),2)));
    end
end
% PLI_t => ������: Hz, ������: �`�����l��(�d��), ��O����: ?(1�̂�), ��l����: ����(60~1200(s))

%% ���ʃv���b�g
figure(2);
title("PLI�̎��g������");
plot(PLI_t(2:500,4,1,180)); %2-500Hz
% for debug => ��͂�A41��40Hz��\���Ă����B

%% ���ԒP�ʂł�PLI���o��(40Hz�����������o����)
PLI40(1:calc_time, 6) = 0;% for output(40Hz)
for i = 60:calc_time
    PLI40(i, EEG_CH_index) = PLI_t(41, EEG_CH_index, 1, i);% �`���l���C���f�b�N�X�͎��R�ɕύX����OK
end

% output
figure(3);
title("PLI 40Hz�̂�");
plot(PLI40(:,ASSR_CH_index));
disp("mean_CH1(�܂Ԃ�) : " + mean(PLI40(60:calc_time,1)));
disp("mean_FC3 : " + mean(PLI40(60:calc_time,2)));
disp("mean_FC4 : " + mean(PLI40(60:calc_time,3)));
disp("mean_FCz : " + mean(PLI40(60:calc_time,4)));
disp("mean_O1 : " + mean(PLI40(60:calc_time,5)));
disp("mean_O2 : " + mean(PLI40(60:calc_time,6)));
disp("mean_�܂Ԃ� : " + mean(PLI40(60:calc_time,7)));
disp("meanAll : " + mean(mean(PLI40(60:calc_time,:))));
disp("mean FC2,FC3,FCz : " + mean(mean(PLI40(60:calc_time,ASSR_CH_index))));

%% PLI_r�̕��ς����߂�(60s ~ => 60s�ȑO�͑S��0�̂���)
% mean(PLI_r(41,1:5,1,60:300), 4);% ���̈�s�ŋ��߂�ꂽ�̂ŁA���ɒ��ڂԂ�����
%% rest-task�̎��ԕψ�(workload���Z�o����)(PLI_r�K�v)
concentration(1:calc_time)=0;
for i=60:calc_time
    concentration(i,EEG_CH_index)=mean(PLI_r(41,EEG_CH_index,1,60:calc_time), 4) - PLI_t(41,EEG_CH_index,1,i);
end

% C3, Cz, C4�𕽋ς��āAworkload�Ƃ��Ă��ǂ�
% �ȉ��́A�S�Ă̓d�ɂ̃��[�N���[�h���v���b�g����
figure(4);
plot(concentration(:,FC3_index));
title("workload FC3");

figure(5);
plot(concentration(:,FC4_index));
title("workload FC4");

figure(6);
plot(concentration(:,FCz_index));
title("workload FCz");
