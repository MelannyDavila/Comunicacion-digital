%%  D-QPSK
clear all
close all
clc
M=4; %Numero de fases (4PSK)
SNR=10;
datos=randi([0 M-1],1000,1); %Creacion del vector de datos aleatorio
desfase=0; %desfase entre constelaciones
SeMod=dpskmod(datos,M,desfase); %Modulacion de los datos
SeTx=awgn(SeMod, SNR);
cd = comm.ConstellationDiagram('ShowTrajectory',true,'ShowReferenceConstellation',false);
%Creacion del objeto de diagrama de constelacion
cd(SeTx) %Diagrama de constelacion de D-QPSK
