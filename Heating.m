function [Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding,cost] = Heating()


global Tindoor  Qcool COP Pelec EPCM SOC ModePCM ModeVCS Qbuild EPCMini  Qbuilding i Qhc Tcond t_ws t_we dtw1 dtw2
global Tevap cost m Tindoorin Baseline Tdb TOU Tsph  Qheat  Qcool Ecost Time Tamb Tcost AT Tbal TPelec Pelec_peak Table  EPCMfin TCPMfinal DeltaE DeltaT

global TPelec_peak Tpcm TOUset clock Tcostbase Tpeakbase TPelecbase  paramTOU Tpcminit  x1 x2 x3 x4 x5 I Y Table2 

% Converting the Summer Start and End Time when TOU is zero
dtw1 =datetime(t_ws, 'Format', 'HH:mm:ss');                                % Start of TES Utilizing during winter
dtw2 =datetime(t_we, 'Format', 'HH:mm:ss');                                % End of TES Utilizing during winter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%Running the Baseline Case%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Baseline ==1
for i =1:m
if i==1
%Initization of Initial Point
Tindoor(i) = Tindoorin;            
Qbuild(i) = 0;                      
Qcool(i) = 0;
Qheat(i)=0;
COP(i) = 0;
Pelec(i)= 0;
EPCM(i)= 0;
SOC(i) =EPCM(i)/EPCMini;
ModePCM(i) = 0;
ModeVCS(i) = 0;
Tevap(i) = 0;
Tcond(i) =0;
Qhc(i)=0;
%Start of Condition 
elseif Tindoor(i-1) < Tsph-Tdb
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_h();     %Normal Operation Heating by VCS during baseline case   
elseif Tindoor (i-1) >= Tsph && Tbal < Tamb(i)
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_c(); 
else
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Standbyoperation_h();    %Normal Operation Heating by VCS during baseline case
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%Performance Calculation%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
Qheat(i)=0;
COP(i) = 0;
Pelec(i)= 0;
EPCM(i)= 0;
SOC(i) =EPCM(i)/EPCMini;
ModePCM(i) = 0;
ModeVCS(i) = 0;
Tevap(i) = 0;
Tcond(i) =0;
Qhc(i)=0;
%Start of Condition 
elseif Tindoor (i-1) <= Tsph-Tdb && TOU(i)>0 && SOC(i-1) < 1 
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Chargingoperation_h();   %Heating through PCM Charging  
elseif Tindoor(i-1) < Tsph-Tdb
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_h();     %Normal Operation Heating by VCS during baseline case  
elseif Tindoor(i-1) >= Tsph-Tdb &&Tindoor(i-1) <= Tsph+Tdb && TOU (i) <= 0 && SOC (i-1) >0                  
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Dischargingoperation_h();%Discharging of the PCM system   
elseif Tindoor (i-1) >= Tsph+Tdb && Tbal < Tamb(i)
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_c(); 
else
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Standbyoperation_h();    %Normal Operation Heating by VCS during baseline case
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%Performance Calculation%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:m
cost(i) = Pelec(i) *Ecost(i);
end
TPelec=sum(Pelec);
for i=1:m
if TOU(i) >0
    Pelec_peak(i)=Pelec(i);   
else
    Pelec_peak(i)=0;
end
end
TPelec_peak = sum(Pelec_peak);
Tcost=sum(cost);

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if paramTOU == 0
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
Qheat(i)=0;
COP(i) = 0;
Pelec(i)= 0;
EPCM(i)= 0;
SOC(i) =EPCM(i)/EPCMini;
ModePCM(i) = 0;
ModeVCS(i) = 0;
Tevap(i) = 0;
Tcond(i) =0;
Qhc(i)=0;
%Start of Condition 
elseif Tindoor (i-1) <= Tsph-Tdb && SOC(i-1) < 1  && clock(i) >dtw1 && clock(i) <dtw2 && Tpcm > Tamb(i)
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Chargingoperation_h();   %Heating through PCM Charging  
elseif Tindoor(i-1) >= Tsph-Tdb && Tindoor(i-1) <= Tsph+Tdb  && SOC (i-1) >0 && (clock(i)> dtw2 || clock(i) <dtw1)                  
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Dischargingoperation_h(); %Discharging of the PCM system   
elseif Tindoor(i-1) < Tsph-Tdb
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_h();     %Normal Operation Heating by VCS during baseline case  
elseif Tindoor (i-1) >= Tsph+Tdb && Tbal < Tamb(i)
[Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Normaloperation_c(); 
else
[Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding] = Standbyoperation_h();    %Normal Operation Heating by VCS during baseline case
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%Performance Calculation%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:m
cost(i) = Pelec(i) *Ecost(i);
end
TPelec=sum(Pelec);
for i=1:m
if TOU(i) >0
    Pelec_peak(i)=Pelec(i);   
else
    Pelec_peak(i)=0;
end
end
TPelec_peak = sum(Pelec_peak);
Tcost=sum(cost);
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

[M,I] = min(Table.Tcost);
[M,Y] = min(Table.TPelec);

Table2= table(Table.Tpcm(I), Table.EPCM(I),Table.Tpcm(Y),Table.EPCM(Y));
end



















% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%Plot Section%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure 
subplot (2,1,1)
plot(Time,Tindoor)
title('Daily Indoor Temperature')
ylabel('Temperature [°C]')
xlabel ('Date & Time')
% ylim([20 25])
% yticks (20:0.5:25)
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
% yticks (-1:1:1)
legend (' 1=Discharging ,-1=charging','Location','southeast')

figure 
subplot (2,1,1)
plot(Time,Pelec)
title('Electric Consumpation ')
ylabel('Electric Consumpation [kWh]')
% yticks (0:1:1)
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
% yticks (0:1:1)
xlabel ('Time [min]')
subplot (2,1,2)
plot(Time,EPCM)
title('PCM Storage Capacity')
ylabel('Energy [kJ]')
xlabel ('Date & Time')

end

    
    
    
    
    
    

        










       

    


