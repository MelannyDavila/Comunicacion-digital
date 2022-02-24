%% SISTEMA CDMA BASICO
close all;
clear all;
clc;
%% TRANSMISOR
%GENERACION DE LA SECUENCIA DE DATOS Y DE LA SECUENCIA EXPANDIDA 
Senal_extendida=[];
N1=10; %longitud del vector de datos
datos=randi([0 1],N1,1)'; %vector de datos aleatorio
N=16; %longitud de la secuencia OVSF
In=9; %indice del codigo OVSF
H = comm.OVSFCode('SpreadingFactor',N,'SamplesPerFrame',N,'Index',In); %objeto que permite la creaciond el codigo gold
secOVSF=H()'; %secuencia del codigo gold obtenida

for i=1:length(secOVSF)
    if secOVSF(i)==-1
        secOVSF(i)=0;
    else
        secOVSF(i)=1;
    end    
end     
k=1; %variable auxiliar para recorrer el lazo for

%GENERACION DE LA SECUENCIA EXPANDIDA
for i=1:N1 %lazo for anidado para realizar la expansion
    for j=1:N
        Senal_extendida(1,k)=xor(datos(1,i),secOVSF(1,j)); %uso de la funcion xor para el calculo del resultado ente la secuencia gold y los datos
        k=k+1; %incremento en la variable auxiliar
    end
end

%GRAFICA DE LAS SECUENCIAS DE DATOS 
figure
Tb=10; %variable que describe el tiempo de bit
Dato_extendido = rectpulse(datos(1,:),10); %se extienden los datos para la grafica
subplot(4,2,1); 
stairs(Dato_extendido); %grafica de los datos extendidos
axis([0 length(Dato_extendido) -0.5 1.5]) %ejes
title({'{\color{red} TRANSMISOR}';'Secuencia de datos transmitidos'}); %titulo

%GRAFICA DE LA SECUENCIA GOLD
Gold_extendida = rectpulse(secOVSF(1,:),10); %extension de la secuencia Gold
subplot(4,2,3); 
stairs(Gold_extendida,'y'); %grafico de la secuencia Gold
axis([0 length(Gold_extendida) -0.5 1.5])
title(' Secuencia OVSF '); %titulo

%GRAFICA DE LA SECUENCIA EXPANDIDA
Senal1 = rectpulse(Senal_extendida(1,:),10); %tension de la secuencia expandida
subplot(4,2,5); 
stairs(Senal1,'r');  %grafico de la secuencia expandida
axis([0 length(Senal1) -0.5 1.5]) %ejes
title(' Secuencia expandida') %titulo

%ETAPA DE MODULACION M-QAM
bp = 100; %tiempo de bit
M=4; %Numero de fase de modulacion
semod = qammod(Senal_extendida,M); %modulacion de la senal con M fases

%OBTENCION DE LOS DATOS PARA GRAFICAR 4QAM
RealMod=real(semod); %parte real de la modulacion
ImagMod=imag(semod); %parte imaginaria de la modulacion
sp=bp*2; %tiempo de spread (2 veces el tiempo de bit)                                     
sr=1/sp; %velocidad de spread                                                      
f=sr*2;%frecuencia
t=sp/100:sp/100:sp; %vector de tiempo
ss=length(t); %longitud del vector del tiempo
m=[]; %vector vacio para registrar las componentes reales e imaginarias de la modulacion

%CREACION DE LA SENAL MODULADA

for(k=1:1:length(RealMod))
    yr=RealMod(k)*cos(2*pi*f*t); %producto entre la portadora Q  y la parte real
    yim=ImagMod(k)*sin(2*pi*f*t); %producto entre la portadora I y la parte imaginaria            
    y=yr+yim; %suma de ambas componentes
    m=[m y]; %registro en el vector creado anteriormente
end
Tiempo=sp/100:sp/100:sp*length(RealMod); %vector de tiempo 
subplot(4,2,7);
plot(Tiempo,m,'b'); %grafica de la  senal modulada
axis([0 5000 -2.5 2.5]) %ejes
title('Senal modulada con 4QAM'); %titulo

%% CANAL CON RUIDO AWGN

SNR = 3; %variable que describe la relacion senal a ruido en dB
ruido = awgn(semod,SNR); %paso a traves de un canal AWGN

bp = 100; %tiempo de bit
RealMod=real(ruido); %obtencion de la parte real de la senal con ruido
ImagMod=imag(ruido); %obtencion de la parte imaginaria de la senal con ruido
sp=bp*2; %tiempo de spread                                     
sr=1/sp; %velocidad de spread                                                     
f=sr*2; %frecuencia
t=sp/100:sp/100:sp; %vector de tiempo
ss=length(t);%longitud del vector de tiempo
m=[]; %vector vacio que permite guardar en memoria los datos obtenidos
for(k=1:1:length(RealMod)) %lazo for que permite realizar la suma de la parte real e imaginaria de la senal
    yr=RealMod(k)*cos(2*pi*f*t);%canal Q                     
    yim=ImagMod(k)*sin(2*pi*f*t);%canal I             
    y=yr+yim; %suma del canal Q con el canal I
    m=[m y]; %registro de los valores obtenidos
end 
Tiempo=sp/100:sp/100:sp*length(RealMod); %vector de tiempo para graficar
subplot(4,2,2);
plot(Tiempo,m,'b'); %grafica de la senal obtenida
axis([0 5000 -2.5 2.5]) %eje
title({'{\color{red} RECEPTOR}';'Secuencia de datos recibidos'}); %titulo

%% RECEPCION
%DEMODULACION DE LA SENAL RECIBIDA
sedemod = qamdemod(ruido,M); %demodulacion de la senal de datos con M fases 
sedemod_pulso = rectpulse(sedemod(1,:),10); %extension de la senal demodulada

for i=1:1:length(sedemod)
    if sedemod(i)>=1 
        sedemod(i)=1;
    else
        sedemod(i)=0;
    end
end    
subplot(4,2,4); 
stairs(sedemod_pulso,'r');  %grafica de la senal demodulada
axis([0 length(sedemod_pulso) -0.5 1.5]) %ejes
title(' Senal demodulada') %titulo

%RECUPERACION DE LA SENAL ORIGINAL
i=1; %variable auxiliar para el lazo for
k=1; %variable auxiliar para el bucle while
los= length(sedemod); %longitud de los datos demodulados
while k < los %bucle while permite recurrer hasta la longitud maxima del vector
    s=0; %variable auxiliar
for j=1:N %lazo for que permite realizar la multiplicacion de los datos recibidos con la secuencia Gold
    SenalRecibida(1,j) = xor(sedemod(1,k),secOVSF(1,j)); %producto xor entre la senal demodulada y la secuencia Gold
    k=k+1; %incremento de la variable k
    s=s+SenalRecibida(1,j);% se guardan los valores obtenidos del producto
end
    %la siguiente condicion permite implementar el dispositivo de decision
    if(s==0) %si s es cero, se designa el valor de 0
        b2(1,i) = 0;
    else %caso contrario el valor de 1
        b2(1,i) = 1; 
    end
        i=i+1; %se incrementa la variable i
end
Senal_no_ensanchada= b2; %obtencion de la senal no ensanchada
 
p=[]; %vector vacio que permite registar valores
for k=1:N1 %lazo for que recorre la senal no ensanchada para expandirla
    if b2(1,k)==0 %si el dato k es 0, se asignan 10 ceros
       senal1=zeros(1,10);
    else %caso contrario, se asignan 10 unos
        senal1=ones(1,10);
    end
    p=[p senal1]; %registro de los valores asignados
end
%GRAFICA DE LAS SENALES RECUPERADAS
Gold_extendida = rectpulse(secOVSF(1,:),10); %extension de la secuencia Gold extendida
subplot(4,2,6); 
stairs(Gold_extendida,'y'); %grafica de la secuencia Gold
axis([0 length(Gold_extendida) -0.5 1.5]) %ejes
title('Secuencia OVSF'); %titulo

subplot(4,2,8); 
stairs(p); %grafica de la senal recuperada extendida
axis([0 length(p) -0.5 1.5]) %ejes
title('Senal recuperada') %titulo

%CALCULO DEL BER
[a ber]=biterr(Dato_extendido,p);
fprintf('La tasa de bit errado es: %f \n',ber);

