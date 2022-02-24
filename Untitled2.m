clc
clear all
close all

t=-4:0.01:120; %creacion de tiempo
P=64; %numero de subportadoras
for i=0:1:P %vector for que permite graficar las N subportadoras
    y=sinc(t-i); %funcion de sampling (subportadora i)
    plot(y) %grafico de cada una de la subportadora i
    axis([-3 7300  -0.25 1.1] ) %limitacion del tamano de los ejes
    hold on %cuadricula
    title('Espectro de las subportadoras de OFDM'); %titulo
    xlabel('Frecuencia [Hz]'); %titulo del eje x
    ylabel('Amplitud [V]') %titulo del eje y
    i=i+1; %incremento de la variable i
end


% Inclusion de prefijo ciclico
CP = 1/16; % Prefijo ciclico
Rb = 8*10^6; % Regimen binario total
M = 32; % numero de fases de la modulacion
fs = 40*10^6; % Frecuencia de muestreo
% Reajustamos algunos datos
if P <= 3*N
    nc = floor(log2(P/3)); % Reajustamos nc para que N > 3*Nc, y Nc sea potencia de 2
    N = 2^(nc); % Reajustamos Nc a partir de nc
    clear nc
end
% Datos de la creacion de OFDM
Lx = 128; % Longitud de la cadena de transmision
N = 64; % Numero de subportadoras por simbolo (primera estimacion)
Nsym = ceil(Lx/N); % Numero de simbolos en la cadena
T = round(fs*N*(log2(M)/Rb)); % Numero de puntos de la IFFT
P = T; % Numero de puntos de la FFT
Tg = floor(T/4); % Longitud del prefijo ciclico
if CP
    Tt = T+Tg; % Longitud total del simbolo cuando hay prefijo ciclico
else
    Tt = T; % Longitud total del simbolo cuando NO hay prefijo ciclico
end

Lx = Nsym*N; % Reajustamos la longitud de la cadena de transmision
X = zeros(1,Lx); % Cadena de simbolos
x = zeros(T,Nsym); % IFFT de cada simbolo agrupadas en columnas
Tx = zeros(1,Nsym*Tt); % Señal transmitida
X = sign(randn(1,Lx)) + 1i*sign(randn(1,Lx)); % Cadena aleatoria de datos M-PSK
% Creacion de la señal OFDM
X = reshape(X,N,Nsym); % Bloque S/P: Separamos la cadena en simbolos OFDM
x = ifft(X,T); % Bloque IFFT: Hacemos la IFFT de cada simbolo
if CP % Bloque PC: Añadimos el prefijo ciclico si procede
    xg(1:Tg,:) = x(T-Tg+1:T,:);
    xg(Tg+1:Tt,:) = x;
    x = xg;
    clear xg;
end
Tx = reshape(x,1,Nsym*Tt); % Bloque P/S: Señal transmitida en cadena
if Nsym > 16 % En caso de que la cadena sea muy larga
    Tx = Tx(1:16*Tt); % Seleccionamos una parte significativa de la cadena
    Nsym = 16;
end
% Grafica en el tiempo
figure(2)
tm = log2(M)*(1/Rb); % Tiempo de simbolo PSK
tmax = Nsym*N*tm; % Intervalo de tiempo representado
t = tmax/length(Tx) : tmax/length(Tx) : tmax;
plot(t,abs(Tx))
axis([0 tmax min(abs(Tx)) max(abs(Tx))]);
%axis([0 10e-5 -1e-3 1.1*max(abs(Tx))])
title('Señal OFDM')
xlabel('Tiempo [s]')
ylabel('Amplitud [V]')
grid minor
% Grafica en la frecuencia
figure(3)
TX = fft(Tx,(P/N)*length(Tx)); % Hallamos el espectro
TX = fftshift(TX); % Colocamos la componente 0 en el centro del espectro
x1 = floor((1/2-3*N/(2*P))*length(TX));
x2 = floor((1/2+(5*N)/(2*P))*length(TX));
TX = TX(x1:x2); % Seleccionamos la parte que queremos representar
i = find(abs(TX)<0.01);
TX(i) = 0.01; % Limitamos el minimo para pasar a dB
TX = 10*log10(abs(TX)); % Pasamos el espectro a dB

ABsub = (2/log2(M))*Rb/N; % Ancho de banda de cada subportadora
ABmax = (1+N)*ABsub/2; % Ancho de banda total de OFDM
f = -2*ABmax : 4*ABmax/(length(TX)-1) : 2*ABmax;
plot(f,TX)
axis([-2*ABmax 2*ABmax -20 20])
title('Espectro OFDM')
xlabel('Frecuencia  (Hz)')
ylabel('Amplitud [V]')
grid minor
