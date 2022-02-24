%% M-QAM
clear all
close all
clc

M=64; %Numero de fases
K=1000; %Numero simbolos a  modular
SNR=30; %relacion senal a ruido en dB
FCos= comm.RaisedCosineTransmitFilter('RolloffFactor',0.5); %Creacion del objeto 
%que describe el filtro de coseno levantado con un valor especifico de factor
%de Roll off en transmision
FCos1=comm.RaisedCosineReceiveFilter('RolloffFactor',0.5); %Creacion del objeto 
%que describe el filtro de coseno levantado con un valor especifico de factor
%de Roll off en recepcion

datosIn =randi([0 M-1],K,1); %vector aleatorio de K simbolos entre 0 y M-1
SeTx = qammod(datosIn,M); %Simbolos modulados con M-PSK 

SeFil=FCos(SeTx);%Aplicacion del filtro Coseno levantado a la senal tx
SN=awgn(SeFil,SNR); %Paso a traves de un canal AWGN

SeFil1=FCos1(SN);%Aplicacion del filtro a la senal con ruido AWGN
SeRx=qamdemod(SeFil1,M); %demodulacion de la senal recibida filtrada

%Ber canal con filtros

[b, Ber1]=biterr(datosIn,SeRx);

disp(['BER con factor de roll-off 0.5: ',num2str(Ber1)])

%Ber canal sin filtros
SeRx = awgn(SeTx,SNR); %Paso a traves de una canal AWGN

SeDem= qamdemod(SeRx,M); %Señal demodulada  
   
[a,Ber]=biterr(datosIn,SeDem);

disp(['BER sin filtro: ',num2str(Ber)])