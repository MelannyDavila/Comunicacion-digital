clear all;
close all;
%Nb is the number of bits to be transmitted
T=1;%tasa de bit 1 bit/s;
%bits a ser transmitidos
%1 1 1 0 0 1 0 1 0 1 0 0 0 0
b=[1 1 1 0 1 0 1 0 1 0 0 0 0];
%Rb is the bit rate in bits/second
 
 
NRZ=[]; %Creacion de un vector en blanco para 
%graficar los bits de entrada
Vp=1;
%Grafico de los bits con NRZ Polar
Modulate=[];
c=[];
for i=1:length(b) %lazo for desde 1 hasta la longitud de b
    t=0:0.001:1;
    f=1/T;
 if b(i)==1 %si la entrada b(i) es 1 se designa el valor de 1V 
     NRZ=[NRZ ones(1,1)*Vp];
     %c1=(sqrt(2/T)*cos((2*pi*f*t)));
 elseif b(i)==0 %si la entrada b(i) es 0 se designa el valor de -1V
     NRZ=[NRZ ones(1,1)*(-Vp)];
     %c1=-(sqrt(2/T)*cos((2*pi*f*t)));
 end
    %Modulate=[Modulate c1];
    
end
   
 
subplot(3,1,1)
plot(NRZ);
grid on
xlabel('Tiempo [s]');
ylabel('Amplitud [V]');
title('Bits enviados');

subplot(3,1,2)
stem(b);
grid on
xlabel('Tiempo [s]');
ylabel('Amplitud [V]');
title('Impulso de bits enviados');

subplot(3,1,3)
plot(Modulate);
grid on
xlabel('Tiempo [s]');
ylabel('Amplitud [V]');
title('BPSK Senal Modulada');


%%
t=0:0.005:length(b); %vector de tiempo
%Frequency of the carrier
f=1;
%Here we generate the modulated signal by multiplying it with 
%carrier (basis function)
Mod=[];
for j=1:length(b)
     if b(i)==1 %si la entrada b(i) es 1 se designa el valor de 1V 
     Mod1=(sqrt(2/T)*cos(2*pi*f*t));
     plot(Mod1);
     hold on
     elseif b(i)==0 %si la entrada b(i) es 0 se designa el valor de -1V
     Mod1=-(sqrt(2/T)*cos(2*pi*f*t));
     plot(Mod1);
     hold on
     end
     Mod=[Mod, Mod1];
     length(t)
     length(Mod)
end
t=0:1:length(Mod)-1;
length(t)
 
