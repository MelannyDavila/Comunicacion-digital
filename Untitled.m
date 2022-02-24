clc
clear all
close all
n = 128;%Numbero de bits por canal
M = 4; %Numero de niveles para la modulacion
n=128;%Numero total de bits a ser transmitidos
tamano = n/2; %tamanio de cada bloque OFDM
cp_len = floor(0.2 * tamano); %Longitud del prefijo ciclico
%Modulacion
% Generacion de informacion aleatoria y posterior modulacion con QPSK
data = randsrc(1, n, 0:M-1);
senial_modulada_QPSK = pskmod(data, M);
% Conversion serie paralelo de la informacion en N subportadoras
N = 64;
%Declaro matriz para organizar la informacion y luego separarla
serialAparalelo = reshape(senial_modulada_QPSK, n/N,N);
subportadora = zeros(n/N);%Declaro matriz  para almacenar las subportadoras
for i=1:N
    subportadora(:,i) = serialAparalelo(:,i);
end
%Aplicacion de la transformada inversa de fourier
prefijoinicio=tamano-cp_len; %Calculo el tamanio del bloque de
%informacion
numFFT = 500;
ifft_suportadora = ifft(subportadora,numFFT); %hago la operacion ifft sobre las
%Adicion del prefijo ciclico
for i=1:N
    suportadora_ifft(:,i) = ifft((serialAparalelo(:,i)),numFFT);% Transformacion la ifft
    for j=1:cp_len
        cyclic_prefix(j,i) = suportadora_ifft(j+prefijoinicio,i);
    end
    anexoDePrefijo(:,i) = vertcat( cyclic_prefix(:,i), suportadora_ifft(:,i));
    %Anexo los prefijos a las subportadoras
end
A = zeros(numFFT+cp_len);%Creo vector n/N +1, en cada una de sus columnas guarda 
%las subportadoras
for i=1:16
   A(:,i) = anexoDePrefijo(:,i); %Realizo la asignacion
end
%Conversion paralelo serie
[rows_Append_prefix, cols_Append_prefix]=size(anexoDePrefijo);
tamanioDatosOFDM = rows_Append_prefix*cols_Append_prefix;
% Creacion de la senial OFDM
senialOFDM = reshape(anexoDePrefijo, 1, tamanioDatosOFDM);
% Inclusion de prefijo ciclico
CP = 1/16; % Prefijo ciclico
Rb = 8*10^6; % Regimen binario total
M = 4; % numero de fases de la modulacion
fs = 40*10^6; % Frecuencia de muestreo
Lx = n; % Longitud de la cadena de transmision
Sub = N; % Numero de subportadoras por simbolo (primera estimacion)
Nsym = ceil(Lx/Sub); % Numero de simbolos en la cadena
T = round(fs*Sub*(log2(M)/Rb));
N = T; % Numero de puntos de las transformadas rapidas
Tg = floor(T/4); % Longitud del prefijo ciclico
if CP
    Tt = T+Tg; % Longitud total del simbolo cuando hay prefijo ciclico
else
    Tt = T; % Longitud total del simbolo cuando NO hay prefijo ciclico
end
% Reajustamos algunos datos
if N <= 3*Sub
    nc = floor(log2(N/3)); % Reajustamos nc para que N > 3*Nc, y Nc sea potencia de 2
    Sub = 2^(nc); % Reajustamos Nc a partir de nc
end
Lx = Nsym*Sub; % Reajustamos la longitud de la cadena de transmision
X = zeros(1,Lx); % Cadena de simbolos
x = zeros(T,Nsym); % IFFT de cada simbolo agrupadas en columnas
Tx = zeros(1,Nsym*Tt); % Señal transmitida
X = sign(randn(1,Lx)) + 1i*sign(randn(1,Lx)); % Cadena aleatoria de datos M-PSK
% Creacion de la señal OFDM
X = reshape(X,Sub,Nsym); % Bloque S/P: Separamos la cadena en simbolos OFDM
x = ifft(X,T); % se realiza la transformada inversa de fourier
if CP % se coloca el prefijo ciclico
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
figure(1)
tm = log2(M)*(1/Rb); % Tiempo de simbolo PSK
tmax = Nsym*Sub*tm; % Intervalo de tiempo representado
t = tmax/length(Tx) : tmax/length(Tx) : tmax;
plot(t,abs(Tx))
title('Señal OFDM')
xlabel('Tiempo [s]')
ylabel('Amplitud [V]')
grid minor
figure(2)
TX = fft(Tx,(N/Sub)*length(Tx)); % Calculo el espectro por 
%medio del uso de la fft
TX = fftshift(TX); % Se coloca la componente nula en el centro
x1 = floor((1/2-3*Sub/(2*N))*length(TX));
x2 = floor((1/2+(5*Sub)/(2*N))*length(TX));
TX = TX(x1:x2); % Se selecciona la parte que se quiere observar
i = find(abs(TX)<0.01);
TX(i) = 0.01; % Se limita el ultimo decibelio
TX = 10*log10(abs(TX)); % Transformacion a dB

ABsub = (2/log2(M))*Rb/Sub; % Ancho de banda de cada subportadora
ABmax = (1+Sub)*ABsub/2; % Ancho de banda total de OFDM
f = -2*ABmax : 4*ABmax/(length(TX)-1) : 2*ABmax;
plot(f,TX)
axis([-2*ABmax 2*ABmax -20 20])
title('Espectro OFDM')
xlabel('Frecuencia (Hz)')
ylabel('Potencia [dB/Hz]')
grid minor