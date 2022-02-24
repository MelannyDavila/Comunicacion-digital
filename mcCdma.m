clear all; close all; clc;

%----------Ingreso de datos----------
cantidadDatos = input('Ingrese la cantidad de datos para el usuario 1 y usuario 2 (preferencia > 50): '); %ingreso del total de datos para el usuario 1,2
SNR = input('Ingrese un valor de SNR: '); %ingreso de la relacion SNR
M = 2;
%------------------------------------
%------------Transmisión-------------
%------------------------------------

%----------Calculo de datos----------
datosUsuario1 = randi([0,1],1,cantidadDatos); %genera bits [0,1] para el usuario 1 de forma aleatoria
datosUsuario2 = randi([0,1],1,cantidadDatos); %genera bits [0,1] para el usuario 2 de forma aleatoria

%----------Modulación BPSK----------
signalBPSK1 = []; %vector vacio para guardar la portadora segun el numero de 1's y 0' en datos
signalBPSK2 = []; %vector vacio para guardar la portadora segun el numero de 1's y 0' en datos

t = 0:2*pi/99:2*pi; %vector tiempo que permite generar 120 muestras

%Modulación BPSK para el usuario 1
for (i=1:1:length(datosUsuario1))%lazo for que almacena la modulación dependiendo del bit de entrada
    if (datosUsuario1(i)==1)
        c1 = cos(t+pi); %creación de una portadora simple cos w
    else
        c1 = cos(t); %creación de una portadora simple cos w
    end
     signalBPSK1 = [signalBPSK1 c1]; %almacena la modulacion
end

modulacionUsuario1 = pskmod(datosUsuario1,M,pi/M); %modulacion bpsk usando la funcion pskmod para usuario 1

%Modulación BPSK para el usuario 2
for (i=1:1:length(datosUsuario2))%lazo for que almacena la modulación dependiendo del bit de entrada
    if (datosUsuario2(i)== 1)
        c2 = cos(t+pi); %creación de una portadora simple cos w
    else
        c2 = cos(t); %creación de una portadora simple cos w
    end
     signalBPSK2 = [signalBPSK2 c2]; %almacena la modulacion
end

modulacionUsuario2 = pskmod(datosUsuario2,M,pi/M); %modulacion bpsk usando la funcion pskmod para usuario 2

%----------Código Hadamard-Walsh----------
n = 8; %número de subportadoras
codigoHW = hadamard(n); %Matriz 8x8 que contiene los códigos de Hadamard-Walsh
cHWusuario1 = codigoHW(2,:); %Matriz 1x8 que contiene el código HW de la fila dos para el usuario 1
cHWusuario2 = codigoHW(6,:); %Matriz 1x8 que contiene el código HW de la fila dos para el usuario 1

%----------Ensanchamiento (Spreading)----------
%Spreading para el usuario 1
sPusuario1 = modulacionUsuario1'; %conversión de los datos serie/paralelo del usuario 1
SpreadingTx1 = sPusuario1*cHWusuario1; %ensanchamiento de la señal mediante la multiplicacion con el código HW

%Spreading para el usuario 2
sPusuario2 = modulacionUsuario2'; %conversión de los datos serie/paralelo del usuario 2
SpreadingTx2 = sPusuario2*cHWusuario2; %ensanchamiento de la señal mediante la multiplicacion con el código HW

%----------IFFT----------
%IFFT para el usuario 1
trasSTX1 = SpreadingTx1'; %reordenamiento de los datos para posteriormente aplicar la IFFT
ifftUsuario1 = ifft(trasSTX1); %aplicación de la IFFT a la señal ensanchada del usuario 1

%IFFT para el usuario 2
trasSTX2 = SpreadingTx2'; %reordenamientode los datos para posteriormente aplicar la IFFT
ifftUsuario2 = ifft(trasSTX2); %aplicación de la IFFT a la señal ensanchada del usuario 2

%----------Agregación del prefijo cíclico----------
%Prefijo cíclico para el usuario 1
ifftTransU1 = ifftUsuario1'; %se realiza la transpuesta (p/s) de los datos para posteriormente aplicar el prefijo cícliclo
prefCicUsuario1 = [ifftTransU1(:,[(n-2):n]) ifftTransU1]; %agregación del prefijo cíclico, añadiendo al principio tres columnas mas para tener valores de guarda
datosTXusuario1 = prefCicUsuario1'; %conversión de paralelo a serie para transmitir los datos del usuario 1

%Prefijo cíclico para el usuario 2
ifftTransU2 = ifftUsuario2'; %se realiza la transpuesta (p/s) de los datos para posteriormente aplicar el prefijo cícliclo
prefCicUsuario2 = [ifftTransU2(:,[(n-2):n]) ifftTransU2]; %agregación del prefijo cíclico, añadiendo al principio tres columnas mas para tener valores de guarda
datosTXusuario2 = prefCicUsuario2'; %conversión de paralelo a serie para transmitir los datos del usuario 2

signalMccdmaTx = ifftUsuario1 + ifftUsuario2; %suma de las señales a transmitir para general la señal MC-CDMA

%------------------------------------
%---------------CANAL----------------
%------------------------------------

signalMccdmaAWGN = awgn(signalMccdmaTx,SNR); %se añade ruido blanco a la señal transmitida por el canal

%------------------------------------
%---------------RECEPCIÓN------------
%------------------------------------

%----------Remover el prefijo cíclico----------
aux = signalMccdmaAWGN'; %conversión s/p
sinPrefCicUsuarios = aux; %aux(:,[(4:(n+3))]);  %remover el prefijo cíclico, quitando al principio los valores de guarda

%----------FFT----------
fftRX = fft(sinPrefCicUsuarios);

%----------Recuperación de los datos de cada usuario a través de HW---------
%Usuario 1
rec1 = fftRX*cHWusuario1';
recPS1 = rec1'; %conversion P/s
datosRXusuario1 = recPS1/max(recPS1); %obtención de los datos del usuario 1

%Usuario 2
rec2 = fftRX*cHWusuario2';
recPS2 = rec2'; %conversion P/s
datosRXusuario2 = recPS2/max(recPS2); %obtención de los datos del usuario 1

%----------Demodulación BPSK----------
%Demodulación Usuario 1
mDemod1 = pskdemod(datosRXusuario1,M); %vector vacio que almacena la demodulacion
% m1Demod = [];
% bp=.0001; 
% for f=length(t):length(t):length(datosRXusuario1)%lazo for que demodula la señal enviada por TX
%   portadorarx1 = cos(t + pi); %portadora para demodularsignalBPSK1((f-(length(t)-1)):f)
%   RepDemod1 = portadorarx1.*datosRXusuario1((f-(length(t)-1)):f); %multiplicacion de la señal modulada con ruido y la protadora con ruid
%   z=trapz(t,RepDemod1); %integracion
%   zz=round((2*z/bp)); %redonde los valores generados en la intregacion para luego comparar y recuperar los bits                                     
%   if(zz>0) %nivel logico que comparar los resultados para generar los bits
%     a=1;
%   else
%     a=0;
%   end
%   m1Demod=[m1Demod a]; %vector que almacena los bits recuperados de la demodulacion
% end

%Demodulación Usuario 2
mDemod2 = pskdemod(datosRXusuario1,M); %vector vacio que almacena la demodulacion
% m2Demod = [];
% bp = .000001; 
% for ff=length(t):length(t):length(datosRXusuario2)%lazo for que demodula la señal enviada por TX
%   portadorarx2 = cos(t + pi); %portadora para demodularsignalBPSK1((f-(length(t)-1)):f)
%   RepDemod2 = datosRXusuario2((ff-(length(t)-1)):ff).*datosRXusuario2((ff-(length(t)-1)):ff); %multiplicacion de la señal modulada con ruido y la protadora con ruid
%   z2=trapz(t,RepDemod2); %integracion
%   zz2=round((2*z/bp)); %redonde los valores generados en la intregacion para luego comparar y recuperar los bits                                     
%   if(zz2>0) %nivel logico que comparar los resultados para generar los bits
%     a2 = 1;
%   else
%     a2 = 0;
%   end
%   m2Demod=[m2Demod a2]; %vector que almacena los bits recuperados de la demodulacion
% end

%----------DEmodulación BPSK----------
signalBPSK11 = []; %vector vacio para guardar la portadora segun el numero de 1's y 0' en datos
signalBPSK22 = []; %vector vacio para guardar la portadora segun el numero de 1's y 0' en datos

t = 0:2*pi/99:2*pi; %vector tiempo que permite generar 120 muestras

%Deodulación BPSK para el usuario 1
for (i=1:1:length(mDemod1))%lazo for que almacena la modulación dependiendo del bit de entrada
    if (mDemod1(i)==1)
        c1 = cos(t+pi); %creación de una portadora simple cos w
    else
        c1 = cos(t); %creación de una portadora simple cos w
    end
     signalBPSK11 = [signalBPSK11 c1]; %almacena la modulacion
end

%Demodulación BPSK para el usuario 2
for (i=1:1:length(mDemod2))%lazo for que almacena la modulación dependiendo del bit de entrada
    if (mDemod2(i)== 1)
        c2 = cos(t+pi); %creación de una portadora simple cos w
    else
        c2 = cos(t); %creación de una portadora simple cos w
    end
     signalBPSK22 = [signalBPSK22 c2]; %almacena la modulacion
end

%------------Cálculo del BER----------
%Usuario 1
[ner1 ber1] = biterr(datosUsuario1,mDemod1);%Funcion para ver el ner y ber
BBer1 = ber1;
fprintf('El BER para el usuario 1 tiene un valor de = %2f \n',BBer1);

%Usuario 2
[ner2 ber2] = biterr(datosUsuario2,mDemod2);%Funcion para ver el ner y ber
BBer2 =ber2;
fprintf('El BER para el usuario 2 tiene un valor de = %2f \n',BBer2);

%------------------------------------
%------------Gráficos en TX----------
%------------------------------------
%Gráfico de los datos del usuario 1
subplot(5,2,1); %grafica en la fila 1 columna 1 los datos del usuario 1
GRAFICAR(datosUsuario1); %Uso de la función graficar para visualizar los bits del usuario 1
title('Datos de entrada del usuario 1 (TX)')
xlabel('Tiempo [s]')
ylabel('Amplitud')

%Gráfico de los datos del usuario 2
subplot(5,2,2); %grafica en la fila 1 columna 2 los datos del usuario 2
GRAFICAR(datosUsuario2); %Uso de la función graficar para visualizar los bits del usuario 2
title('Datos de entrada del usuario 2 (TX)')
xlabel('Tiempo [s]')
ylabel('Amplitud')

%Gráfico de la modulación BPSK del usuario 1
lonBPSKsig1 = length(signalBPSK1); %almacena la longitud de la matriz signalBPSK para graficar y dimensionar los ejes
subplot(5,2,3); %grafica en la fila 2 columna 1 los datos de la modulación BPSK del usuario 1
plot(signalBPSK1,'r','linewidth',0.01); %gráfica de la modulación BPSK en el tiempo
axis([0 lonBPSKsig1 -1.5 1.5]);  %dimension de los ejes
title('Modulación BPSK para el usuario 1');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico de la modulación BPSK del usuario 2
lonBPSKsig2 = length(signalBPSK2); %almacena la longitud de la matriz signalBPSK para graficar y dimensionar los ejes
subplot(5,2,4); %grafica en la fila 2 columna 2 los datos de la modulación BPSK del usuario 2
plot(signalBPSK2,'b','linewidth',0.01); %gráfica de la modulación BPSK en el tiempo
axis([0 lonBPSKsig2 -1.5 1.5]);  %dimension de los ejes
title('Modulación BPSK para el usuario 2');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico del código HW del usuario 1
subplot(5,2,5); %grafica en la fila 3 columna 1 el código HW del usuario 1
GRAFICAR(cHWusuario1); %Uso de la función graficar para visualizar el código HW del usuario 1
title('Código Hadamard-Walsh del usuario 1 (TX)')
xlabel('Tiempo [s]')
ylabel('Amplitud')

%Gráfico del código HW del usuario 2
subplot(5,2,6); %grafica en la fila 3 columna 2 el código HW del usuario 2
GRAFICAR(cHWusuario2); %Uso de la función graficar para visualizar el código HW del usuario 2
title('Código Hadamard-Walsh del usuario 2 (TX)')
xlabel('Tiempo [s]')
ylabel('Amplitud')

%Gráfico de la señal ensanchada del usuario 1
grafResEnsanchada1 = reshape(SpreadingTx1,1,[]); %reordenamiento de datos
lonEnsanchada1 = length(grafResEnsanchada1); %almacena la longitud de la matriz para graficar y dimensionar los ejes
subplot(5,2,7); %grafica en la fila 4 columna 1 de la señal ensanchada del usuario 1
plot(abs(grafResEnsanchada1),'k','linewidth',0.01); %gráfica de la mseñal ensanchada en el tiempo
axis([0 lonEnsanchada1 -1.5 1.5]);  %dimension de los ejes
title('Señal ensanchada del usuario 1 (Spreading TX)');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico de la señal ensanchada del usuario 2
grafResEnsanchada2 = reshape(SpreadingTx2,1,[]); %reordenamiento de datos
lonEnsanchada2 = length(grafResEnsanchada2); %almacena la longitud de la matriz para graficar y dimensionar los ejes
subplot(5,2,8); %grafica en la fila 4 columna 2 los datos de la señal ensanchada del usuario 2
plot(abs(grafResEnsanchada2),'linewidth',0.01); %gráfica de la señal ensanchada en el tiempo
axis([0 lonEnsanchada2 -1.5 1.5]);  %dimension de los ejes
title('Señal ensanchada del usuario 2 (Spreading TX)');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico de la IFFT del usuario 1
grafIFFT1 = reshape(ifftTransU1,1,[]);
lonIFFT1 = length(grafIFFT1); %almacena la longitud de la matriz para graficar y dimensionar los ejes
subplot(5,2,9); %grafica en la fila 5 columna 1 los datos de la IFFT del usuario 1
plot(abs(grafIFFT1),'c','linewidth',0.01); %gráfica de la IFFT en el tiempo
axis([0 lonIFFT1 min(abs(grafIFFT1)) max(abs(grafIFFT1))]);  %dimension de los ejes
title('IFFT del usuario 1 en TX');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico de la IFFT del usuario 2
grafIFFT2 = reshape(ifftTransU2,1,[]);
lonIFFT2 = length(grafIFFT2); %almacena la longitud de la matriz para graficar y dimensionar los ejes
subplot(5,2,10); %grafica en la fila 5 columna 2 los datos de la IFFT del usuario 2
plot(abs(grafIFFT2),'m','linewidth',0.01); %gráfica de la IFFT en el tiempo
axis([0 lonIFFT2 min(abs(grafIFFT2)) max(abs(grafIFFT2))]);  %dimension de los ejes
title('IFFT del usuario 2 en TX');
xlabel('Tiempo [s]');
ylabel('Amplitud');
%%
%------------------------------------
%------------Gráficos en RX----------
%------------------------------------
figure

%Gráfico de la FFT
grafFFT1 = reshape(fftRX,1,[]);
lonIFFT1 = length(grafFFT1); %almacena la longitud de la matriz para graficar y dimensionar los ejes
subplot(5,1,1); %grafica en la fila 5 columna 1 los datos de la FFT del usuario 1
plot(abs(grafFFT1),'c','linewidth',0.01); %gráfica de la FFT en el tiempo
axis([0 lonIFFT1 min(abs(grafFFT1)) max(abs(grafFFT1))]);  %dimension de los ejes
title('FFT en RX');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico de la señal desensanchada del usuario 1
grafResEnsanchada11 = reshape(datosRXusuario1,1,[]); %reordenamiento de datos
lonEnsanchada1 = length(grafResEnsanchada11); %almacena la longitud de la matriz para graficar y dimensionar los ejes
subplot(5,2,3); %grafica en la fila 4 columna 1 de la señal ensanchada del usuario 1
plot(abs(grafResEnsanchada11),'k','linewidth',0.01); %gráfica de la mseñal ensanchada en el tiempo
axis([0 lonEnsanchada1 -1.5 1.5]);  %dimension de los ejes
title('Señal Desenchada usuario 1 (Spreading RX)');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico de la señal desensanchada del usuario 2
grafResEnsanchada22 = reshape(datosRXusuario2,1,[]); %reordenamiento de datos
lonEnsanchada1 = length(grafResEnsanchada22); %almacena la longitud de la matriz para graficar y dimensionar los ejes
subplot(5,2,4); %grafica en la fila 4 columna 1 de la señal ensanchada del usuario 2
plot(abs(grafResEnsanchada22),'k','linewidth',0.01); %gráfica de la mseñal ensanchada en el tiempo
axis([0 lonEnsanchada1 -1.5 1.5]);  %dimension de los ejes
title('Señal Desenchada usuario 2 (Spreading RX)');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico de la demodulación BPSK del usuario 1
lonBPSKsig11 = length(signalBPSK11); %almacena la longitud de la matriz signalBPSK para graficar y dimensionar los ejes
subplot(5,2,5); %grafica en la fila 2 columna 1 los datos de la modulación BPSK del usuario 1
plot(signalBPSK11,'r','linewidth',0.01); %gráfica de la demodulación BPSK en el tiempo
axis([0 lonBPSKsig11 -1.5 1.5]);  %dimension de los ejes
title('Demodulación BPSK para el usuario 1');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico de la demodulación BPSK del usuario 2
lonBPSKsig22 = length(signalBPSK22); %almacena la longitud de la matriz signalBPSK para graficar y dimensionar los ejes
subplot(5,2,6); %grafica en la fila 2 columna 1 los datos de la demodulación BPSK del usuario 1
plot(signalBPSK22,'r','linewidth',0.01); %gráfica de la demodulación BPSK en el tiempo
axis([0 lonBPSKsig22 -1.5 1.5]);  %dimension de los ejes
title('Demodulación BPSK para el usuario 2');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico del código HW del usuario 1
subplot(5,2,7); %grafica en la fila 3 columna 1 el código HW del usuario 1
GRAFICAR(cHWusuario1); %Uso de la función graficar para visualizar el código HW del usuario 1
title('Código Hadamard-Walsh del usuario 1 (RX)')
xlabel('Tiempo [s]')
ylabel('Amplitud')

%Gráfico del código HW del usuario 2
subplot(5,2,8); %grafica en la fila 3 columna 2 el código HW del usuario 2
GRAFICAR(cHWusuario2); %Uso de la función graficar para visualizar el código HW del usuario 2
title('Código Hadamard-Walsh del usuario 2 (RX)')
xlabel('Tiempo [s]')
ylabel('Amplitud')

%Gráfico de los datos del usuario 1
subplot(5,2,9); %grafica en la fila 1 columna 1 los datos del usuario 1
GRAFICAR(mDemod1); %Uso de la función graficar para visualizar los bits del usuario 1
title('Datos recibidos del usuario 1 (RX)')
xlabel('Tiempo [s]')
ylabel('Amplitud')

%Gráfico de los datos del usuario 2
subplot(5,2,10); %grafica en la fila 1 columna 2 los datos del usuario 2
GRAFICAR(mDemod1); %Uso de la función graficar para visualizar los bits del usuario 2
title('Datos recibidos del usuario 2 (RX)')
xlabel('Tiempo [s]')
ylabel('Amplitud')




%------------------------------------------------------------------------
%------------Gráfico del Espectro de diferentes señales------------------
%------------------------------------------------------------------------
figure
%Gráfico del espectro la señal MC-CDMA
grafSigTX = reshape(signalMccdmaTx,1,[]);
subplot(3,2,1); %grafica en la fila 1 columna 1 del espectro de la señal MC-CDMA TX 
plot(abs(fft(grafSigTX)),'b','linewidth',0.01); %gráfica del espectro de la señal MC-CDMA TX en el tiempo
axis ([0 length(abs(fft(grafSigTX))) min(abs(fft(grafSigTX))) max(abs(fft(grafSigTX)))]);  %dimension de los ejes
title('Espectro de la señal MC-CDMA TX');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico del espectro la señal MC-CDMA RECIBIDO
grafSigTXAWGN = reshape(signalMccdmaAWGN,1,[]);
subplot(3,2,2); %grafica en la fila 1 columna 2 del espectro de la señal MC-CDMA TX 
plot(abs(fft(grafSigTXAWGN)),'b','linewidth',0.01); %gráfica del espectro de la señal MC-CDMA TX en el tiempo
axis ([0 length(abs(fft(grafSigTXAWGN))) min(abs(fft(grafSigTXAWGN))) max(abs(fft(grafSigTXAWGN)))]);  %dimension de los ejes
title('Espectro de la señal MC-CDMA RX (AWGN)');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico del espectro la señal MODULADA usuario 1
grafMB1 = reshape(signalBPSK1,1,[]);
subplot(3,2,3); %grafica en la fila 2 columna 1 del espectro de la señal MODULACION
plot(abs(fft(grafMB1)),'b','linewidth',0.01); %gráfica del espectro de la señal MODULADA
axis ([0 length(abs(fft(grafMB1))) min(abs(fft(grafMB1))) max(abs(fft(grafMB1)))]);  %dimension de los ejes
title('Espectro Modulación BPSK usuario 1');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico del espectro la señal MODULADA usuario 2
grafMB2 = reshape(signalBPSK2,1,[]);
subplot(3,2,4); %grafica en la fila 2 columna 1 del espectro de la señal MODULACION
plot(abs(fft(grafMB2)),'b','linewidth',0.01); %gráfica del espectro de la señal MODULADA
axis ([0 length(abs(fft(grafMB2))) min(abs(fft(grafMB2))) max(abs(fft(grafMB2)))]);  %dimension de los ejes
title('Espectro Modulación BPSK usuario 2');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico del espectro la señal DEMODULADA usuario 1
grafMBD1 = reshape(signalBPSK11,1,[]);
subplot(3,2,5); %grafica en la fila 2 columna 1 del espectro de la señal DEMODULACION
plot(abs(fft(grafMBD1)),'b','linewidth',0.01); %gráfica del espectro de la señal DEMODULADA
axis ([0 length(abs(fft(grafMBD1))) min(abs(fft(grafMBD1))) max(abs(fft(grafMBD1)))]);  %dimension de los ejes
title('Espectro Demodulación BPSK usuario 1');
xlabel('Tiempo [s]');
ylabel('Amplitud');

%Gráfico del espectro la señal DEMODULADA usuario 2
grafMBD2 = reshape(signalBPSK22,1,[]);
subplot(3,2,6); %grafica en la fila 2 columna 1 del espectro de la señal DEMODULACION
plot(abs(fft(grafMBD2)),'b','linewidth',0.01); %gráfica del espectro de la señal DEMODULADA
axis ([0 length(abs(fft(grafMBD2))) min(abs(fft(grafMBD2))) max(abs(fft(grafMBD2)))]);  %dimension de los ejes
title('Espectro Demodulación BPSK usuario 2');
xlabel('Tiempo [s]');
ylabel('Amplitud');