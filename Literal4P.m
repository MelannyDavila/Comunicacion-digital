%% 64QAM
clear all
close all
clc
M=64; %Numero de fase de QAM
SNR=30; %Valor de SNR en dB
K=100; %Numero datos
datos=randi([0 M-1],K,1); %vector aleatorio k datos entre 0 y M-1]
SeTx=qammod(datos,M); %Senal de datos modulada con M-PSK
FCos= comm.RaisedCosineTransmitFilter('RolloffFactor',0.1); %Creacion del objeto que 
%describe el filtro de coseno levantado con un valor especifico de factor
%de Roll off
SeFil=FCos(SeTx);%Aplicacion del filtro Coseno levantado a la senal tx
SN=awgn(SeFil,SNR); %Paso a traves de un canal AWGN
FCos1=comm.RaisedCosineReceiveFilter('RolloffFactor',0.1);
SeFil1=FCos1(SN);%Aplicacion del filtro a la senal con ruido AWGN
SeRx=qamdemod(SeFil1,M); %demodulacion de la senal recibida filtrada
%% Calculo del BER
%Usando filtro Coseno Levantado 
Ber = (biterr(datos, SeRx))/length(SeFil);
 disp(['BER usando un filtro coseno levantado con factor de roll-off 0.5: ',num2str(Ber)])

%Sin filtro
SeSF = awgn(SeTx,SNR); %paso de la senal de datos modulada por un canal AWGN
senSf = qamdemod(SeSF,M); %demodulacion de la senal no filtrada
Ber1 =biterr(datos,senSf)/length(SeSF);
disp(['BER sin usar el filtro coseno levantado: ',num2str(Ber1)])
