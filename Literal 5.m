%% Pi/4 QPSK
clear all
close all
clc
M=4; %Numero de fases
datos=randi([0 M-1],1000,1); %Creacion del vector de datos aleatorio
SeMod=dpskmod(datos,M,pi/4); %Modulacion de los datos
cd = comm.ConstellationDiagram('ShowTrajectory',true,'ShowReferenceConstellation',false);
%Creacion del objeto de diagrama de constelacion
cd(SeMod) %Diagrama de constelacion de pi/4-QPSK