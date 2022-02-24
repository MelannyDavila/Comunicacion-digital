function x = GRAFICAR(SecEntada)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

Sec=SecEntada;
longitud=length(Sec);
Sec(longitud+1)=0;
n=1;

while n<=longitud
    rx=(n-1):0.001:n;   %tiempo de 0 a n
    
    if Sec(n)==1 %Condicion para cada bit
        if Sec(n+1)==Sec(n)
            yy=(rx<=n); %valor logico
        else 
            yy=(rx<n);
        end
    else
        if Sec(n+1)==Sec(n)
            yy=(rx>n);
        else
            yy=(rx>=n);
        end
    end
    plot(rx,yy,'Linewidth',2);
    hold on;
    axis([0 longitud -0.25 1.25]);
    grid on;
    n=n+1;  
end
end

