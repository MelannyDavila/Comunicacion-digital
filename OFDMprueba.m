clear all
clc
close  

M = 32;                          %   SEÑAL PSK 
no_of_data_points = 320;        %   PUNTOS DE LA CONSTELACION
block_size = 32;                 %   PREFIJO CICLICO
cp_len = block_size/4;  %   LONGITUD DE PREFIJO CICLICO
no_of_ifft_points = block_size;           %   3NUMERO DE SUBPORTADORAS
no_of_fft_points = block_size;
%   ---------------------------------------------
%   B:  %   +++++   TRANSMITTER    +++++
%   ---------------------------------------------
%   1.  Generate 1 x 3200 vector of data points phase representations
data_source = randsrc(1, no_of_data_points, 0:1);
data_ingreso=de2bi(data_source,6);
figure(1)
stem(data_source); grid on; xlabel('Puntos'); ylabel('Representacion')
title('Datos Transmitidos')
%   2.  MODULACION QPSK
qam_modulated_data = qammod(data_source, M);
%   3.  hACER LA MULTIPLEXACION CON IFFT
num_cols=length(qam_modulated_data)/block_size;
data_matrix = reshape(qam_modulated_data, block_size, num_cols);
%  CREACION DE UNA  MTRIZ PARA LA ifft
cp_start = block_size-cp_len;
cp_end = block_size;
%   
for i=1:num_cols,
    ifft_data_matrix(:,i) = ifft((data_matrix(:,i)),no_of_ifft_points);
    %   rEALIZACION DEL PREFIJO
    for j=1:cp_len,
       actual_cp(j,i) = ifft_data_matrix(j+cp_start,i);
    end
   
    ifft_data(:,i) = vertcat(actual_cp(:,i),ifft_data_matrix(:,i));
end
%   4.  cONVERTIR SERIE PARALELO
[rows_ifft_data cols_ifft_data]=size(ifft_data);
len_ofdm_data = rows_ifft_data*cols_ifft_data;
%   Actual OFDM signal to be transmitted
ofdm_signal = reshape(ifft_data, 1, len_ofdm_data);
figure(3)
plot(real(ofdm_signal)); xlabel('Tiempo'); ylabel('Amplitud');
axis([1 64 -2.5 2.5]);
title('Señal OFDM');grid on;
figure(4)
tfsm=fft(real(ofdm_signal),1600/32 *length(real(ofdm_signal)));
tfsm = fftshift(tfsm); 
x1 = floor((1/2-(3*32/(2*1600)))*length(tfsm));
x2 = floor((1/2+(5*32/(2*1600)))*length(tfsm));
tfsm = tfsm(x1:x2); % Seleccionamos la parte que queremos representar
tfsm = 10*log10(abs(tfsm)); 
Fmd=linspace(-1000,1000,length(tfsm));
plot(Fmd,tfsm,'r');
%axis([-300 300 -10 15]);
title('Espectro Señal Frecuencia');
xlabel('Frecuencia (Hz)');
ylabel('Amplitud');

%canal con ruido
ofdm_signal1=awgn(ofdm_signal,25); 

%     +++++   RECEPCION    +++++
recvd_signal = ofdm_signal1;
%   4.  CONVIERTE "PARALELO SERIE
recvd_signal_matrix = reshape(recvd_signal,rows_ifft_data, cols_ifft_data);
%   5.  rEMUECO EL PREFIJO CICLICO
recvd_signal_matrix(1:cp_len,:)=[];
%   6.  UTILIZAR fft
for i=1:cols_ifft_data,
    %   FFT
    fft_data_matrix(:,i) = fft(recvd_signal_matrix(:,i),no_of_fft_points);
end
%   7.  CONVERTIR SERIE IMPLEMENTADO CON PULSOS
recvd_serial_data = reshape(fft_data_matrix, 1,(block_size*num_cols));
%   8.  SE DEMODULA
qam_demodulated_data = qamdemod(recvd_serial_data,M);
figure(6)
stem(qam_demodulated_data);title('Datos Recibidos');
data_salida=de2bi(qam_demodulated_data,6);
[x,BER]=biterr(data_ingreso,data_salida);
BER