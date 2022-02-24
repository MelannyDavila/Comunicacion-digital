%% FHSS
clc
clear all
close all

N=30; %Numero de datos
datos=randi([0 1],1,N);    %Generacion del vector de datoss
senal=[]; %Vector senal vacio
portadora=[]; %Vector portadora vacio
f=[0:2*pi/119:2*pi];     % Creating 120 samples for one cosine
for k=1:N %lazo for que permite recorrer el vector de datos
    if datos(1,k)==0  %si el bit es 0
        se=-ones(1,120);    %se designan 120 muestras de valor 1 con signo negativo para cada bit
    else %si el bit es 1
        se=ones(1,120);     %se designan 120 muestras para cada bit
    end
    p=cos(f); %se designa la portadora cos(t)
    portadora=[portadora p]; %se registra la portadora de cada bit
    senal=[senal se]; %se registra la senal de datos extendida
end

% Modulacion BPSK de la senal de datos
bpsk=senal.*portadora;   %modulacion BPSK

% Creacion de las 6 frecuencias de portadora
t1=[0:2*pi/9:2*pi]; %vector de tiempo 1
t2=[0:2*pi/19:2*pi]; %vector de tiempo 2
t3=[0:2*pi/29:2*pi]; %vector de tiempo 3
t4=[0:2*pi/39:2*pi]; %vector de tiempo 4
t5=[0:2*pi/59:2*pi]; %vector de tiempo 5
t6=[0:2*pi/119:2*pi]; %vector de tiempo 6
c1=cos(t1); %portadora 1
c1=[c1 c1 c1 c1 c1 c1 c1 c1 c1 c1 c1 c1];
c2=cos(t2); %portadora 2
c2=[c2 c2 c2 c2 c2 c2];
c3=cos(t3); %portadora 3
c3=[c3 c3 c3 c3];
c4=cos(t4); %portadora 4
c4=[c4 c4 c4];
c5=cos(t5); %portadora 5
c5=[c5 c5];
c6=cos(t6); %portadora 6
fh=[ ];
% Frecuencias randomicas para FHSS
ss=[]; %vector de frecuencias vacio
for n=1:N %lazo for que designa las frecuencias potadoras a cada bit de dato
    p=randi([1 6],1,1); %obtencion de la secuencia aleatoria de frecuencias
    switch(p); %bucle switch que permite designar las frecuencias portadoras segun la secuencia aleatoria
        case(1)
            ss=[ss c1];
        case(2)
            ss=[ss c2];
        case(3)
            ss=[ss c3];
        case(4)
            ss=[ss c4];
        case(5)       
            ss=[ss c5];
        case(6)
            ss=[ss c6];
    end
    fh=[fh p];
end
% Senal FHSS
fhss=bpsk.*ss; %producto entre la senal bpsk y la secuencia aleatoria de frecuencias

f=1:1:30; %creacion de un vector de tiempo
%Grafico de los canales de frecuencia utilizados
figure 
plot(f,fh,'s r');
axis([0.5 30.5 0.75 6.25])
title('Canales de frecuencia utilizados en FHSS')
grid on
grid minor
xlabel('Tiempo')
ylabel('Frecuencia')