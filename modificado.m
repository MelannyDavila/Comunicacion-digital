clear all
close all
clc

modulacion='4QAM'; %modulacion: BPSK, QPSK, 8PSK, 16QAM, 32QAM, 64QAM

fft_long=256; %tamano de ifft/fft

PC=16; %tamano del prefijo ciclico

SNR=20; %relacion senal a ruido en dB

num_taps=8; %numero de taps de canal (1=no canal)

estim_canal='LS'; %metodo de estimacion de canal: ninguno

%calculo del orden de la modulacion desde el metodo de modulacion
metodos_mod={'BPSK','4QAM','8PSK','16QAM'};
orden_mod=find(ismember(metodos_mod,modulacion));

%cambio de los datos a un conjunto de bits
imagen=imread('cartoon.bmp'); %lectura de la imagen
imagen_bin=dec2bin(imagen(:))'; %imagen en bits
imagen_bin=imagen_bin(:); %vector imagen

%cambio de bits a simbolos, los pads hacen que la senal tenga una longitud
%apropiada
simb_rem=mod(orden_mod-mod(length(imagen_bin),orden_mod),orden_mod); %modulacion de los bits
padding=repmat('0',simb_rem,1); %completacion de la longitud de la senal
imag_bin_padded=[imagen_bin;padding]; %imagen suavizada
constelacion_datos=reshape(imag_bin_padded,orden_mod,length(imag_bin_padded)/orden_mod)'; %creacion de la constelacion de los datos
constelacion_simb=bin2dec(constelacion_datos); %creacion de la constelacion de simbolos

%simbolos de la modulacion
%BPSK
if orden_mod==1 %si se utiliza un bit
    mod_ind=2^(orden_mod-1);
    n=0:pi/mod_ind:2*pi-pi/mod_ind;
    in_phase=cos(n); %portadora en fase
    quadrature=sin(n); %portadora en cuadratura
    symbol_book=(in_phase+quadrature*1i)';
end

%desplazamiento de fase alrededor de un circuito de radio 1
if orden_mod==2 %si se utiliza 2
    mod_ind=sqrt(2^orden_mod);
    in_phase=repmat(linspace(-1,1,mod_ind),mod_ind,1); %portadora en fase
    quadrature=repmat(linspace(-1,1,mod_ind)',1,mod_ind); %portadora en cuadratura
    symbol_book=in_phase(:)+quadrature(:)*1i;
end

%Modulaciones 16QAM y 64QAM
if orden_mod==4||orden_mod==6 %si se utilizan 4 o 6 bits
    mod_ind=sqrt(2^orden_mod);
    in_phase=repmat(linspace(-1,1,mod_ind),mod_ind,1); %portadora en fase
    quadrature=repmat(linspace(-1,1,mod_ind)',1,mod_ind); %portadora en cuadratura
    symbol_book=in_phase(:)+quadrature(:)*1i;
end

%modulacion de los datos de acuerdo al libro de simbolos
X=symbol_book(constelacion_simb+1);

%Uso de la IFFT para el dominio de tiempo
fft_tiempo=mod(fft_long-mod(length(X),fft_long),fft_long);
Senal_padded=[X;zeros(fft_tiempo,1)];
Senal_bloques=reshape(Senal_padded,fft_long,length(Senal_padded)/fft_long);
x=ifft(Senal_bloques);

%Adicion del prefijo ciclico y cambio de paralelo a serie
Senal_PC=[x(end-PC+1:end,:);x];
Senal_TX=Senal_PC(:); %senal lista para ser transmitida

%Paso a traves de un canal AWGN
Potencia_datos=mean(abs(Senal_TX.^2)); %calculo de la potencia de los datos

%Adicion de ruido al canal
Potencia_ruido=Potencia_datos/10^(SNR/10); %calculo de la potencia del ruido
Ruido=normrnd(0,sqrt(Potencia_ruido/2),size(Senal_TX))+normrnd(0,sqrt(Potencia_ruido/2),size(Senal_TX))*1i;
Senal_ruido=Senal_TX+Ruido;

%medicion del SNR
Med_SNR=10*log10(mean(abs(Senal_TX.^2))/mean(abs(Ruido.^2)));

%multitrayecto (aplicacion de fading)
M=exp(-(0:num_taps-1));
M=M/norm(M);
Senal_ruido_fading=conv(Senal_ruido,M,'same'); %senal con ruido suavizada

%Uso de la FFT para pasar al dominio de frecuencia

%Eliminacion del prefijo ciclico y paso de serial a paralelo
Senal_sinCP=reshape(Senal_ruido_fading,fft_long+PC,length(Senal_ruido_fading)/(fft_long+PC)); %senal sin prefijo ciclico
Senal_Completa_sinPC=Senal_sinCP(PC+1:end,:);

Senal_RX_bloques=fft(Senal_Completa_sinPC);%cambio al dominio de la frecuencia

%Estimacion del canal
if num_taps>1
    switch (estim_canal)
        case 'none'
        case 'LS'
            G=Senal_RX_bloques(:,1)./Senal_bloques(:,1);
            Senal_RX_bloques=Senal_RX_bloques./repmat(G,1,size(Senal_RX_bloques,2));
    end
end

%Demodulacion de los simbolos
%remover el padding de fft
X_hat=Senal_RX_bloques(:);
X_hat=X_hat(1:end-fft_tiempo);

%Recuperacion de los datos de los simbolos demodulados
rec_syms=knnsearch([real(symbol_book) imag(symbol_book)],[real(X_hat) imag(X_hat)])-1;

%Cambio de secuencia de bits y eliminacion del simbolo de padding
rec_syms_cons=dec2bin(rec_syms);
rec_im_bin=reshape(rec_syms_cons',numel(rec_syms_cons),1);
rec_im_bin=rec_im_bin(1:end-simb_rem);
ber=sum(abs(rec_im_bin-imagen_bin))/length(imagen_bin);

%%Recuperacion de la imagen
rec_im=reshape(rec_im_bin,8,numel(rec_im_bin)/8);
rec_im=uint8(bin2dec(rec_im'));
rec_im=reshape(rec_im,size(imagen));

%Generacion de las gr\'aficas

%constelacion de de la senal transmitida
subplot(2,2,1);
plot(X,'x','linewidth',2,'markersize',10);
xlim([-2 2]);
ylim([-2 2]);
xlabel('Fase');
ylabel('Cuadratura');

if num_taps>1
    title(sprintf('\\bfDiag. Const. de  la senal OFDM en el Tx   \n \\rm Modulacion: %s',modulacion));
else
    title(sprintf('\\bfDiag. Const. de  la senal OFDM en el Tx   \n \\rm Modulacion: %s ',modulacion));
end
grid on;

%Constelacion recuperada 
subplot(2,2,2);
plot(X_hat(1:500:end),'x','markersize',3);
xlim([-4 4]);
ylim([-4 4]);
xlabel('Fase');
ylabel('Cuadratura');
if num_taps>1
    title(sprintf('\\bfDiag. Const. de  la senal OFDM en el Rx\n \\rm SNR: %.2f dB', Med_SNR));
else
    title(sprintf('\\bfDiag. Const. de  la senal OFDM en el Rx\n]]rm SNR: %.2f dB',Med_SNR));
end    
grid on;

%Imagen original
subplot(2,2,3);
imshow(imagen);
title('\bfImagen original en el Tx');

%Imagen recuperada
subplot(2,2,4);
imshow(rec_im);
title(sprintf('\\bfImagen recuperada en el Rx\n\\rmBER: %.2g',ber));

%Impresion del BER
disp(['Probabilidad de bit errado (BER): ', num2str(ber) ])
    