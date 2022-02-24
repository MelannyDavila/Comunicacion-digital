b = [0 1 0 1 1 1 0]; %datos de entrada
n = length(b); %numero de  datos
t = 0:.01:n; %tiempo para la modulacion
x = 1:1:(n+2)*100; %vector que empiezaa en 0 y termina en (n+2)*100, graficar datos
for i = 1:n %lazo for para graficar los datos
if (b(i) == 0) %comparacion de cada datos
b_p(i) = 0; %asignacion de nivel 0 a los bits que son igual a 0
else
b_p(i) = 1; %asignacion de nivel 1 a los bits que son igual a 1
end
for j = i:.1:i+1 %lazo for para graficar los datos
bw(x(i*100:(i+1)*100)) = b_p(i)
if (mod(i,2) == 0)
bow(x(i*100:(i+1)*100)) = b_p(i);
bow(x((i+1)*100:(i+2)*100)) = b_p(i);
else
bew(x(i*100:(i+1)*100)) = b_p(i);
bew(x((i+1)*100:(i+2)*100)) = b_p(i);
end
end
end