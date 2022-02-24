clear all;
close all;
%Nb is the number of bits to be transmitted
T=1;%tasa de bit 1 bit/s;
%bits a ser transmitidos
%1 1 1 0 0 1 0 1 0 1 0 0 0 0
b=[0 0 1 1 0]
%Rb is the bit rate in bits/second
 
 
NRZ=[]; %Creacion de un vector en blanco para 
%graficar los bits de entrada
Vp=1;
%Grafico de los bits con NRZ Polar
for i=1:length(b) %lazo for desde 1 hasta la longitud de b
 if b(i)==1 %si la entrada b(i) es 1 se designa el valor de 1V 
 NRZ=[NRZ ones(1,200)*Vp];
 elseif b(i)==0 %si la entrada b(i) es 0 se designa el valor de -1V
 NRZ=[NRZ ones(1,200)*(-Vp)];
 end
end
t=0.005:0.005:5;
%Frequency of the carrier
f=5;
%Here we generate the modulated signal by multiplying it with 
%carrier (basis function)
Modulated=NRZ.*(sqrt(2/T)*cos(2*pi*f*t));
figure;
plot(Modulated);
xlabel('Time (seconds)-->');
ylabel('Amplitude (volts)-->');
title('BPSK Modulated signal');

plot(t,Mod)