clear all
close all
clc
format short g
datetime.setDefaultFormats('default','MM/dd/yyyy HH:mm:ss')


%%%Updates List%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Version 1,06092020,NK, Start of Program and Weekly Model
%Version 2,06152020,NK, Incorprated heating cycle and also monthly analysis
%Version3, 06222020,NK, Incorporated Non-TOU configuration 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Declare Global Variables
global Tindoor Cbuild Qcool COP Pelec EPCM SOC ModePCM ModeVCS Qbuild EPCMini dt Tamb Qbuilding i Qhc COPH COPC Tchange UA Ubuild
global Tpcm AT cost Tbal Tspc m Tindoorin Baseline TOU Time Ecost Tdb Tcost Tsph Qheat SOCini Tamb_ave TOUset TPelec  TPelecold M EPCMfin TCPMfinal DeltaE DeltaT
global TPelec_peak Pelec_peak  dts1 dts2 t_ss t_se clock t_ws t_we dtw1 dtw2 Tcond Tevap Tcostbase Tpeakbase TPelecbase paramTOU Table Tpcminit P1 x1 x2 x3 x4 x5 Table2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%user Input for the Program%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read input ambient temperature and TOU file
dirListing =dir('Arizona Monthly TOU TMY');
[num,txt,raw] = xlsread ('Arizona Monthly TOU TMY\April.xlsx') ;                                %Upload the data file

%Intial Conditions and Set-points 
Tindoorin = 18;                                                            %Unit: °C. Intial indoor temperature
Tspc = 23;                                                                 %Unit: °C. Cooling set-point during summer
Tsph = 20;                                                                 %Unit: °C. Heating set-point during winter
UA=0.11;                                                                   %UA of the building
Cbuild = 658.388;                                                          %Unit: kJ/K. Thermal Capacitance of Building
Tdb=0.5;                                                                   %Unit: °C. Deadband 
Tpcminit=45;                                                                %Unit: °C. Melting temperature of PCM 
Tbal=15;
EPCMini=20000;                                                             %Unit: kJ. Total Energy of PCM
dt = 60;                                                                   %Unit: s. Timestep of raw data in minutes
AT = 5;                                                                    %Unit: °C, Approach Temperature
SOCini =0;
Ubuild = 0.208405336*1.25;

%The Control Arm for different operation
Baseline =1;                                                               %Binary 0 and 1. 0 TES, 1 Baseline                                                            
paramTOU=1;   

% Run the parametric study for varying PCM temperature and Energy
% If TOU equates to zero, please set this parameters
t_ss = '11:00:00' ;                                                        % t_ss is the summer start time for PCM utiliziation in a 24-hr clock format
t_se = '20:00:00' ;                                                        % t_se is the summer end time for PCM utiliziation in a 24-hr clock format

t_ws = '15:00:00' ;                                                        % t_ws is the winter start time for PCM utilization in a 24-hr clock format
t_we ='23:59:00' ;                                                         % t_we is the winter end time for PCM utilization in a 24-hr clock format

EPCMfin =20000;
TCPMfinal = 45;
DeltaE=20000;
DeltaT=20;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%DO NOT EDIT BEYOND THIS POINT%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%WITHOUT CREATING NEW VERSION%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%% Start of Model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initization of the uploaded Data
[m,n] = size(num);
%m=round(m/31);

for x=1:m
   Time(x) = num(x,1);                                                     %Creating a Time array from the raw data
   Tamb(x) = num(x,4);                                                     %Creating a Temperature ambient array from the raw data
   TOU(x) = num(x,5);                                                      %Creating a TOU Array from the raw data 
   Ecost(x) = num(x,6); 
end

                                                                      
Time =datetime(Time+693960,'ConvertFrom','datenum');                       % Creating the Date and Time for the TMY Data  


Tamb_ave=movmean(Tamb,1440);                                               % Moving Average of the ambient temperature
Tambave=mean(Tamb);                                                        % Mean of monthly temperature


% Converting date and time for daily clock 
Time.Format = 'HH:mm:ss';
clock = cellstr(Time);   
clock =datetime(clock, 'Format', 'HH:mm:ss'); 


% Condition for Heating or Cooling
 if Tambave >= Tspc-2                                                       
  [Qcool,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding,cost] = Cooling();  %Calls cooling performance
  Cooling=1;
else
  [Qheat,SOC,COP,Tindoor,EPCM,ModePCM,ModeVCS,Qbuilding,cost] = Heating();  % Calls heating performance
  Heating=1;
end