clear all
close all 
clc
%datos=[1 0 0 0 1 0 1 1]; %datos a codificar

K=70; %Numero simbolos

xn =randi([0 1],K,1); %vector aleatorio de K simbolos entre 0 y 15

%xn=[1 0 0 0 1 0 1 1]; %Codigo binario de Entrada
subplot(1,1,1);stairs([0:length(xn)-1],xn);axis([0 (length(xn)-1) -0.5 1.5])
title('Codigo Binario Transmitido'); %codigo binario de Entrada
grid on;
%HMod = comm.MSKModulator(xn,length(xn)*10);%crea el objeto que modulara a la señal de entrada
%HDemod =comm.MSKModulator('BitOutput',true);
%plot(HMod)
