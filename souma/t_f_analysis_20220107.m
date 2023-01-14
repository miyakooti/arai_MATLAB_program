T = readmatrix('C:\Users\Kenshin Soma\Documents\MATLAB\data\shibata_jetcoaster2.csv');

T_fftdata = [];
for ch=1:6
    Tc = T(:,1+ch);
    [S,w,t,ps]=spectrogram(Tc,500,[],500,500); 
        %[S,w,t] Sデータ w周波数 tデータ時間
        %s = spectrogram(EEGdata,windowの数,noverlapデータのオーバーラップ,何Hzごとに出すか,サンプリング周波数)
    T_fftdata(ch,:,:)=ps(1:49,:);
end

for ch=1:6
    for n=1:length(t)
        T_delta_data = mean(T_fftdata(ch,1:3,n));
        T_theta_data = mean(T_fftdata(ch,4:7,n));
        T_alpha_data = mean(T_fftdata(ch,8:13,n));
        T_beta_data = mean(T_fftdata(ch,14:30,n));
        T_gamma_data = mean(T_fftdata(ch,31:49,n));

        %各周波数帯の指定時間ごとの平均値を順番にグラフ用配列に格納
        T_delta_graph(ch,n) = T_delta_data;
        T_theta_graph(ch,n) = T_theta_data;
        T_alpha_graph(ch,n) = T_alpha_data;
        T_beta_graph(ch,n) = T_beta_data;
        T_gamma_graph(ch,n) = T_gamma_data;
    end
end

%figure;plot(T_theta_graph(1,:))
%title('ch1')
%figure;plot(T_theta_graph(2,:))
%title('ch2')
%figure;plot(T_theta_graph(3,:))
%title('ch3')
%figure;plot(T_theta_graph(4,:))
%title('ch4')
%figure;plot(T_theta_graph(5,:))
%title('ch5')
%figure;plot(T_theta_graph(6,:))
%title('ch6')

T_theta_mean=mean(T_theta_graph,2)
%T_theta_mean_up=mean(T_theta_graph(:,34:98),2)
T_theta_mean_slide=mean(T_theta_graph(:,98:122),2)
%T_theta_mean_stay=mean(T_theta_graph(:,122:136),2)
T_theta_mean_down=mean(T_theta_graph(:,136:146),2)