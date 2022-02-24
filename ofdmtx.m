clc;
clear all;
close all;

no_of_data_bits = 1024;%Numero de bits
M = 8; %Estado de modulacion
block_size = 16; %longitud para determinar el CP
cp_len = floor(0.1 * block_size); %Prefijo ciclico

% Etapa de transmision
data = randsrc(1, no_of_data_bits, 0:1); %generacion de bits aleatoriamente entre 1 y 0
figure(1),stairs(data); axis([0 length(data) -0.5 1.5]); grid minor; xlabel('Tiempo'); ylabel('Amplitud')
%Grafica de los datos generados 
title('Datos generados ')

% Modulacion M-PSK
opsk_modulated_data = pskmod(data, M);
% Convertir los datos serie a paralelo 
S2P = reshape(opsk_modulated_data, no_of_data_bits/64,64);

%designamos un numero determinado de portadoras
number_of_subcarriers=64;
%Obtenemos las longitudes del prefijo ciclico
cp_start=block_size-cp_len;


for i=1:number_of_subcarriers
ifft_Subcarrier(:,i) = ifft((S2P(:,i)),16);
% transformada inversa de fourier a los datos en paralelo
for j=1:cp_len
cyclic_prefix(j,i) = ifft_Subcarrier(j+cp_start,i);
%asiganacion del CP
end
Append_prefix(:,i) = vertcat( cyclic_prefix(:,i), ifft_Subcarrier(:,i));
%Datos con el CP
end

%conversion de paralelo a serie 
[rows_Append_prefix, cols_Append_prefix]=size(Append_prefix);
len_ofdm_data = rows_Append_prefix*cols_Append_prefix;

ofdm_signal = reshape(Append_prefix, 1, len_ofdm_data);
figure(2),plot((real(ofdm_signal)));axis([1 64 -0.1 0.35]); xlabel('Tiempo'); ylabel('Amplitud');
title('Senal OFDM');grid minor;
%obtencion de la senal OFDM en dominio del tiempo

%grafica del espectro en frecuencia 
figure(3)
%transforma de fourier 
tfsm=fft(real(ofdm_signal),1600/64 *length(real(ofdm_signal)));
tfsm = fftshift(tfsm); 
%asiganacion de los limites de para representarlo graficamente 
x1 = floor((1/2-(3*32/(2*1600)))*length(tfsm));
x2 = floor((1/2+(5*32/(2*1600)))*length(tfsm));
tfsm = tfsm(x1:x2);
%tratamiento de datos para poder crear un espacio vectorial
tfsm = 10*log10(abs(tfsm)); 
Fmd=linspace(-1000,1000,length(tfsm));
plot(Fmd,tfsm);
axis([-100 1000 -30 10]);
grid minor;
title('Espectro en frecuencia de la senal OFDM');
xlabel('Frecuencia (Hz)');
ylabel('Amplitud');


Fmd1=linspace(-1000,1000,length(ofdm_signal));
figure(4)
plot(Fmd1,10*log10(abs(fft(ofdm_signal))));
