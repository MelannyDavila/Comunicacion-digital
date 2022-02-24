clear all
close all
clc
tb = 1; %Se declara un tiempo de bit
datos = [1 1 1 0 0 1 0 1 0 1 0 0 0 0]; %Se crea un vector de datos
d = 0; %valor de desfase inicial
d_1 = 0; %valor de desfase para DQPSK
y = []; %vector para la modulacion DBQPSK
x = []; %vector para la modulacion DQPSK
f = 1/tb; %frecuencia de la senal coseno
t = 0:1/100000:tb; %vector de tiempo modulacion DBPSK
t1 = 0:1/100000:tb*2; %vector de tiempo modulacion DQPSK


%% MODULACION D-BPSK
 for i=1:1:length(datos) %lazo for para recorrer los bits de datos
   if datos(i) == 0 %comparacion de los bits
        d = d + pi; %aumentamos el desfase en pi
        y = [y cos((2*pi*f*t)+d)]; %se completa el vector y con los datos
         
   else
        t1 = 0:1/100000:tb; %se declara el vector de tiempo 
        %porque la fase no cambia
        y = [y cos((2*pi*f*t1) + d)]; %se completa el vector y con los datos
   end
 end
 

subplot(3,1,1);
NRZ(datos); %uso de la funcion creada para graficar los bits de datos
   
subplot(3,1,2);
t = linspace(0,tb*length(datos),1400014); %vector de tiempo
plot (t,y ,"LineWidth",2) %Grafica D-BPSK
grid on
title('Modulacion D-BMSK') %titulo
ylabel('A. Normalizada') %eje y 
xlabel('Tiempo [ms]') %eje x
 
 %% MODULACION QPSK
 
 for j=1:2:length(datos) %lazo for para recorrer el vecto de datos
     
   if datos(j)==0 && datos(j+1) == 0 %si los datos i y i+1 son 0
       %se designa como un desfase  de 0 
        d_1; %la fase a utilizar es la misma a la anterior
        x = [x cos((2*pi*f*t1)+d_1)]; %se completa el vector x
         
   elseif datos(j)==0 && datos(j+1) == 1 %si el datos i es 0 y el dato i+1 
       %es 1 se designa como un desfase  de 90
           
        d_1 = d_1 + pi/2; %aumentamos el desfase en pi/2
        x = [x cos((2*pi*f*t1)+d_1)]; %se completa el vector x
        
   elseif datos(j)==1 && datos(j+1) == 1 %si el datos i es 1 y el dato i+1 
       %es 1 se designa como un desfase  de 180
       d_1 = d_1 + pi; %aumentamos el desfase en pi
        x = [x cos((2*pi*f*t1)+d_1)]; %se completa el vector x
       
       
   elseif datos(j)==1 && datos(j+1) == 0 %si el datos i es 1 y el dato i+1 
       %es 0 se designa como un desfase  de 270
       d_1 = d_1 + 3*pi/2; %aumentamos el desfase en 3pi/2
       x = [x cos((2*pi*f*t1)+d_1)];%se completa el vector x
                    
   end
 end
subplot(3,1,3);
t_1 = linspace(0,tb*length(datos),700007); %vector de tiempo
plot (t_1,x,"LineWidth",2) %Grafica D-QPSK
grid on
title('Modulacion D-QMSK') %titulo
ylabel('A. Normalizada') %eje y 
xlabel('Tiempo [ms]') %eje x
 
 




