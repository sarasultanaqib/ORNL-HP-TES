function [Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_h()
global Tindoor Cbuild COP Pelec EPCM SOC ModePCM ModeVCS dt Tamb i Qbuilding Qhc COPH COPC Tcond Tevap Qheat AT Tbal UA
%%%Updates List%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Version 1,06092020,NK, Fixed Qevap and COPH COPC Qhc Tcond Tevap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ModePCM(i) = 0 ;                                                           %Mode of PCM Operation
ModeVCS(i) = -1 ;                                                           %Mode of VCS Operation

Tcond(i)= Tindoor(i-1) + AT;
Tevap(i)= 7;

[COPH,COPC, Qhc] = VCHP();
Qbuilding(i) = 0.26050667 *(Tamb(i) - Tbal);                               %Unit: kWth, Building Heating
SOC(i) = SOC(i-1);                                                         %Range: 0 - 1 
EPCM(i) =EPCM(i-1);                                                        %Unit: kJ, Energy in PCM
Qheat(i)= Qhc(i);                                                          %Unit: kWth, cooling load supplied to building
Tindoor (i) = Tindoor(i-1)+(((Qheat(i)+Qbuilding(i))/Cbuild)*dt);          %Unit: °C, Indoor Temperature
COP(i) = COPH(i) ;                                                         %COP of System


if Qbuilding(i) < 0;
Pelec(i) = (Qheat(i)/COP(i))/dt;                                       %Unit:kWhele, the electric power    
else
Pelec(i)=0;
end   


end

