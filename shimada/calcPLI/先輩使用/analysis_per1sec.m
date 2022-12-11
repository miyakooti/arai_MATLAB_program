%% task analysis per 1 second
%% How to Import

% ���l�s��CC5(��6):K(end)�@�ȉ�����
    % �]�g�f�[�^8ch C5(��6):J(end)�@
    % �g���K�f�[�^ K5(��6):K(end)
    
% �ȉ���task�I������1�I��Ŏ��s��Cfind triger task�ȉ������s���Csave�ŊY���f�[�^��ۑ�

%% task�I��
%% test1
            %task=[];
            %task(:,:)=test1(:,:);
            task = rawdata;
            disp('TASK test1');
%% test2
            %task=[];
            %task(:,:)=test2(:,:);
            %disp('TASK test2');

%% read
           %task=[];
           %task(:,:)=read(:,:);
           %disp('TASK read');
           
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% find trigger task

plot(task(:,9));
%% �ڂŌ���臒l��ݒ�
trg_time_t=[];
th_s=-1940;%% ���ꂪ臒l

%%
%for i=2:length(task)
%    if(task(i,9) > th_s && task(i-1,9) < th_s)
%        trg_time_t=[trg_time_t i];
%        disp("trg : " + trg_time_t);
%    end
%end

% coded by shimada % ����臒l�ɍ��킹��
for i=2:length(task)
    if(task(i,9) < th_s && task(i-1,9) > th_s)
        trg_time_t=[trg_time_t i];
        %disp("trg : " + trg_time_t);
    end
end

disp(trg_time_t(1));
disp(trg_time_t(end));
length(task);
for i=2:length(task)/500+1
    trg_time_t(i+1)=trg_time_t(i)+500;
end

%trg_time_t(920:930)=[]; %% �悭�Ȃ� �{���̓f�[�^���݂ă^�C�~���O������Ă���g���K�͍폜
trg_time_t(901:end)=[];
plot(trg_time_t(2:end)-trg_time_t(1:end-1)); %% trigger�m�F %% �S�Ă̊Ԃ������Ă���(�܂�S��1s�ԂɂȂ��Ă��邩���m�F�ł���)
xlim([0,900]);% �����ŁA���͔͈͂��w�肵�Ă���(���̐l��15���������̂ŁA900/60 = 15�ƂȂ�)
% ��L���R : �g���K�[���m�̊Ԃ�1�b����̂ŁA���ꂪ900�X�e�b�v��900�b�Ƃ�������
 %% �Ō�̃g���K�����̃f�[�^���Ȃ��̂ōŌ�̃g���K�͎g��Ȃ�


%% epoch�i1�b��؂�j
freq=500;
div_sec=1;
% task(end,:)=[]; %�ŏI�s��NaN���܂܂��ꍇ�Ɏg�p

EEG_task=task(:,1:8);% �������́u1:8�v��rawdata�̗���w��(�]�g�f�[�^��������)
EEG_task(end+1:455000,1:8)=0;% �悭������񂪁A0�����ɂ������Ă���
div_EEG_task=[];
PLI_t=[];

% ���炭�����́A60 ~ 900�܂ł𕪐͂Ɏg�����Ƃ��Ă���?
%for n=1:length(trg_time_t)
for n=60:length(trg_time_t)
%for n=60:900
    for i=1:60
        time=i+n-60;
        div_EEG_task(:,:,i)=EEG_task(trg_time_t(time):trg_time_t(time)+freq*div_sec-1,:);
    end
    %for i=1:60
    %    div_EEG_task(:,:,i)=EEG_task(trg_time_t(n):trg_time_t(n)+freq*div_sec-1,:);
    %end
    
    %% �t�[���G�ϊ����Ď��g�������擾
    FT = fft(div_EEG_task);
    POWER=abs(FT).^2;
    len =length(FT);
    f=freq/2*linspace(0,1,len/2+1);
    
    %% PLI���v�Z (n(��4����)�����Ԏ�, ���炭��������Hz��\���Ă��āA41 => 40Hz��\���Ă���Ǝv����)
    for ch_num=1:size(FT,2)
        PLI_t(:,ch_num,:,n)=squeeze(abs(mean(squeeze(FT(:,ch_num,:))./abs(squeeze(FT(:,ch_num,:))),2)));
    end
end

%% ���ʃv���b�g
figure(2);
%plot(PLI_t(2:51,4,1,180)); %60s����Ō�܂őI�����ĕ\��
plot(PLI_t(2:500,4,1,64)); %60s����Ō�܂őI�����ĕ\��

%% task����40hz�т̎��ԕω�
% 40hz=[];
% for i=60:length(trg_time_t)
%     40hz(i,1:8)=-PLI_t(41,1:8,1,i);
% end
% 40hz(conc(60:end,5))

%% rest-task�̎��ԕψ�
concentration(1:900)=0;
%for i=60:900
for i=60:64
    %concentration(i,1:8)=PLI_r(41,1:8)-PLI_t(41,1:8,1,i);
    concentration(i,1:8)=PLI_t(41,1:8)-PLI_t(41,1:8,1,i);
end

% ��������rest-task�̕���
workload_per_s=[];
workload_per_s(:,:)=(concentration(:,3)+concentration(:,4)+concentration(:,5))*(1/3);

%workload_per_s(:,:)=concentration(:,3);%09�͂R�̂�
figure(3);
plot(workload_per_s(:,:));

% NaN����!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

min_isnan_wps=900;
for i=900:-1:60
    if isnan(workload_per_s(i))
        min_isnan_wps=i;
    else
        break
    end
end

for i=min_isnan_wps:900
    workload_per_s(i)=workload_per_s(i-1);
end

workload_per_s = fillmissing(workload_per_s,'linear');

% 1�������Z����

workload_per_m=[];
for i=1:15
    workload_per_m(i)=mean(workload_per_s((i-1)*60+1:i*60));
end

workload_per_10s=[];
for i=1:90
    workload_per_10s(i)=mean(workload_per_s((i-1)*10+1:i*10));
end
    
%% �m�F
subplot(3,1,1);
plot(workload_per_s);
subplot(3,1,2);
plot(workload_per_m);
subplot(3,1,3);
plot(workload_per_10s);
%% SAVE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%% test1
            wps_test1=[];
            wps_test1=workload_per_s(1:900);
            wpm_test1=workload_per_m(1:15);
            wp10s_test1 = workload_per_10s(1:90);
            disp('SAVE test1');
%% test2
            wps_test2=[];
            wps_test2=workload_per_s(1:900);
            wpm_test2=workload_per_m(1:15);
            wp10s_test2 = workload_per_10s(1:90);
            disp('SAVE test2');
%% read
            wps_read=[];
            wps_read=workload_per_s(1:900);
            wpm_read=workload_per_m(1:15);
            wp10s_read = workload_per_10s(1:90);
            disp('SAVE read');
%% All �m�F
            Zwps_test1(1:60)=0;
            Zwps_test1(61:900)=zscore(wps_test1(61:900));
            Zwps_test2(1:60)=0;
            Zwps_test2(61:900)=zscore(wps_test2(61:900));
            Zwps_read(1:60)=0;
            Zwps_read(61:900)=zscore(wps_read(61:900));
            
            th=1.8; %% 臒l�ݒ�I�I�I�I�I�I�I�I�I�I�I�I�I�I�I�I�I�I�I�I�I�I�I
            
            figure();
            subplot(2,1,1);
            plot(Zwps_test1);
            hold on
            plot(Zwps_test2);
            plot(Zwps_read);
            hline = refline([0 th]);
            hline.Color='r';
            hline = refline([0 -th]);
            hline.Color='r';
            hold off
            legend('test1','test2','read');

            subplot(2,1,2);
            Zwpm_test1=zscore(wpm_test1);
            Zwpm_test2=zscore(wpm_test2);
            Zwpm_read=zscore(wpm_read);
            plot(Zwpm_test1);
            hold on;
            plot(Zwpm_test2);
            plot(Zwpm_read);
            hold off;
            legend('test1','test2','read');
            