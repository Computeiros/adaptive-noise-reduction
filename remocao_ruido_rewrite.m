%% Leitura do aúdio base e plot

% Limpa dados de execução
clear
close all
clc

% Recebe informações do audio selecionado
[audio_data]=audioread('audio.wav');
frequencia=10000;

% Realiza plot do sinal do audio no domínio do tempo
figure(1)
res_audio_freq=(0:length(audio_data)-1)/frequencia;
subplot(2,1,1);
plot(res_audio_freq,audio_data, 'r');
xlabel('Sinal no domínio do tempo (t)');
ylabel('Amplitude');
hc=2+frequencia/1000;
coeficientes_preditor_linear=lpc(audio_data,hc);
coeficientes_preditor_linear=coeficientes_preditor_linear(1,:);
[freq_resposta,freq_fisica]=freqz(1,coeficientes_preditor_linear,512,frequencia);

% Realiza plot do sinal do audio no domínio da frequência
subplot(2,1,2);
plot(freq_fisica,20*log10(abs(freq_resposta)+eps));
xlabel('Sinal no domínio da frequência(Hz)');
ylabel('Ganho (dB)');


%% Manipulação do filtro

% Criação do filtro passa-baixa e plot do mesmo
figure(2);
periodo=512;
filtro_pb_freq=zeros(periodo,1);
filtro_pb_freq(1:60)=1;
plot(filtro_pb_freq);
xlabel('Sinal no domínio da frequência(Hz)');
ylabel('Ganho (dB)');

% Criação de um filtro rejeita-faixa através do filtro passa-baixa e plot
figure(3);
subplot(2,1,1);
filtro_rf_freq = filtro_pb_freq;
filtro_rf_freq(periodo-58:periodo)=1;
plot(filtro_rf_freq);
xlabel('Sinal no domínio da frequência(Hz)');
ylabel('Ganho (dB)');
subplot(2,1,2);
filtro_rf_temp=real(ifft(filtro_rf_freq));
plot(filtro_rf_temp);
xlabel('Sinal no domínio da frequência(Hz)');
ylabel('Ganho (dB)');

% Inversão do filtro rejeita-faixa e plot
figure(4);
filtro_pf_temp(1:periodo/2-1,1)= filtro_rf_temp(periodo/2+2:periodo);
filtro_pf_temp(periodo/2:periodo,1)=filtro_rf_temp(1:periodo/2+1);
plot(filtro_pf_temp)

% Aplicação da Transformada rápida de Fourier no filtro manipulado
% anteriormente e plot
figure(5);
filtro_pf_freq=fft(filtro_pf_temp);
plot(abs(filtro_pf_freq));
xlabel('Sinal no domínio da frequência(Hz)');
ylabel('Ganho (dB)');

% Criação do filtro passa-alta
figure(6);
filtro_pa_freq=ones(periodo,1);
filtro_pa_freq(1:69)=0;

% Plot do filtro passa-alta
subplot(2,1,1);
plot(filtro_pa_freq)
xlabel('Sinal no domínio da frequência(Hz)');
ylabel('Ganho (dB)');

% Aplicação da transformada inversa de Fourier no filtro passa-alta e plot
filtro_pa_freq(periodo-67:periodo)=0;
filtro_pa_temp=real(ifft(filtro_pa_freq));
subplot(2,1,2);
plot(filtro_pa_temp);

% Inversão dos audio_datas da metade do filtro passa-alta com a outra metade e
% plot no domínio do TEMPO
var_temp(1:periodo/2-1,1)=filtro_pa_temp(periodo/2+2:periodo);
var_temp(periodo/2:periodo,1)=filtro_pa_temp(1:periodo/2+1);
filtro_pa_temp=var_temp;
figure(7);
subplot(2,1,1);
plot(filtro_pa_temp)

% Plot no domínio da FREQUÊNCIA
subplot(2,1,2);
filtro_pa_freq=fft(filtro_pa_temp);
plot(abs(filtro_pa_freq))

% Criação do áudio base para aplicação do ruído
[audio_data,fs]=audioread('audio.wav');
audio_data=audio_data(:,1);

audio_pf=conv(audio_data,filtro_pf_temp);


%% Construção e aplicação do ruído

% Construção do ruído branco
ruido_branco=2*randn(size(audio_data,1),1);

% Aplicação do ruído no sínal
ruido_aplicado=conv(ruido_branco,filtro_pa_temp);
sinal_ruido=audio_pf + ruido_aplicado;

% Recuperação do sinal
sinal_filtrado=conv(sinal_ruido,filtro_pf_temp);
% soundsc(sinal_ruido,fs)

%% Recuperação do sinal é plot de comparação final

% Plot do sinal com ruído no domínio do tempo
figure(8);
frequencia=10000;
res_audio_freq=(0:length(sinal_ruido)-1)/frequencia;
hold on;
plot(res_audio_freq,sinal_ruido, 'g');
xlabel('Sinal no domínio do tempo (t)','FontSize',24);
ylabel('Amplitude','FontSize',24);

% Recuperação do sinal e plot do audio recuperado no domínio do tempo
hold on;

res_audio_freq=(0:length(sinal_filtrado)-1)/frequencia;
plot(res_audio_freq,sinal_filtrado, 'r');
xlabel('Sinal no domínio do tempo (t)','FontSize',24);
ylabel('Amplitude','FontSize',24);
soundsc(sinal_filtrado,fs)


% Plot do audio original no domínio do tempo
hold on
res_audio_freq=(0:length(audio_data)-1)/frequencia;
plot(res_audio_freq,audio_data, 'b');
xlabel('Sinal no domínio do tempo (t)','FontSize',24);
ylabel('Amplitude','FontSize',24);

legend('Sinal ruído','Sinal filtrado','Sinal original')