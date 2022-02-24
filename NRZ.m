
function NRZ(h)

clf;
n=1;
l=length(h);
h(l+1)=1;
while n<=length(h)-1;
    t=n-1:0.001:n;
if h(n) == 0
    if h(n+1)==0  
        y=(t>n);
    else
        y=(t==n);
    end
    subplot(3,1,1);
    d=plot(t,y,'b');grid on;
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
    d = plot(t,y,'b');grid on;
    title('DATOS DE ENTRADA');
    set(d,'LineWidth',2);
    hold on;

end
n=n+1;
%pause; 
end