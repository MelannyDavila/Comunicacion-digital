%% PDS
clear all
close all
clc
datos=randi([0 1],1000,1);
%creacion de un vector de 1000 componentes
%cuyos valores son 1 o 0
SNR=50;
msk=comm.MSKModulator('BitInput',true);
%creacion del objeto MSKModulator
SMSK=msk(datos);
%Modulacion de los datos con MSK
SAWGN=awgn(SMSK,SNR);
%Paso de los datos modulados a traves de un 
%canal AWGN, con SNR=15dB
[x,y]=periodogram(SAWGN,'centered');
plot(y,pow2db(x),'g')
hold on
grid on
gmsk=comm.GMSKModulator('BitInput',true);
%creacion del objeto GMSKModulator
SGMSK=gmsk(datos);
%Modulacion de los datos
SAWGN1=awgn(SGMSK,SNR);
%Paso de los datos modulados a traves de un 
%canal AWGN, con SNR=15dB
[x,y]=periodogram(SAWGN1,'centered');
plot(y,pow2db(x),'b')
legend('MSK','GMSK')
hold off