%% BSPK
clear all
close all
clc
M=64; %Numero de fase de BPSK
SNR=30; %Valor de SNR en dB
K=1000; %Numero datos

datos=randi([0 M-1],K,1); %vector aleatorio k datos entre 0 y M-1]
t=1:1:8*K; %Vector de tiempo para graficar la senal Tx y y senal Rx
SeTx=qammod(datos, M); %Senal de datos modulada con M-PSK

FCos= comm.RaisedCosineTransmitFilter('RolloffFactor',0.5); %Creacion del objeto que 
%describe el filtro de coseno levantado con un valor especifico de factor
%de Roll off
SeFil=FCos(SeTx);%Aplicacion del filtro Coseno levantado a la senal tx
%Grafico senal tx en el tiempo
subplot(3,1,1)
plot(t,real(SeFil))
title('Senal transmitida en tiempo');
xlabel('Tiempo[s]');
ylabel('Amplitud [V]');
grid on;

SN=awgn(SeFil,SNR); %Paso a traves de un canal AWGN

%Grafico senal recibida a traves de un canal AWGN
subplot(3,1,2)
plot(t,real(SN))
title('Senal recibida a traves de un canal AWGN');
xlabel('Tiempo[s]');
ylabel('Amplitud [V]');
grid on;
FCos1=comm.RaisedCosineReceiveFilter('RolloffFactor',0.5);
SeFil1=FCos1(SN); %Aplicacion del filtro a la senal con ruido AWGN
t2=1:1:K; %Vector de tiempo para graficar la senal recuperada
%Grafico senal recuperada en tiempo
subplot(3,1,3)
plot(t2,real(SeFil1))
title('Senal recuperada en tiempo'); %codigo binario de Entrada
xlabel('Tiempo[s]');
ylabel('Amplitud [V]');
grid on;

SeDemod=qamdemod(SeFil1,M); %Senal demodulada 


%% Diagramas de ojo

eyediagram(SN,2*M); %Diagrama del ojo de la senal recibida
eyediagram(SeFil1,2*M); %Diagrama del ojo de la senal recibida filtrada

%% Diagramas de constelacion

constDiagram = comm.ConstellationDiagram('ShowReferenceConstellation',false,'XLimits',[-10 10],'YLimits',[-10 10]);
constDiagram(SeTx); %diagrama de constelacion de los datos

constDiagram1 = comm.ConstellationDiagram('ShowReferenceConstellation',false,'XLimits',[-10 10],'YLimits',[-10 10]);
constDiagram1(SN); %diagrama de constelacion filtrada en recepcion

constDiagram2 = comm.ConstellationDiagram('ShowReferenceConstellation',false,'XLimits',[-10 10],'YLimits',[-10 10]);
constDiagram2(SeFil1); %diagrama de constelacion en el receptor