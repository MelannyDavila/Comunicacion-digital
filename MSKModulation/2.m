clear;
clc;
b = [0 1 0 1 1 1 0]; %datos de entrada
n = length(b); %numero de  datos
t = 0:.01:n; %tiempo para la modulacion
x = 1:1:(n+2)*100; 
for i = 1:n %lazo for para graficar los datos
if (b(i) == 0) %comparacion de cada datos
b_p(i) = 0; %asignacion de nivel 0 a los bits que son igual a 0
else
b_p(i) = 1; %asignacion de nivel 1 a los bits que son igual a 1
end
for j = i:.1:i+1 %lazo for para 
bw(x(i*100:(i+1)*100)) = b_p(i);
if (mod(i,2) == 0)
bow(x(i*100:(i+1)*100)) = b_p(i);
bow(x((i+1)*100:(i+2)*100)) = b_p(i);
else
bew(x(i*100:(i+1)*100)) = b_p(i);
bew(x((i+1)*100:(i+2)*100)) = b_p(i);
end
if (mod(n,2)~= 0)
bow(x(n*100:(n+1)*100)) = -1;
bow(x((n+1)*100:(n+2)*100)) = -1;
end
end
end
bw = bw(100:end);
bew = bew(100:(n+1)*100);
bow = bow(200:(n+2)*100);
wot = 2*pi*t*(5/4);
Wt = 2*pi*t/(4*1);
st = bow.*sin(wot+(bew.*bow).*Wt);
subplot(2,1,1)
plot(t,bw)
grid on ; axis([0 n -2 +2])

subplot(2,1,2)
plot(t,st)
grid on ; axis([0 n -2 +2])
Fs=5/4; %figure
%periodogram(st)
S = fft(st,65);
PSS = S.* conj(S) / 65;
f = 1000*(-16:16)/65;
