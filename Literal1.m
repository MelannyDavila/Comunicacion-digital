clear all
close all
clc

mod_method='QPSK'; %modulacion: BPSK, QPSK, 8PSK, 16QAM, 32QAM, 64QAM

n_fft=256; %tamaño de ifft/fft

n_cpe=16; %tamano del prefijo ciclico

snr=25; %relacion senal a ruido en dB

n_taps=8; %numero de taps de canal (1=no canal)

ch_est_method='LS'; %metodo de estimacion de canal: ninguno

save_file=0; %opcion para guardar el dibujo en un archivo

%calculo del orden de la modulacion desde el metodo de modulacion
mod_methods={'BPSK','QPSK','8PSK','16QM','32QAM','64QAM'};
mod_order=find(ismember(mod_methods,mod_method));

%cambio de los datos a un conjunto de bits
im=imread('blacky.bmp'); %lectura de la imagen
im_bin=dec2bin(im(:))';
im_bin=im_bin(:);

%cambio de bits a simbolos, los pads hacen que la senal tenga una longitud
%apropiada
sym_rem=mod(mod_order-mod(length(im_bin),mod_order),mod_order);
padding=repmat('0',sym_rem,1);
im_bin_padded=[im_bin;padding];
cons_data=reshape(im_bin_padded,mod_order,length(im_bin_padded)/mod_order)';
cons_sym_id=bin2dec(cons_data);

%simbolos de la modulacion
%BPSK
if mod_order==1
    mod_ind=2^(mod_order-1);
    n=0:pi/mod_ind:2*pi-pi/mod_ind;
    in_phase=cos(n);
    quadrature=sin(n);
    symbol_book=(in_phase+quadrature*1i)';
end

%desplazamiento de fase alrededor de un circuito de radio 1
if mod_order==2 || mod_order==3
    mod_ind=2^(mod_order-1);
    n=0:pi/mod_ind:2*pi-pi/mod_ind;
    in_phase=cos(n+pi/4);
    quadrature=sin(n+pi/4);
    symbol_book=(in_phase+quadrature*1i)';
end

%Modulaciones 16QAM y 64QAM
if mod_order==4||mod_order==6
    mod_ind=sqrt(2^mod_order);
    in_phase=repmat(linspace(-1,1,mod_ind),mod_ind,1);
    quadrature=repmat(linspace(-1,1,mod_ind)',1,mod_ind);
    symbol_book=in_phase(:)+quadrature(:)*1i;
end


%Modulacion 32QAM
if mod_order==5
    mod_ind=6;
    in_phase+repmat(linspace(-1,1,mod_ind),mod_ind,1);
    quadrature=repmat(linspace(-1,1,mod_ind)',1,mod_ind);
    symbol_book=in_phase(:)+quadrature(:)*1i;
    symbol_book=symbol_book([2:5 7:30 32:35]);
end

%modulacion de los datos de acuerdo al libro de simbolos
X=symbol_book(cons_sym_id+1);

%Uso de la IFFT para el dominio de tiempo
fft_rem=mod(n_fft-mod(length(X),n_fft),n_fft);
X_padded=[X;zeros(fft_rem,1)];
X_blocks=reshape(X_padded,n_fft,length(X_padded)/n_fft);
x=ifft(X_blocks);

%Adicion del prefijo ciclico y cambio de paralelo a serie
x_cpe=[x(end-n_cpe+1:end,:);x];
x_s=x_cpe(:);

%Paso a traves de un canal AWGN
data_pwr=mean(abs(x_s.^2)); %calculo de la potencia de los datos

%Adicion de ruido al canal
noise_pwr=data_pwr/10^(snr/10);
noise=normrnd(0,sqrt(noise_pwr/2),size(x_s))+normrnd(0,sqrt(noise_pwr/2),size(x_s))*1i;
x_s_noise=x_s+noise;

%medicion del SNR
snr_meas=10*log10(mean(abs(x_s.^2))/mean(abs(noise.^2)));

%multitrayecto (aplicacion de fading)
g=exp(-(0:n_taps-1));
g=g/norm(g);
x_s_noise_fading=conv(x_s_noise,g,'same');

%Uso de la FFT para pasar al dominio de frecuencia

%Eliminacion del prefijo ciclico y paso de serial a paralelo
x_p=reshape(x_s_noise_fading,n_fft+n_cpe,length(x_s_noise_fading)/(n_fft+n_cpe));
x_p_cpr=x_p(n_cpe+1:end,:);

X_hat_blocks=fft(x_p_cpr);%cambio al dominio de la frecuencia

%Estimacion del canal
if n_taps>1
    switch (ch_est_method)
        case 'none'
        case 'LS'
            G=X_hat_blocks(:,1)./X_blocks(:,1);
            X_hat_blocks=X_hat_blocks./repmat(G,1,size(X_hat_blocks,2));
    end
end

%Demodulacion de los simbolos
%remover el padding de fft
X_hat=X_hat_blocks(:);
X_hat=X_hat(1:end-fft_rem);

%Recuperacion de los datos de los simbolos demodulados
rec_syms=knnsearch([real(symbol_book) imag(symbol_book)],[real(X_hat) imag(X_hat)])-1;

%Cambio de secuencia de bits y eliminacion del simbolo de padding
rec_syms_cons=dec2bin(rec_syms);
rec_im_bin=reshape(rec_syms_cons',numel(rec_syms_cons),1);
rec_im_bin=rec_im_bin(1:end-sym_rem);
ber=sum(abs(rec_im_bin-im_bin))/length(im_bin);

%%Recuperacion de la imagen
rec_im=reshape(rec_im_bin,8,numel(rec_im_bin)/8);
rec_im=uint8(bin2dec(rec_im'));
rec_im=reshape(rec_im,size(im));

%Generacion de las gr\'aficas

%constelacion de de la senal transmitida
subplot(2,2,1);
plot(X,'x','linewidth',2,'markersize',10);
xlim([-2 2]);
ylim([-2 2]);
xlabel('In phase');
ylabel('Quadrature');

if n_taps>1
    title(sprintf('\\bfConstelacion de  la senal OFDM transmitida \n \\rm Modulacion: %s',mod_method));
else
    title(sprintf('\\bfConstelacion de  la senal OFDM transmitida\n \\rm Modulacion: %s ',mod_method));
end
grid on;

%Constelacion recuperada
subplot(2,2,2);
%plot(X_hat(1:500:end),'x','markersize',3);
xlim([-4 4]);
ylim([-4 4]);
xlabel('In phase');
ylabel('Quadrature');
if n_taps>1
    title(sprintf('\\bfConstelacion de  la senal OFDM recibida\n \\rm SNR: %.2f dB', snr_meas));
else
    title(sprintf('\\bfConstelacion de  la senal OFDM recibida\n]]rm SNR: %.2f dB',snr_meas));
end    
grid on;

%Imagen original
subplot(2,2,3);
imshow(im);
title('\bfImagen Transmitida');

%Imagen recuperada
subplot(2,2,4);
imshow(rec_im);
title(sprintf('\\bfImagen Recibida\n\\rmBER: %.2g',ber));

%Posicion de la figura
%set(gcf,'Position',[680 2877 698 691]);
  
    
    
    
    
    
    
