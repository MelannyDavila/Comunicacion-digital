%comparacion
clear all
close all
clc
M1=4; %Numero de fases para D-QPSK, QPSK y Pi/4QPSK

Ber=[]; %Creacion de un vector para la probabilidad de bit errado
Ber2=[]; %Creacion de un vector para la probabilidad de bit errado
Ber3=[]; %Creacion de un vector para la probabilidad de bit errado
for Eb=-4:1:50; %lazo for que varia el valor de Eb/No
    Eb1=10^(Eb/10); %Transformacion de dB a veces
    Pe1=(erfc(sin(pi/M1).*sqrt(log2(M1)).*sqrt(Eb1)))*log2(M1);  %Calculo de la prob. de error
    Ber=[Ber Pe1]; %Asignacion de los valores de prob. de error
end

for Eb=-4:1:50; %lazo for que varia el valor de Eb/No
    Eb1=10^(Eb/10); %Transformacion de dB a veces
    Pe11= (2/(log2(M1)))*erfc(sqrt(Eb1/2)*sin(pi/M1));  %Calculo de la prob. de error
    Ber2=[Ber2 Pe11]; %Asignacion de los valores de prob. de error
end

for Eb=-4:1:50; %lazo for que varia el valor de Eb/No
    Eb1=10^(Eb/10); %Transformacion de dB a veces
    Pe111=(erfc(sin(pi/M1).*sqrt(log2(M1)).*sqrt(Eb1)))*log2(M1);  %Calculo de la prob. de error
    Ber3=[Ber3 Pe111]; %Asignacion de los valores de prob. de error
end


Eb=-4:1:50; %Vector de Eb/No
semilogy(Eb,Ber2','g+-');%Grafica semilogaritmica
hold on
semilogy(Eb,Ber','b*')
hold on
semilogy(Eb,Ber3','r')
legend('D-QPSK','QPSK','pi/4 - QPSK') %Nombre de la grafica
title('BER vs. Eb/No') %Titulo
xlabel('Eb/No') %nombre del eje x
ylabel('Probabilidad de bit errado') %nombre del eje y
grid on %Cuadricula