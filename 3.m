clc;
clear all;
close all;

%Número de ususarios:
users=2;          
%Generació de los códigos Walsh-Hadamard:
n =8;                               % Matriz de orden 8                        
walsh=hadamard(n);                  % Matriz Hadamard
code1=walsh(2,:);                   % Selección de la 2da y 6ta fila
code2=walsh(6,:);                   
%Generación de los datos para USER 1:
N=10^2;                             % Numero de datos para User 1
data_user1= rand(1,N)>0.5;          % Generación de datos
data_user1bpsk = 2*data_user1-1;    % Modulación BPSK  
%Generación de los datos para USER 2:
M=10^2;                             % Numero de datos para User 2
data_user2= rand(1,M)>0.5;          % Generación de datos
data_user2bpsk = 2*data_user2-1;    % Modulación BPSK 
%Ensanchamiento y aplicación de la IFFT en USER 1: 
data_user1_1=data_user1bpsk';
spdata1_user1=data_user1_1*code1;   % Ensanchamiento con Hadamard para USER 1
spdata12=(spdata1_user1)';
ifftdata_user1=ifft(spdata12);      % Aplicación de la IFFT
ifftdata12=ifftdata_user1';
%Ensanchamiento y aplicación de la IFFT en USER 2: 
data_user2_1=data_user2bpsk';
spdata2_user2=data_user2_1*code2;    % Ensanchamiento con Hadamard para USER 1
spdata22=(spdata2_user2)';
ifftdata_user2=ifft(spdata22);      % Aplicación de la IFFT
ifftdata22=ifftdata_user2';

%Señal MC-CDMA:
x=ifftdata12+ifftdata22;
x=x';
figure,
subplot(3,2,1)
stairs(data_user1)
title('Datos User 1')
subplot(3,2,2)
stairs(code1)
title('Walsh Fila 2')
subplot(3,2,3)
stairs(data_user2)
title('Datos User 2')
subplot(3,2,4)
stairs(code2)
title('Walsh Fila 6')

%Canal AWGN:
SNR=3;                             % Relación señal a ruido
y=awgn(x,SNR);

%Espectros
subplot(3,1,3)
espT=fft(x);
espT=fftshift(espT);
Fmd=linspace(0,1000,length(espT));
plot(Fmd,abs(espT),'b')

espT1=fft(x(:,1:50));
espT1=fftshift(espT1);
Fmd1=linspace(0,500,length(espT1));
hold on
plot(Fmd1,abs(espT1),'r');

espT2=fft(x(:,51:100));
espT2=fftshift(espT2);
Fmd2=linspace(500,1000,length(espT2));
hold on
plot(Fmd2,abs(espT2),'g');

title('Espectro de las Señales')
xlabel('Frecuencia [MHz]')
ylabel('Amplitud')
axis([0 1000 -0.5 2.5])


% Recepción: 
figure,
fft_y_1=fft(y);
fft_y_1=fft_y_1';
data_received_1=fft_y_1*code1';       % Señal recibida con ruido
data_received_11=real(data_received_1)>0; 
data_received_12=data_received_11';

data_received_2=fft_y_1*code2';       % Señal recibida con ruido
data_received_21=real(data_received_2)>0; 
data_received_22=data_received_21';

subplot(2,2,1)
stairs(data_user1)
title('Datos User 1 originales')
axis([0 100 -1 2]);

subplot(2,2,2)
stairs(data_received_12)
title('Datos User 1 recibidos')
axis([0 100 -1 2]);

subplot(2,2,3)
stairs(data_user2)
title('Datos User 2 originales')
axis([0 100 -1 2]);
subplot(2,2,4)
stairs(data_received_22)
title('Datos User 2 recibidos')
axis([0 100 -1 2]);

[h1 BER1]=biterr([data_user1 data_user2],[data_received_12 data_received_22]);
disp('El BER calculado es:')
BER1