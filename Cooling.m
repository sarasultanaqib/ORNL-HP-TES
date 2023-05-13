function [Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding,cost] = Cooling()


global Tindoor  Qcool COP Pelec EPCM SOC ModePCM ModeVCS Qbuild EPCMini  Tamb Qbuilding i 
global Qhc Tcond Tevap cost Tspc m Tindoorin Baseline Tdb TOU Time Ecost Tcost  Qheat TPelec Tchange TPelecold Tcostold paramTOU Table EPCMfin TCPMfinal DeltaE DeltaT
global Pelec_peak TPelec_peak Tbal TOUset Tpcm dts1 dts2 t_ss t_se clock Tcostbase Tpeakbase TPelecbase TPeakold Tchange1 Tchange2 Tchange3 Tpcminit Table2

%Converting the Summer Start and End Time when TOU is zero
dts1 =datetime(t_ss, 'Format', 'HH:mm:ss');                                % Start of TES Utilizing during summer                               
dts2 =datetime(t_se, 'Format', 'HH:mm:ss');                                % End of Tes Utilizing during summer


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%Running the Baseline Case%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Baseline ==1
    wb = waitbar(0,'elapsed');
for i =1:m
    waitbar(i/m,'elapsed')
if i==1
%Initization of Initial Point
Tindoor(i) = Tindoorin;            
Qbuild(i) = 0;                      
Qcool(i) = 0;                   
COP(i) = 0;
Pelec(i)= 0;
EPCM(i)= EPCMini;
SOC(i) =1;
ModePCM(i) = 0;
ModeVCS(i) = 0;
Tevap(i) = 0;
Tcond(i) =0;
Qhc(i)=0;
%Start of Condition 
elseif  Tindoor (i-1) >= Tspc+Tdb
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_c();       %Normal Operation Cooling by VCS during baseline case
elseif Tindoor (i-1) <=Tspc+Tdb  && Tbal > Tamb(i)
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_h();       %Normal Operation Cooling by VCS during baseline case
else 
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Standbyoperation_c();      % Standby Mode
end 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%Performance Calculation%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:m
cost(i) = Pelec(i) *Ecost(i);
end
Tcostbase=sum(cost);
TPelecbase=sum(Pelec);
for i=1:m
if TOU(i) >0
    Pelec_peak(i)=Pelec(i); 
else
    Pelec_peak(i)=0;
end
end
Tpeakbase = sum(Pelec_peak);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%Running the TOU Case%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if paramTOU==1     
iter =0;
 while EPCMini <EPCMfin
       Tpcm =Tpcminit;
   while Tpcm < TCPMfinal
    for i =1:m
if i==1
%Initization of Initial Point
Tindoor(i) = Tindoorin;            
Qbuild(i) = 0;                      
Qcool(i) = 0;                   
COP(i) = 0;
Pelec(i)= 0;
EPCM(i)= EPCMini;
SOC(i) =1;
ModePCM(i) = 0;
ModeVCS(i) = 0;
Tevap(i) = 0;
Tcond(i) =0;
Qhc(i)=0;
%Start of Condition for city's with TOU rating
elseif Tindoor (i-1) >= Tspc+Tdb && TOU(i)> 0 && SOC(i-1) > 0
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Dischargingoperation_c();  %Cooling through PCM discharging  
elseif Tindoor (i-1) <=Tspc-Tdb && Tbal > Tamb(i)
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_h();       %Normal Operation Heating during schedule month
elseif Tindoor(i-1) <= Tspc+Tdb  && TOU(i) == 0 && SOC (i-1) < 1      
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Chargingoperation_c();     % Charging of the PCM system
elseif Tindoor (i-1) >= Tspc+Tdb                                    
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_c();       %Normal Operation Cooling by VCS   
else
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Standbyoperation_c();      % Standby Mode
end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%Performance Calculation%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:m
cost(i) = Pelec(i) *Ecost(i);
end
Tcost=sum(cost);
TPelec=sum(Pelec);
for i=1:m
if TOU(i) >0
    Pelec_peak(i)=Pelec(i); 
else
    Pelec_peak(i)=0;
end
end
TPelec_peak = sum(Pelec_peak);
Tpcmold=Tpcm;
Tpcm=Tpcmold+DeltaT;
iter=iter+1;
x1(iter)= Tpcm;
x2(iter)=Tcost;
x3(iter)=TPelec;
x4(iter)=TPelec_peak;
x5(iter)=EPCMini;
   end
EPCMold=EPCMini;
EPCMini=EPCMold+DeltaE; 
 end

Table=table(x1.',x5.', x2.',x3.',x4');   
Table.Properties.VariableNames = {'Tpcm', 'EPCM','Tcost','TPelec','TPelec_peak'};

[M,I] = min(Table.Tcost)
[M,Y] = min(Table.TPelec)

Table2= table(Table.Tpcm(I), Table.EPCM(I),Table.Tpcm(Y),Table.EPCM(Y));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%Running the Non-TOU Case%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if paramTOU==0 
iter =0;
 while EPCMini <EPCMfin
       Tpcm =Tpcminit;
   while Tpcm < TCPMfinal
    for i =1:m
if i==1
%Initization of Initial Point
Tindoor(i) = Tindoorin;            
Qbuild(i) = 0;                      
Qcool(i) = 0;                   
COP(i) = 0;
Pelec(i)= 0;
EPCM(i)= EPCMini;
SOC(i) =1;
ModePCM(i) = 0;
ModeVCS(i) = 0;
Tevap(i) = 0;
Tcond(i) =0;
Qhc(i)=0;    
%Start of Condition for city's without TOU condition
elseif Tindoor (i-1) >= Tspc+Tdb && SOC (i-1) > 0 && clock(i) > dts1 && clock(i) < dts2 && Tpcm < Tamb(i)
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Dischargingoperation_c();  %Cooling through PCM discharging  
elseif Tindoor (i-1) <=Tspc-Tdb && Tbal > Tamb(i)
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_h();       %Normal Operation Heating during schedule month
elseif Tindoor (i-1) <= Tspc+Tdb && SOC (i-1) <= 1 && (clock(i)> dts2 || clock(i) <dts1)
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Chargingoperation_c();     % Charging of the PCM system
elseif Tindoor (i-1) >= Tspc+Tdb                                    
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_c();       %Normal Operation Cooling by VCS   
else
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Standbyoperation_c();      % Standby Mode   
end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%Performance Calculation%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:m
cost(i) = Pelec(i) *Ecost(i);
end
Tcost=sum(cost);
TPelec=sum(Pelec);
for i=1:m
if TOU(i) >0
    Pelec_peak(i)=Pelec(i); 
else
    Pelec_peak(i)=0;
end
end
TPelec_peak = sum(Pelec_peak);

Tpcmold=Tpcm;
Tpcm=Tpcmold+DeltaT;
iter=iter+1;
x1(iter)= Tpcm;
x2(iter)=Tcost;
x3(iter)=TPelec;
x4(iter)=TPelec_peak;
x5(iter)=EPCMini;
   end
EPCMold=EPCMini;
EPCMini=EPCMold+DeltaE; 
 end
   


Table=table(x1.',x5.', x2.',x3.',x4');   
Table.Properties.VariableNames = {'Tpcm', 'EPCM','Tcost','TPelec','TPelec_peak'};
[M,I] = min(Table.Tcost)
[M,Y] = min(Table.TPelec)
Table2= table(Table.Tpcm(I), Table.EPCM(I),Table.Tpcm(Y),Table.EPCM(Y));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%Plot Section%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close(wb)
figure 
subplot (2,1,1)
plot(Time,Tindoor)
title('Daily Indoor Temperature')
ylabel('Temperature [°C]')
xlabel ('Date & Time')
ylim([20 25])
yticks (20:0.5:25)
subplot (2,1,2)
plot(Time,Tamb)
title('Ambient Temperature')
ylabel('Temperature [°C]')
xlabel ('Date & Time')

figure 
subplot (2,1,1)
plot(Time,ModeVCS)
title('Mode of Operation')
ylabel(' Operation Mode [0-3]')
xlabel ('Date & Time')
legend ('0=Standby 1=Normal,2=charging,3=Discharging','Location','southeast')
subplot (2,1,2)
plot(Time,ModePCM)
title('Mode of PCM')
ylabel('PCM Mode [-1,1]')
xlabel ('Date & Time')
yticks (-1:1:1)
legend (' 1=Discharging ,-1=charging','Location','southeast')

figure 
subplot (2,1,1)
plot(Time,Pelec)
title('Electric Consumpation ')
ylabel('Electric Consumpation [kWh]')
%yticks (0:1:1)
xlabel ('Time [min]')
subplot (2,1,2)
plot(Time,cost)
title('Cost of Electricity')
ylabel('Cost [Cents]')
xlabel ('Date & Time')
  
figure 
subplot (2,1,1)
plot(Time,SOC)
title('PCM State of Charge')
ylabel('SOC [0-1]')
%yticks (0:1:1)
xlabel ('Time [min]')
subplot (2,1,2)
plot(Time,EPCM)
title('PCM Storage Capacity')
ylabel('Energy [kJ]')
xlabel ('Date & Time')















end
    
    
    
    
    

        










       

    
