function [Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_c()
global Tindoor Cbuild Qcool COP Pelec EPCM SOC ModePCM ModeVCS dt Tamb i Qbuilding Qhc COPH COPC Tcond Tevap Tspc Tbal AT UA
%%%Updates List%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Version 1,06092020,NK, Fixed Qevap and COPH COPC Qhc Tcond Tevap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ModePCM(i) = 0 ;                                                           %Mode of PCM Operation
ModeVCS(i) = 1 ;                                                           %Mode of VCS Operation

Tcond(i)=Tamb(i) + AT;
Tevap(i)= 7;



[COPH,COPC, Qhc] = VCHP();
Qbuilding(i) = 0.26050667 *(Tamb(i) - Tbal);                               %Unit: kWth, Building Heating
SOC(i) = SOC(i-1);                                                         %Range: 0 - 1 
EPCM(i) =EPCM(i-1);                                                        %Unit: kJ, Energy in PCM
Qcool(i)= Qhc(i);                                                          %Unit: kWth, cooling load supplied to building
Tindoor (i) = Tindoor(i-1)-(((Qcool(i)-Qbuilding(i))/Cbuild)*dt);          %Unit: °C, Indoor Temperature
COP(i) = COPC(i) ;                                                         %COP of System


if Qbuilding(i) > 0;
Pelec(i) = (Qcool(i)/COP(i))/dt;                                           %Unit:kWhele, the electric power    
else
Pelec(i)=0;
end   

end

