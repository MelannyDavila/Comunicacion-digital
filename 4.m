clear all
close all
clc
N=100; %cantidad de datos aleatorios
datos1=randi([0 1],N,1)'; %datos aleatorios usuario 1
datos2=randi([0 1],N,1)'; %datos aleatorios usuario 2
M=2;%cantidad de fases de la modulacion M-PSK
a1=pskmod(datos1,M); %modulacion de los datos del usuario 1
a2=pskmod(datos2,M); %modulacion de los datos del usuario 2
n=8; %orden de la matriz
H=hadamard(n); %uso de la funcion hadamard de matlab
F2=H(2,:); %Seleccion de la fila 2 de la matriz de Hadamard
F6=H(6,:); %Seleccion de la fila 6 de la matriz de Hadamard
for i=1:N %lazo for que recorre el vector de datos1
    if datos1(i)==0 %si el dato es 0, se designa el valor de -1
        datos1(i)=-1;
    else %caso contrario se designa el valor de 1
        datos1(i)=1; 
    end
end
m1w1=[]; %vector vacio

for i=1:N %lazo for que realiza el producto de entre el codigo Walsh y la informacion
    c1=a1(i).*F2; %producto entre los datos modulados y el codigo    
    m1w1=[m1w1 c1]; %registro del producto
    i=i+1; %incremento de la variable auxiliar i
end

for i=1:N %lazo for que permite recorrer el vector de datos 2
    if datos2(i)==0 %si los datos son 0, se designa el valor de 1
       datos2(i)=-1;
    else %caso contrario el valor de 1
        datos2(i)=1;
    end
end

m2w2=[]; %vector de datos vacio 
for i=1:N
    c2=a2(i).*F6; %producto entre los datos modulados y el codigo Walsh
    m2w2=[m2w2 c2]; %registro del producto
    i=i+1; %incremento de la variable auxiliar i
end

ifft1=ifftshift(m1w1); %uso de la transformada inversa de fourier en m1w1
ifft2=ifftshift(m2w2); %uso de la transformada inversa de fourier en m2w2

CDMA=ifft1+ifft2; %obtencion de la senal CDMA
SNR=3; %valor de SNR en dB
SeTx=awgn(CDMA,SNR); %paso a traves de canal AWGN
t=linspace(0,500,length(SeTx));
plot(t,real(SeTx))
axis([0 500 -5 5])
legend('Senal CDMA');
hold on
t1=linspace(0,250,length(ifft1));
plot(t1,1.5*(real(awgn(ifft1,SNR))-1))
axis([0 500 -5 5])
legend('Senal del usuario 1');
hold on
t2=linspace(251,500,length(ifft2));
plot(t2,1.5*(real(awgn(ifft2,SNR))-1))
axis([0 500 -5 5])
legend('Senal del usuario 2');