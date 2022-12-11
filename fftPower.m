     %フーリエ変換
Y = fft(rawdata);
FT(:,:)=Y;
P(:,:)= sqrt(Y.*conj(Y));

len =length(rawdata);
f = MEL_SAMPLE_FREQ/2*linspace(0,1,len/2+1);

%フーリエ変換結果
figure;
hold on;
subplot(3,1,1);
plot(f,P(1:len/2+1,1:5));
title('Fourier transform');
xlabel('Hz');
ylabel('Power');
legend(CH_NAME([1:5]));
ylim([0 10^5])

subplot(3,1,2);
plot(f,P(1:len/2+1,7:8));
title('Fourier transform');
xlabel('Hz');
ylabel('Power');
legend(CH_NAME([7:8]));

subplot(3,1,3);
plot(f,P(1:len/2+1,9));
title('Fourier transform');
xlabel('Hz');
ylabel('Power');
legend(CH_NAME(9));

raw1 = rawdata(:,1)/1000;
figure;
hold on;
plot(raw1);

EEG = rawdata;
load('filt_data05_200.mat')
EEG = filtfilt(Num,1,EEG);
EEG1 = EEG(:,1)
figure;
hold on;
plot(EEG1);














loop_cnt=loop_cnt+1;

if(loop_cnt > 2)
    
    
    for ch_num=1:size(epoched_data,2)
        ITPC(:,ch_num,:)=squeeze(abs(mean(squeeze(FT(:,ch_num,:))./abs(squeeze(FT(:,ch_num,:))),2)));
    end
    
    
    %                     for i_combi = 1:size(ch_combi,1)
    %                         PLV(:,i_combi) = abs(mean(squeeze(FT_mov(:,ch_combi(i_combi,1),:)) .* conj(squeeze(FT_mov(:,ch_combi(i_combi,2),:)))...
    %                             ./ abs(squeeze(FT_mov(:,ch_combi(i_combi,1),:))) ./ abs(squeeze(FT_mov(:,ch_combi(i_combi,2),:))),2));
    %                     end
    
    %加算平均フーリエ変換結果
    figure(fig1);subplot(3,2,5); plot(f(21:91),ITPC(21:91,:));
    title(['PLI ' num2str(round(toc))]);xlabel('Hz');ylabel('PLI');legend(CH_NAME(EEG_CH));
    
    figure(fig1); subplot(3,2,6); plot(f(21:91),mean(ITPC(21:91,:),2)*5)
    title(['PLI ' num2str(round(toc))]);xlabel('Hz');ylabel('avgPLI');
    
    %                     figure(fig1);subplot(4,2,7); plot(f(21:91),PLV(21:91,:));
    %                     title(['PLV ' num2str(round(toc))]);xlabel('Hz');ylabel('PLV');
    %
    %                     figure(fig1);subplot(4,2,8);plot(f(21:91),mean(PLV(21:91,:),2)*28)
    %                     title(['PLV ' num2str(round(toc))]);xlabel('Hz');ylabel('avgPLV');
end
    
   