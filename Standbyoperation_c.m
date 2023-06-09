function [Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Standbyoperation_c()
global Tindoor Cbuild Qcool COP Pelec EPCM SOC ModePCM ModeVCS dt Tamb  i Qbuilding Qhc  Tbal Tcond Tevap COPC COPH AT UA

%%%Updates List%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Version 1,06092020,NK, Fixed Qevap and COP. NOTES: Change to EES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ModePCM(i) = 0 ;                                                           %Mode of PCM Operation
ModeVCS(i) = 0 ;                                                           %Mode of VCS Operation

Tcond(i)=Tamb(i) + AT;
Tevap(i)=Tindoor(i-1) - AT;
COPC(i)=0;
COPH(i)=0;

Qbuilding(i) = 0.26050667 *(Tamb(i) - Tbal);                               %Unit: kWth, Building Heating 
Qhc(i)=0;                                                                 %Unit: kWth, Heat Cond
Qcool (i) = 0;                                                             %Unit: kWth, cooling load supplied to building
EPCM (i) =EPCM(i-1);                                                       %Unit: kJ, Energy in PCM
SOC (i) = SOC(i-1);                                                        %Range: 0 - 1 
COP (i) = 0;                                                               %COP of System
Tindoor(i) = Tindoor(i-1)-(((-Qbuilding(i)+Qcool(i))/Cbuild)*dt);          %Unit: �C, Indoor Temperature
Pelec(i) = 0;                                                              %Unit:kWhele, the electric power
end

