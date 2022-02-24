clear all;
close all;
%Nb is the number of bits to be transmitted
T=1;%Bit rate is assumed to be 1 bit/s;
%bits to be transmitted
b=[1 1 0 0 0 ]
%Rb is the bit rate in bits/second
 
 
NRZ_out=[];
  
%Vp is the peak voltage +v of the NRZ waveform
Vp=1;
%Here we encode input bitstream as Bipolar NRZ-L waveform
Mod=[]
for index=1:size(b,2)
    t=0.005:0.005:5;
    f=5;
 if b(index)==1
 NRZ_out=[NRZ_out ones(1,200)*Vp];
 Mod=[sqrt(2/T)*cos(2*pi*f*t)];
 elseif b(index)==0
 NRZ_out=[NRZ_out ones(1,200)*(-Vp)];
 Mod=[sqrt(2/T)*cos((2*pi*f*t)+pi)];
 end
end
 
%Generated bit stream impulses
figure(1);
stem(b);
xlabel('Time (seconds)-->')
ylabel('Amplitude (volts)-->')
title('Impulses of bits to be transmitted');
figure(2);
plot(NRZ_out);
xlabel('Time (seconds)-->');
ylabel('Amplitude (volts)-->');
title('Generated NRZ signal');
plot(Mod)
%%
t=0.005:0.005:5;
%Frequency of the carrier
f=5;
%Here we generate the modulated signal by multiplying it with 
%carrier (basis function)
Modulated=NRZ_out.*(sqrt(2/T)*cos(2*pi*f*t));
figure;
plot(Modulated);
xlabel('Time (seconds)-->');
ylabel('Amplitude (volts)-->');
title('BPSK Modulated signal');
 
 
y=[];
%We begin demodulation by multiplying the received signal again with 
%the carrier (basis function)
demodulated=Modulated.*(sqrt(2/T)*cos(2*pi*f*t));
%Here we perform the integration over time period T using trapz 
%Integrator is an important part of correlator receiver used here
for i=1:200:size(demodulated,2)
 y=[y trapz(t(i:i+199),demodulated(i:i+199))];
end
received=y>0;
figure;
stem(received)
title('Impulses of Received bits');
xlabel('Time (seconds)-->');
ylabel('Amplitude (volts)')
 