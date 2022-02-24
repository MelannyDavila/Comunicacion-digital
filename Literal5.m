%% FHSS
clc
clear all
close all

%%Transmisor
N=30; %Numero de datos
datos=randi([0 1],1,N);    %Generacion del vector de datoss
senal=[]; %Vector senal vacio
SNR=25; %valor de la relacion senal a ruido
portadora=[]; %Vector portadora vacio
t=[0:2*pi/119:2*pi];     % Creating 120 samples for one cosine
for k=1:N %lazo for que permite recorrer el vector de datos
    if datos(1,k)==0  %si el bit es 0
        se=-ones(1,120);    %se designan 120 muestras de valor 1 con signo negativo para cada bit
    else %si el bit es 1
        se=ones(1,120);     %se designan 120 muestras para cada bit
    end
    p=cos(t); %se designa la portadora cos(t)
    portadora=[portadora p]; %se registra la portadora de cada bit
    senal=[senal se]; %se registra la senal de datos extendida
end

%Grafico de la senal de datos
subplot(4,1,1);
plot(senal);
axis([0 length(senal) -1.5 1.5]);
title('Secuencia original de bit');

% Modulacion BPSK de la senal de datos
bpsk=senal.*portadora;   %modulacion BPSK
%Grafico de la senal modulada 
subplot(4,1,2);
plot(bpsk)
axis([0 length(bpsk) -1.5 1.5])
title('Secuencia modulada  con BPSK');
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

% Frecuencias randomicas para FHSS
ss=[]; %vector de frecuencias vacio
for n=1:N %lazo for que designa las frecuencias potadoras a cada bit de dato
    p=randi([1 6],1,1); %obtencion de la secuencia aleatoria de frecuencias
    switch(p) %bucle switch que permite designar las frecuencias portadoras segun la secuencia aleatoria
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
end

%Grafico de la senal aleatoria de frecuencias de salto
subplot(4,1,3)
plot([1:length(ss)],ss);
axis([0 length(ss) -1.5 1.5]);
title('Secuencia pseudo-aleatoria de 6 frecuencias');

% Senal FHSS
fhss=bpsk.*ss; %producto entre la senal bpsk y la secuencia aleatoria de frecuencias

%Grafico de la senal FHSS
subplot(4,1,4)
plot([1:length(fhss)],fhss);
axis([0 length(fhss) -1.5 1.5]);
title('Senal Frequency Hopping Spread Spectrum');

SeTx=awgn(fhss,SNR); %paso a traves de un canal awgn

%%Receptor

defhss1=SeTx./ss; %obtencion de la senal bpsk
demodSe=defhss1./portadora; %demodulacion de la senal bpsk obtenida
v=[]; %vector vacio que permite guardar el valor de x
for i=1:119:length(demodSe)-119 %lazo for que recorre la senal demodulada
   x=mean(demodSe(i:i+119)); %se obtiene el valor medio de los primeros 120 valores
   v=[v x]; %registro del valor de x en el vector v
end

for i=1:length(v) %lazo for que recorre el vector v
    if v(i)<=0 %si la media obtenida es menor que 0, se designa el valor de 0
       v(i)=0;
    else
       v(i)=1; %caso contrario se designa el valor de 1
    end
end

mat_f=ones(1,120); %variable auxiliar que permite obtener 120 unos
modf=[]; %vector de datos vacios
for i=1:length(datos) %lazo for que recorre el vector v, el mismo que tiene la misma longitud de los datos originales
    mod=v(i)*mat_f; %se realiza el producto entre los 120 unos y el valor v designado anteriormente
    modf=[modf mod]; %se registra el producto obtenido en el vector modf
end

for i=1:1:length(senal) %lazo for que permite recorrer al vector senal
   if senal(i)==-1 %si el bit i es -1 se designa el valor de 0
       senal(i)=0;
   else
       senal(i)=1; %caso contrario se designa el valor de 1
   end
end

[b, ber2]= biterr(senal,modf); % se calcula el BER entre la senal de datos y la senal demodulada

for i=1:length(modf) %lazo for que recorre el vector modf
   if modf(i)==0 %si el dato i es 0, se designa el valor de -1
      modf(i)=-1;
   else %caso contrario se designa el valor de 1
      modf(i)=1; 
   end
end
 for i=1:length(senal) %lazo for que permite recorrer el vector senal
   if senal(i)==0 %si el dato 1 es  0, se designa el valor de -1
      senal(i)=-1;
   else
      senal(i)=1; %de lo contrario se designa el valor de 1
   end
end
% Grafico de las  senales de datos original y de la senal demodulada
figure(2)
subplot(2,1,1)
plot(senal)
title('Senal de datos original');
axis([0 length(SeTx) -1.5 1.5]);
subplot(2,1,2)
plot(modf)
title('Senal demodulada');
axis([0 length(SeTx) -1.5 1.5]);

figure(3)

%Senal recibida
subplot(4,1,1)
plot([1:length(SeTx)],SeTx);
axis([0 length(SeTx) -1.5 1.5]);
title('Senal Frequency Hopping Spread Spectrum en el Receptor');

%grafico de la secuencia pseudoaleatoria de frecuencias
subplot(4,1,2)
plot([1:length(ss)],ss);
axis([0 length(ss) -1.5 1.5]);
title('Secuencia pseudo-aleatoria de 6 frecuencias');

%Senal que pasa a traves del sintentizador 
subplot(4,1,3)
plot([1:length(defhss1)],defhss1);
axis([0 length(defhss1) -1.5 1.5]);
title('Senal que pasa a traves del sintetizador');

%Senal demodulada con BPSK
dembpsk1 = defhss1./portadora;
r=round(dembpsk1);


for i=1:1:length(r)
   if r(i)>0
       r(i)=1;
   else
       r(i)=-1;
   end
end
subplot(4,1,4)
plot([1:length(dembpsk1)],r);
axis([0 length(dembpsk1) -1.5 1.5]);
title('Senal ensanchada recuperada en el receptor');
for i=1:1:length(senal) %lazo for que permite recorrer al vector senal
   if senal(i)==-1 %si el bit i es -1 se designa el valor de 0
       senal(i)=0;
   else %caso contrario se designa el valor de 1
       senal(i)=1;
   end
end

for i=1:1:length(r)%lazo for que permite recorrer el vector r
   if r(i)==-1 %si el bit i es -1 se designa el valor de 0
       r(i)=0;
   else %caso contrario se designa el valor de 1
       r(i)=1;
   end
end

[a,ber1]=biterr(senal,r);%obtencion del ber entre la senal ensanchada en Rx y Rx

disp([' BER senal ensanchada es:',num2str(ber1)])
disp([' BER senal original es:',num2str(ber2)])

%%
snr1=5;
snr2=25;
SNR=[snr1;snr2];

ber1=0.2975;
ber2=0.0447;

BERSenalEnsanchada=[ber1;ber2];
ber3=0.1666;
ber4=0.0333;
BERSenalOriginal=[ber3;ber4];

Tabla=table(SNR,BERSenalEnsanchada,BERSenalOriginal);
disp(Tabla)