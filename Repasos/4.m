clear all
close all
clc
Tb=1;
t=0:(Tb/100):Tb;
f=2
m=[0 1 0 0 1 1 0 1];
B1=[];

for i=1:2:length(m)
    b1=m(i);
    B1=[B1 b1];
end

B2=[];

for i=2:2:length(m)
    b2=m(i);
    B2=[B2 b2];
end

B1;
B2;

s=[];
din=0;
for i=1:1:(length(m)/2)
    if B1(i)==0 && B2(i)==0
       d(i)=0-din;
       c=-cos((2*pi*f*t)+d(i));
       c1=c;  
       s=[s c1];
       din=0;
    end
    
    if B1(i)==0 && B2(i)==1
       d(i)=pi/2-din;
       c=cos((2*pi*f*t)+d(i));
       c2=c;
       s=[s c2];
       din=-pi/2;
    end
    
    if B1(i)==1 && B2(i)==0
       d(i)=3*pi/2+din;
       c=cos((2*pi*f*t)+d(i));
       c3=c;
       s=[s c3];
       din=-(3*pi)/2;
    end
    
    if B1(i)==1 && B2(i)==1
        d(i)=pi+din;
        c=-cos((2*pi*f*t)+d(i));
        c4=c;
        s=[s c4];
        din=pi;
    end
end

plot(s)
grid on