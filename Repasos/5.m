clear all
close all
clc;
tb = 1; %Se declara un tiempo de bit
h = [1 1 1 0 0 1 0 1 0 1 0 0 0 0];
a=length(h);
d = 0; %declaracion de desfase
d_1 = 0;
y = []; %matriz 
x = [];
f = 1/tb;
t = 0:1/100000:tb; %Tb
t2 = 0:1/100000:tb*2; %Tb
%% Grafico NRZ
n=1

while n<=length(h)-1;
    t=n-1:0.001:n;
if h(n) == 0
    if h(n+1)==0  
        y=(t>n);
    else
        y=(t==n);
    end
    subplot(3,1,1);
    d=plot(t,y,"k");grid on;
    title('DATOS DE ENTRADA');
    set(d,'LineWidth',2);
    hold on;
    axis([0 length(h)-1 -1.5 1.5]);

else
    if h(n+1)==0
        %y=(t>n-1)-2*(t==n);
        y=(t<n)-0*(t==n);
    else
        %y=(t>n-1)+(t==n-1);
        y=(t<n)+1*(t==n);
    end
    %y=(t>n-1)+(t==n-1);
    subplot(3,1,1);
    d = plot(t,y,"k");grid on;
    title('DATOS DE ENTRADA');
    set(d,'LineWidth',2);
    hold on;

end
n=n+1;
%pause; 
end
 
grid on
xlabel('Tiempo [s]');
ylabel('Amplitud [V]');
title('Bits enviados');


%% MODULACION D-BPSK
 for i=1:1:length(b)
   if b(i) == 0 
        d = d + pi; %aumentamos el desfase en pi
        y = [y cos((2*pi*f*t)+d)]; %completamos los datos de mi matriz y
         
   else
        t2 = 0:1/100000:tb; %Tb
        y = [y cos((2*pi*f*t2) + d)]; %completamos los datos de mi matriz y
   end
 end
   
 subplot(3,1,2);
 t = linspace(0,tb*length(b),1400014); %tiempo
 plot (t,y ,"LineWidth",2) %Grafica
 grid on
 
 title('Modulacion D-BMSK') %titulo
 ylabel('A. Normalizada') %eje y 
 xlabel('Tiempo [ms]') %eje x
 
 %% MODULACION QPSK
 
for j=1:2:length(b)
     
   if b(j)==0 && b(j+1) == 0
        d_1; %aumentamos el desfase en pi
        x = [x cos((2*pi*f*t2)+d_1)]; %completamos los datos de mi matriz y
         
   elseif b(j)==0 && b(j+1) == 1
           
        d_1 = d_1 + pi/2; %aumentamos el desfase en pi
        x = [x cos((2*pi*f*t2)+d_1)]; %completamos los datos de mi matriz y
        
   elseif b(j)==1 && b(j+1) == 1
       d_1 = d_1 + pi; %aumentamos el desfase en pi
        x = [x cos((2*pi*f*t2)+d_1)]; %completamos los datos de mi matriz y
       
       
   elseif b(j)==1 && b(j+1) == 0
       d_1 = d_1 + 3*pi/2; %aumentamos el desfase en pi
       x = [x cos((2*pi*f*t2)+d_1)]; %completamos los datos de mi matriz y
                    
   end
 end
 subplot(3,1,3);
 t_1 = linspace(0,tb*length(b),700007); %tiempo
 plot (t_1,x,"LineWidth",2) %Grafica
 grid on
 
 title('Modulacion D-QMSK') %titulo
 ylabel('A. Normalizada') %eje y 
 xlabel('Tiempo [ms]') %eje x
 
 





