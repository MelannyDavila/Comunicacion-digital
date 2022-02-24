%% 16PSK probabilidad de error
clear all
close all
clc
M=16; %numero de fases 
b=log2(16);
pe=[]; %creacion de un vector para la 
%probabilidad de error
for Eb=0:1:30 %lazo for para variar el valor de Eb/No
    x=10^(Eb/10); %cambio de dB a veces el valor de EB/No
    a=sin(pi/M)*sqrt(b)*sqrt(x);
    pe1=erfc(a); %Calculo de la prob. de error
    pe=[pe pe1]; %asignacion de los valores obtenidos al vector pe
end

Eb=0:1:30; %vector de Eb/No
semilogy(Eb,pe','*-'); %grafica de Eb/No vs. Prob. error
grid on %cuadricula
title('16PSK-Probabilidad de error vs Eb/No') %titulo
xlabel('Eb/No') %nombre del eje x
ylabel('Probabilidad de error') %nombre del eje y