clear all
close all
clc
N=100; %cantidad de datos aleatorios
SNR=20; %valor de relacion senal a ruido en dB
datos1=randi([0 1],N,1)'; %datos aleatorios usuario 1
datos2=randi([0 1],N,1)'; %datos aleatorios usuario 2
M=2;%cantidad de fases de la modulacion M-PSK
datosber=[datos1 datos2]; %union de los dos datos
n=8; %orden de la matriz
H=hadamard(n); %uso de la funcion hadamard de matlab
F2=H(2,:); %Seleccion de la fila 2 de la matriz de Hadamard
F6=H(6,:); %Seleccion de la fila 6 de la matriz de Hadamard
tb=1; %tiempo de bit
tc=tb/n; %tiempo de chip
gd1=[]; %vector vacio 
for i=1:1:100 %lazo for que recorre los datos del usuario 1
    if datos1(i)==1
     for j=0:tc/100:tb-tc/100
        gd1 = [gd1 1]; %creacion de la matriz de datos 
     end
    else
     for j=0:tc/100:tb-tc/100
        gd1 = [gd1 -1]; %creacion de la matriz de datos 
     end
    end
end
subplot(3,2,1)
txmod=linspace(0,length(datos1),length(gd1));
plot(txmod,gd1);
axis([0 10 -1.2 1.2])
title('Datos-Usuario 1')
xlabel('Tiempo[seg]')
ylabel('Amplitud [V]')

sec1=[];%vector vacio
for i=1:length(datos1) %lazo for que recorre el vector de datos 1
    sec1=[sec1 F2];%se replica la secuencia de Hadamard
end
gc=[];%vector vacio
 for i=1:length(sec1) %lazo for que recorre el vector obtenido
   if sec1(i)==-1 %si la secuencia tiene el valor de -1 se genera un vector
        for j=0:tc/100:tc-tc/100
        gc = [gc -1]; %creacion de la matriz de datos con valor -1
        end
   else
        for j=0:tc/100:tc-tc/100 %si la secuencia tiene el valor de 1 se genera un vector
        gc = [gc 1]; %creacion de la matriz de datos con valor 1
        end
   end
 end
subplot(3,2,3)
plot(txmod,gc);
axis([0 2 -1.2 1.2])
title('Secuencia Hadamard-Usuario 1')
xlabel('Tiempo[seg]')
ylabel('Amplitud [V]')

res1=gd1.*gc; %Producto entre la secuencia de Hadamard y los datos
subplot(3,2,5)
plot(txmod,res1);
axis([0 4 -1.2 1.2])
title('Senal obtenida-Usuario 1')
xlabel('Tiempo[seg]')
ylabel('Amplitud [V]')

respi=reshape(res1,800,100);%conversion de tamano
X1=ifft(respi,800); %uso de la ifft
Xaux1=X1(1:4,:); %vector auxiliar
X1=[X1;Xaux1]; %registro de los valores obtenidos

gd2=[]; %vector vacio
for i=1:1:100 %lazo for que recorre el vector de datos 2
    if datos2(i)==1 %si el dato es 1 se genera un vector
      for j=0:tc/100:tb-tc/100
        gd2 = [gd2 1]; %creacion de la matriz de datos cuyo valor es 1
      end
    else
      for j=0:tc/100:tb-tc/100
        gd2 = [gd2 -1]; %creacion de la matriz de datos cuyo valor es -1
      end
    end
end
subplot(3,2,2)
txmod2=linspace(0,length(datos2),length(gd2));%vector auxiliar de tiempo
plot(txmod2,gd2);
axis([0 10 -1.2 1.2])
title('Datos-Usuario 2')
xlabel('Tiempo[seg]')
ylabel('Amplitud [V]')

sec2=[]; %vector vacio
for i=1:length(datos2) %lazo for que permite la creacion de una matriz
    sec2=[sec2 F6];%registro de la fila de la matriz de hadamard
end
gc2=[];%vector vacio
 for i=1:length(sec2) %lazo for que recorre el arreglo creado anteriormente
   if sec2(i)==-1
        for j=0:tc/100:tc-tc/100
            gc2 = [gc2 -1]; %creacion de la matriz de datos 
        end
   else
        for j=0:tc/100:tc-tc/100
            gc2 = [gc2 1]; %creacion de la matriz de datos
        end
   end
 end
subplot(3,2,4)
plot(txmod,gc2);
axis([0 2 -1.2 1.2])
title('Walsh-Hadamart Usuario 2')
xlabel('Tiempo[seg]')
ylabel('Amplitud [V]')

res2=gd2.*gc2; %producto entre los datos y la secuencia de Hadamard
subplot(3,2,6)
plot(txmod,res2);
axis([0 4 -1.2 1.2])
title('Senal Usuario 2')
xlabel('Tiempo[seg]')
ylabel('Amplitud [V]')

respi2=reshape(res2,800,100); %conversion de tamano
X2=ifft(respi2,800); %uso de la ifft
Xaux2=X2(1:4,:);%vector auxiliar
X2=[X2;Xaux2]; %registro de los valores obtenidos

XF1=reshape(X1,1,80400); %conversion paralelo a serie
XF2=reshape(X2,1,80400); %conversion paralelo a serie
XF=[XF1 XF2]; %union de los usuarios

figure(5)
XT=XF.*cos(2*pi*(1*10)); %modulacion BPSK
txt=linspace(0,length(datos1)*2,length(XT));
plot(txt,real(XF));
axis([100 200 -0.6 0.6])
title('Senal transmitida total')
xlabel('Tiempo[seg]')
ylabel('Amplitud [V]')

figure(2)
hold on 
espT=fft(XT); %uso de la fft
espT=fftshift(espT);%obtencion del espectro total
Fmd=linspace(-1000,1000,length(espT)); %vector de tiempo auxiliar
plot(Fmd,abs(espT))
hold on
axis([0 1000 0 max(abs(espT))])
espT1=fft(XT(:,1:80400));%uso de la fft
espT1=fftshift(espT1); %obtencion del espectro del usuario 1
Fmd1=linspace(0,500,length(espT1)); %vector de tiempo auxiliar 1
plot(Fmd1,abs(espT1));
hold on
espT2=fft(XT(:,80401:160800));%uso de la fft
espT2=fftshift(espT2);%obtencion del espectro del usuario 2
Fmd2=linspace(500,1000,length(espT2)); %vector de tiempo auxiliar 2
plot(Fmd2,abs(espT2));
title('Espectro de las senales transmitidas')
xlabel('Frecuencia [MHz]')
ylabel('Amplitud [V]')
legend('Total','Usuario1','Usuario2')

XR=XT; %renombre de la variable XT
XR1=awgn(XT,SNR); %paso a traves de un canal awgn

figure(3)
espTr=fft(XR1); %uso de la fft en la senal transmitida total
espTr=fftshift(espTr); %obtencion del espectro
Fmdr=linspace(-1000,1000,length(espTr)); %vector de tiempo auxiliar
plot(Fmdr,abs(espTr))
hold on
axis([0 1000 0 max(abs(espTr))])
espT1r=fft(XR1(:,1:80400));%uso de la fft en la senal transmitida del usuario 1
espT1r=fftshift(espT1r); %obtencion del espectro
Fmd1r=linspace(0,500,length(espT1r)); %vector de tiempo auxiliar
plot(Fmd1r,abs(espT1r));
hold on
espT2r=fft(XR1(:,80401:160800)); %uso de la fft en la senal transmitida del usuario 2
espT2r=fftshift(espT2r); %obtencion del espectro
Fmd2r=linspace(500,1000,length(espT2r)); %vector de tiempo auxiliar
plot(Fmd2r,abs(espT2r));
title('Espectro de las senales recibidas')
xlabel('Frecuencia [MHz]')
ylabel('Amplitud [V]')
legend('Total','Usuario1','Usuario2')

XRD=XR./(cos(2*pi*(1*10^9))); %demodulacionn
X1R=[XRD(:,1:80400)]; %obtencion de la senal del usuario 1
X2R=[XRD(:,80401:160800)]; %obtencion de la senal dle usuario 2

X1R=reshape(X1R,804,100); %conversion a paralelo
X2R=reshape(X2R,804,100); %conversion a paralelo
X1RQ=X1R(1:800,:); %creacion de una matriz
X2RQ=X2R(1:800,:); %creacion de una matriz

X1RQF=fft(X1RQ,800); %uso de la fft en la senal 1
X2RQF=fft(X2RQ,800); %uso de la fft en la senal 2

X1RQFF=real(X1RQF); %obtencion de la aprte real de la fft de la senal 1
X2RQFF=real(X2RQF);%obtencion de la aprte real de la fft de la senal 2
X1RQFF=reshape(X1RQFF,1,80000); %conversion de paralelo a serie
X2RQFF=reshape(X2RQFF,1,80000); %conversion de paralelo a serie
datrec1=X1RQFF.*gc; %producto entre la senal 1 obtenida y la secuencia de hadamard
datrec2=X2RQFF.*gc2; %producto entre la senal 2 obtenida y la secuencia de hadamard
datrec1=awgn(datrec1,SNR); %paso a traves del canal awgn
datrec2=awgn(datrec2,SNR); %paso a traves del canal awgn
j=1; %variable auxiliar
for p=400:800:length(datrec1) %vector que recorre la senal 1
   if datrec1(p)>0.5 %dipositivo de decision
    dout1(j)=1;
     j=j+1;%incremento en la variable auxiliar
   else 
    dout1(j)=0;
     j=j+1; %incremento en la variable auxiliar
   end
end
j2=1; %variable auxiliar
for p2=400:800:length(datrec2) %vector que recorre la senal 2
   if datrec2(p2)>0.5  %dipositivo de decision
    dout2(j2)=1;
     j2=j2+1;%incremento en la variable auxiliar
   else 
    dout2(j2)=0;
     j2=j2+1;%incremento en la variable auxiliar
   end
end
doutF=[dout1 dout2]; %union de las dos senales obtenidas
[h BER]=biterr(datosber,doutF); %obtencion del BER
fprintf('La tasa de bit errado es: %0.3f \n',BER)

[f BER1]=biterr(dout1,datos1);
fprintf('La tasa de bit errado  del usuario 1 es: %0.3f \n',BER1)

[r BER2]=biterr(dout2,datos2);
fprintf('La tasa de bit errado  del usuario 2 es: %0.3f \n',BER2)
gd1r=[]; %vector vacio
for i=1:1:100 %lazo for que recorre la senal 1
    if dout1(i)==1
     for j=0:tc/100:tb-tc/100
     gd1r = [gd1r 1]; %creacion de la matriz de datos 
     end
    else
     for j=0:tc/100:tb-tc/100
     gd1r = [gd1r -1]; %creacion de la matriz de datos 
     end
    end
end
gd2r=[];%vector vacio
for i=1:1:100 %lazo for que recorre la senal 2
    if dout2(i)==1
     for j=0:tc/100:tb-tc/100
     gd2r = [gd2r 1]; %creacion de la matriz de datos 
     end
    else
     for j=0:tc/100:tb-tc/100
     gd2r = [gd2r -1]; %creacion de la matriz de datos 
     end
    end
end
figure(4)
subplot(2,2,2)
plot(txmod,gd1r)
axis([0 100 -1.2 1.2])
title('Senal recuperada-Usuario 1')
xlabel('Tiempo [seg]')
ylabel('Amplitud [V]')

subplot(2,2,1)
plot(txmod,gd1);
axis([0 100 -1.2 1.2])
title('Datos-Usuario 1')
xlabel('Tiempo[seg]')
ylabel('Amplitud [V]')

subplot(2,2,4)
plot(txmod,gd2r)
axis([0 100 -1.2 1.2])
title('Senal recuperada-Usuario 2')
xlabel('Tiempo [seg]')
ylabel('Amplitud [V]')

subplot(2,2,3)
plot(txmod,gd2);
axis([0 100 -1.2 1.2])
title('Datos-Usuario 2')
xlabel('Tiempo[seg]')
ylabel('Amplitud [V]')