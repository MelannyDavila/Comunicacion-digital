%% 16-QAM
close all
clc
M=16; %numero de fases
Pe=[]; %Creacion de un vector para la probabilidad de error

for Eb=0:1:30; %lazo for que varia el valor de Eb/No
    Eb1=10^(Eb/10);%Transformacion de dB a veces
    a=3*log2(M); %Parte a del factor
    b=2*(M-1);%Parte b del factor
    c=a/b;%Factor total que multiplica a Eb/No
    x=sqrt(c*Eb1);%Raiz del valor a calcular con la funcion erfc
    Pe1=2*((sqrt(M)-1)/sqrt(M))*erfc(x); %Calculo de la prob. de error
    Pe=[Pe Pe1]; %Asignacion de los valores de prob. de error
end

Eb=0:1:30;%Vector de Eb/No
semilogy(Eb,Pe','g+-') %Grafica semilogaritmica
legend('16-QAM') %Nombre de la grafica
title('Probabilidad de error vs. Eb/No') %Titulo
xlabel('Eb/No') %nombre del eje x
ylabel('Probabilidad de error') %nombre del eje y
grid on %cuadricula