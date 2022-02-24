clear all
close all
clc

n=8; %orden de la matriz
b=mod(log2(n),1);%operacion modulo 1
%verificacion que el orden de la matriz sea potencia de dos
if b==0 %si no existe residuo ingresa al lazo
    H=hadamard(n); %uso de la funcion hadamard de matlab
    fprintf('La  matriz de Hadamard de orden %d generada es: \n',n);
    disp(H) %impresion de la matriz
else
    disp('El orden debe ser de potencia de 2');%impresion indicando el error
end
