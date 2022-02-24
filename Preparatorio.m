%% clear all
close all
clc
constDiagram= comm.ConstellationDiagram;
constDiagram1= comm.ConstellationDiagram;
M=16; 
K=700; %Numero simbolos a  modular
b= log2(M); %numero de bits para cada simbolo
datosIn =randi([0 M-1],K,1); %vector aleatorio de K simbolos entre 0 y 15
be=0; %numero de bit erraros inicialmente es cero
  
SeIn=de2bi(datosIn,b); %transformacion datos transmitidos a binario

SeTx = pskmod(datosIn,M,pi/M); %Simbolos modulados con 16psk 

constDiagram(SeTx); %Diagrama de constelacion ideal

SeRx = awgn(SeTx,4); %Paso a traves de una canal AWGN

constDiagram1(SeRx); %Diagrama de constelacion señal en canal con ruido

SeDem= pskdemod(SeRx,M); %Señal demodulada  
   
SeOut= de2bi(SeDem,b);  %Señal de salida, transformacion de la señal demodulada en binario
   
be=biterr(SeIn,SeOut); %Numero de bit errados
nb=K*b; %numero total de bits transmitidos
ber=be/nb %BER