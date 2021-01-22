function [Order,umbral_high,umbral_low] = WMcalibration(EV)  
WMbase;
countMyos=1;
m = MyoMex(countMyos);
m1 = m.myoData(1);
m1.timeEMG;
m1.emg;
m1.stopStreaming();
m.myoData.clearLogs();
m1.startStreaming();

runMYO=1;
counter=0;
aux=0;
set_emg=0;

%% VARIABLES -----------------------------------------
ventana=0.8;
rep_cal=20;
order=1;
sensor=1;
ref_sensor=1;
calibration_umbral=zeros(8,rep_cal);
calibration_reference=zeros(1,rep_cal);

for i=1:rep_cal
    %% EMG_1 get stream data
    timeEMG = m1.timeEMG_log;  
    
    if ~isempty(timeEMG)
        T_emg=timeEMG(:,1)>=(timeEMG(end,1)-ventana);
        emg = m1.emg_log(T_emg,:);
        umbral=Wsumenv(emg');
        calibration_umbral(:,i)=umbral;
        medias=mean(emg);            
        [~,sensor]= max(medias);    
        calibration_reference(i)=sensor;
       
    end
    pause(0.08);        

end

[times,sensor]=max(histc(calibration_reference,1:length(calibration_reference)));
clc
if times>(length(calibration_reference)/3)
    disp('Sistema sincronizado')
    ref_sensor=sensor;
    
else
    disp('Repita la sincronizacion')
    ref_sensor=32;
end

pause(3)
close all

       
%% EMG_1 Set sensor reference
 
    switch ref_sensor      
        case 1;order=1;
        case 2;order=2;
        case 3;order=3;
        case 4;order=4;
        case 5;order=5;
        case 6;order=6;
        case 7;order=7;
        case 8;order=8;           
        otherwise
            order=1;
    end

%% Calibartion umbral

calibration_umbral=calibration_umbral';
switch ref_sensor
    
    case 1
        calibration_umbral=calibration_umbral(:,[1,2,3,4,5,6,7,8]);
    case 2
        calibration_umbral=calibration_umbral(:,[2,3,4,5,6,7,8,1]);
    case 3
        calibration_umbral=calibration_umbral(:,[3,4,5,6,7,8,1,2]);
    case 4
        calibration_umbral=calibration_umbral(:,[4,5,6,7,8,1,2,3]);
    case 5
        calibration_umbral=calibration_umbral(:,[5,6,7,8,1,2,3,4]);
    case 6
        calibration_umbral=calibration_umbral(:,[6,7,8,1,2,3,4,5]);
    case 7
        calibration_umbral=calibration_umbral(:,[7,8,1,2,3,4,5,6]);
    case 8
        calibration_umbral=calibration_umbral(:,[8,1,2,3,4,5,6,7]);
        
    otherwise
end

    mean_umbral=calibration_umbral;
    mean_umbral=mean_umbral(end-15:end,:);
    mean_umbral=mean(mean_umbral);
    [val,pos]=max(mean_umbral);
    
    val_umbral_high = EV*sum(mean_umbral(1:4))/4; 
    val_umbral_low  = EV*sum(mean_umbral(5:8))/4; 
    

%% Close MYO    
m1.stopStreaming();   
m.myoData.clearLogs();
m.delete;  
%clear m               
%delete m m1
Order = order;
umbral_high=val_umbral_high;
umbral_low=val_umbral_low;

assignin('base','order',  order);
assignin('base','umbral_low',  umbral_low);
assignin('base','umbral_high', umbral_high);
clc
end

