clc
clear all
close all

t=-4:0.01:20; %creacion de tiempo
N=16; %numero de subportadoras
for i=0:1:N %vector for que permite graficar las N subportadoras
    y=sinc(t-i); %funcion de sampling (subportadora i)
    plot(y) %grafico de cada una de la subportadora i
    axis([0 length(y) -0.25 1.1] ) %limitacion del tamano de los ejes
    hold on %cuadricula
    title('Espectro de las subportadoras de OFDM'); %titulo
    xlabel('Frecuencia'); %titulo del eje x
    ylabel('Amplitud') %titulo del eje y
    i=i+1; %incremento de la variable i
end