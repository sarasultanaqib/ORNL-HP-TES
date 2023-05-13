function [COPH,COPC,Qhc] = VCHP()

global COPH COPC Qhc Tcond Tevap i


%Parameter a 
% This curve fits the density of R410A saturated vapor - the compressor suction density
a(i) = (30.5571378+1.02160466*Tevap(i)+0.0138446344*Tevap(i)^2);           %Tevap: °C

%Parameter b 
% Normalizes the result so that we get 7 kW at Tevap=0°C and Tcond = 35°C
b = 7.5/30.58;

%Parameter c 
% This accounts for the increase in vapor mass fraction quality entering the evaporator during isenthalpic expansion. 1.5 is approximate Cp and 220 is approximate hfg for R410A
c(i) = 1-(1.5*(Tcond(i)-Tevap(i))/220);                                    %Tcond & Tevap: °C

%Heating and Cooling Capacity 
Qhc(i) = a(i)*b*c(i);                                                      %kW

Tcond_k(i) = Tcond(i)+273.15;                                              % Converting Tcond from °C to K
Tevap_k(i) = Tevap(i)+273.15;                                              % Converting Tevap from °C to K

%Heating COP
COPH(i) = 0.3*(Tcond_k(i)/(Tcond_k(i) - Tevap_k(i)));

%Cooling COP
COPC(i) = 0.35*(Tevap_k(i)/(Tcond_k(i) - Tevap_k(i)));

end 

