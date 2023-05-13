function [Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Dischargingoperation_h()
global Tindoor Cbuild Qcool COP Pelec EPCM SOC ModePCM ModeVCS dt Tamb i Qbuilding EPCMini Tcond Tevap COPH COPC Qhc Tpcm AT Tbal Qheat UA

%%%Updates List%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Version 1,06092020,NK, Fixed Qevap and COP. NOTES: Change to EES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ModePCM(i) = -1;                                                           %Mode of PCM Operation
ModeVCS(i) = -3 ;                                                           %Mode of VCS Operation
Qbuilding(i) = 0.26050667 *(Tamb(i)-Tbal);                         %Unit: kWth, Building Heating 

Tcond(i)=Tpcm + AT;
Tevap(i)= Tamb(i) - AT;

[COPH,COPC, Qhc] = VCHP();                                                 %Calling VC Heat Pump File
Qheat(i) = 0;                                                              %Unit: kWth, cooling load supplied to building
EPCM(i) =EPCM(i-1) - Qhc(i)*dt;                                            %Unit: kJ, Energy in PCM
SOC(i) = EPCM(i)/EPCMini  ;                                                %Range: 0 - 1 
COP (i) = COPH(i);                                                         %COP of System
Tindoor(i) = Tindoor(i-1) -(((Qheat(i) + Qbuilding(i))/Cbuild)*dt);        %Unit: °C, Indoor Temperature  %Unit: °C, Indoor Temperature
Pelec(i) = (Qhc(i)/ COP(i))/dt;                                            %Unit:kWhele, the electric power  




end

