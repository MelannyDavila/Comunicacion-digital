%% GMSK
clc
clear all
close all
datos=randi([0 1], 1000,1);
%vector aleatorio de 1000 datos, entre 1 y 0
gmsk=comm.GMSKModulator('BitInput',true);
%creacion del objeto GMSKModulator
SGMSK=gmsk(datos);
%Modulacion de los datos
SAWGN=awgn(SGMSK,40);
%Paso de los datos modulados a traves de un 
%canal AWGN, con SNR=15dB
eyediagram(SGMSK,100);
%Diagrama de ojo de los datos modulados con GMSK
eyediagram(SAWGN,100);
%Diagrama de ojo de los datos a traves de un canal
%AWGN