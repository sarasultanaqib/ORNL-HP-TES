function [Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Dischargingoperation_c()
global Tindoor Cbuild Qcool COP Pelec EPCM SOC ModePCM ModeVCS dt Tamb i Qbuilding EPCMini Tpcm AT COPC COPH Qhc Tcond Tevap Tbal UA
%%%Updates List%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Version 1,06092020,NK, Fixed Qevap and COP. NOTES: Change to EES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ModePCM(i) = 1;                                                            %Mode of PCM Operation
ModeVCS(i) = 3 ;                                                           %Mode of VCS Operation
Qbuilding(i) = 0.26050667 *(Tamb(i) - Tbal);                               %Unit: kWth, Building Heating 


Tcond(i)= Tpcm + AT;
Tevap(i)= Tindoor(i-1)-AT;

if Tcond(i) < Tevap(i);                                                    % If Condenser Temperature is below the evaporator temperature, only direct cooling is provided

Tevap(i)= Tindoor(i-1)-AT;
Tcond(i)=Tevap(i) +2 ;                                                     %Assuming the temperature lift in VC is only 2K, therefore we would accept high COP. This model needs to be improved in the future. Also to achieve this temperature our condenser approach temperature will be high in the range of 10 to 20C            
[COPH,COPC, Qhc] = VCHP();                                                 %Calling VC Heat Pump File                                                      
Qcool(i) = Qhc(i);                                                         %Unit: kWth, cooling load supplied to building
EPCM(i) =EPCM(i-1) - Qhc(i)*dt;                                            %Unit: kJ, Energy in PCM
SOC(i) = EPCM(i)/EPCMini ;                                                 %Range: 0 - 1 
COP (i) =  COPC(i);                                                        %COP of System
Tindoor (i) = Tindoor(i-1)-(((Qcool(i)-Qbuilding(i))/Cbuild)*dt);          %Unit: °C, Indoor Temperature
Pelec(i) =    (Qcool(i)/COP(i))/dt;                                        %Unit:kWhele, the electric power. When the Condenser temperature (Low temperature PCM heat sink) is below the evaporator temperature, the HP is technically not doing any work 

else                                                                       %PCM acts like a heat sink, reduced temperature for the condenser
Tcond(i)= Tpcm + AT;                                
Tevap(i)= Tindoor(i-1)-AT;
[COPH,COPC, Qhc] = VCHP();                                                 %Calling VC Heat Pump File                                                      
Qcool(i) = Qhc(i);                                                         %Unit: kWth, cooling load supplied to building
EPCM(i) =EPCM(i-1) - Qhc(i)*dt;                                            %Unit: kJ, Energy in PCM
SOC(i) = EPCM(i)/EPCMini  ;                                                %Range: 0 - 1 
COP (i) =  COPC(i);                                                        %COP of System
Tindoor (i) = Tindoor(i-1)-(((Qcool(i)-Qbuilding(i))/Cbuild)*dt);          %Unit: °C, Indoor Temperature
Pelec(i) =  (Qcool(i)/COP(i))/dt;                                          %Unit:kWhele, the electric power.                                            
end

end

