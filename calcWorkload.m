%% ���[�N���[�h���Z�o����v���O����(���펞PLI - �^�X�N��PLI)
% ���炩���߁APLI_r(���펞PLI)��ʓr�o���K�v������(calcPLI_rest.m)�ŎZ�o�\
% �܂Ԃ��p�d�ɂ����ꂽ8ch�ł̕��͗p�v���O����
%% EEG��ǂݍ���

task=[];
task(:,:)=rawdata(:,:);% �����œǂݍ���
%EEG_data(:,1:6) = rawdata(:,1:6);
% �n�C�p�X�t�B���^��������(�܂��AEEG�����̂ݎ��o��)
%for i=1:6
%    task(:,i) = highpass(rawdata(:,i),1.0,500,'ImpulseResponse','fir');% �����������g��(1.0Hz)�A��O�������T���v�����O���g��
    %EEG_data(:,i) = highpass(rawdata(:,i),1,500);
%end
% �n�C�p�X�t�B���^�I��
%% infomax�̎�
% task(:,1:6) = independence(:,:);

%% ���ԓ����p�ɍŏ��̕�����؂�(�f�[�^���Ȃ���)
% Kinect�Ƃ̎��ԓ�����ɐ��l��ς���(���ԓ����܂Ƃ�.md�̐��l���Q�l�ɕύX����)
%task(1:7634,:)=[];% ���̏ꍇ�A1~7634�܂ł̃f�[�^���Ȃ���

disp('load rawdata');

%% �g���K�[���o�͂��āA���o�I��臒l(�ǂ̒l�ȏオ�N���b�N���̎n�܂肩?)��������
figure(1);
subplot(2,1,1);
plot(task(:,7)); % EX1 40Hz�N���b�N��
subplot(2,1,2);
plot(task(:,8)); % EX2 �t�H�g�f�B�e�N�^

%% 臒l��ݒ�
trg_time_t=[];% �g���K�[�̎n�܂�̍s�����擾����
th_s=-1238;% ������臒l������% �������ق��ɍ��킹��(�ꔭ�ڂ̃g���K�[�����Ɉ��������邾���ł悳����)

%% ���͂���S�Ẵg���K�[���擾
for i=2:length(task)
    % 臒l���v���X�̏ꍇ�́A������2�̕s�������t�ɂȂ�
    if(task(i,7) < th_s && task(i-1,7) > th_s)% 臒l���傫�����A�O�̃f�[�^��臒l�����ł���΁A������g���K�[�̊J�n�Ƃ���
        trg_time_t=[trg_time_t i];
    end
end

disp(trg_time_t(1));% for debug
disp(trg_time_t(end));%for debug
length(task);

% 500step(=1s)���݂̒l���g���K�[�^�C���Ƃ��Ēǉ�(�N���b�N����1s���ɌJ��Ԃ���邽��)
for i=2:length(task)/500+1
    trg_time_t(i+1)=trg_time_t(i)+500;
end

% Kinect�Ƃ̎��ԓ����ׂ̈ɕs�v�ȃf�[�^����菜�� 
firstTime = 3207; %% <=�u���ԓ����܂Ƃ�.md�v�Ƀ������Ă��鐔�l������ %%
diff = firstTime - trg_time_t(1);
firstIndex = diff / 500 + 1;
trg_time_t(1:firstIndex-1) = [];% �s�v�ȕ���������

% 20min(=1200s)�Ԃ̕��͂�z�肵���R�[�h�Ƃ���B
%trg_time_t(920:930)=[]; %% �悭�Ȃ� �{���̓f�[�^���݂ă^�C�~���O������Ă���g���K�͍폜
trg_time_t(1201:end)=[];
plot(trg_time_t(2:end)-trg_time_t(1:end-1)); %% trigger�m�F % �g���K�[�Ԃ̃f�[�^�����S��500step(1s)�ɂȂ��Ă��邩�����o�I�Ɋm�F����
xlim([0,1200]);% 0~1200(12min)�܂łőł��؂�(���͂ɂ͂����܂ł����K�v�Ȃ�����)
% ���X�g�̃g���K�[�͎����g�p���Ȃ�(�������̃f�[�^���������߁APLI�����߂��Ȃ�����)
%% epoch�i1�b��؂�j
freq=500;%% �T���v�����O���g��(EEG��)
div_sec=1;%% �ǂ̂��炢�̒����ŋ�؂邩? => �����1s���ɋ�؂�
% task(end,:)=[]; %�ŏI�s��NaN���܂܂��ꍇ�Ɏg�p

EEG_task=task(:,1:6);% EEG�f�[�^�����������
EEG_task(end+1:605000,1:6)=0;%% �v���X10s���Ă���(���炭�v���O�������~�܂�Ȃ��悤�ɂ��邽��)((1200 + 10)s * 500hz)
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
plot(PLI_t(2:500,4,1,180));
% for debug => ��͂�A41��40Hz��\���Ă����B
%disp("40 : " + PLI_t(40,4,1,180));
%disp("41 : " + PLI_t(41,4,1,180));

%% ���ԒP�ʂł�PLI���o��(40Hz�����������o����)
PLI40(1:1200, 6) = 0;% for output(40Hz)
for i = 60:1200
    PLI40(i, 1:6) = PLI_t(41, 1:6, 1, i);% �u1:5�v�̏����u2�v�Ƃ��ɂ���΁A1�̓d�ɂ����̃f�[�^���o��
end
% output
figure(3);
title("PLI 40Hz�̂�");
plot(PLI40(:,4));
disp("mean1(�܂Ԃ�) : " + mean(PLI40(60:1200,1)));
disp("mean2 : " + mean(PLI40(60:1200,2)));
disp("mean3 : " + mean(PLI40(60:1200,3)));
disp("mean4 : " + mean(PLI40(60:1200,4)));
disp("mean5 : " + mean(PLI40(60:1200,5)));
disp("mean6 : " + mean(PLI40(60:1200,6)));
disp("meanAll : " + mean(mean(PLI40(60:1200,:))));

%% PLI_r�̕��ς����߂�(60s ~ => 60s�ȑO�͑S��0�̂���)
% mean(PLI_r(41,1:5,1,60:300), 4);% ���̈�s�ŋ��߂�ꂽ�̂ŁA���ɒ��ڂԂ�����
%% rest-task�̎��ԕψ�(workload���Z�o����)(PLI_r�K�v)
concentration(1:1200)=0;
for i=60:1200
    concentration(i,1:6)=mean(PLI_r(41,1:6,1,60:300), 4) - PLI_t(41,1:6,1,i);
end

% C3, Cz, C4�𕽋ς��āAworkload�Ƃ��Ă��ǂ�
% �ȉ��́A�S�Ă̓d�ɂ̃��[�N���[�h���v���b�g����
figure(4);
title("workload �d��2");
plot(concentration(:,2));
figure(5);
title("workload �d��3");
plot(concentration(:,3));
figure(6);
title("workload �d��4");
plot(concentration(:,4));