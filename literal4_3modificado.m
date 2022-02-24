%% BSPK
clear all
close all
clc
M=2; %Numero de fase de BPSK
SNR=10; %Valor de SNR en dB
K=100; %Numero datos
datos=randi([0 M-1],K,1); %vector aleatorio k datos entre 0 y M-1]
SeTx=pskmod(datos, M); %Senal de datos modulada con M-PSK
FCos= comm.RaisedCosineTransmitFilter('RolloffFactor',0.9); %Creacion del objeto que 
%describe el filtro de coseno levantado con un valor especifico de factor
%de Roll off
SeFil=FCos(SeTx);%Aplicacion del filtro Coseno levantado a la senal tx

SN=awgn(SeFil,SNR); %Paso a traves de un canal AWGN

FCos1=comm.RaisedCosineReceiveFilter('RolloffFactor',0.9);
SeFil1=FCos1(SN); %Aplicacion del filtro a la senal con ruido AWGN

%% Calculo del BER

%Usanso un filtro
filtrada = pskdemod(SeFil1,M);
Ber = (biterr(datos,filtrada))/800;
recibida = pskdemod(SN,M);
 disp(['BER usando un filtro coseno levantado con factor de roll-off 0.1: ',num2str(Ber)])

%sin filtro
SeSF = awgn(SeTx,SNR);
senSf = pskdemod(SeSF,M);
BER = (biterr(datos,senSf))/800;
 disp(['BER sin filtro: ',num2str(BER)])





