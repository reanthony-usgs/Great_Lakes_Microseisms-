% This Script takes the wind data from a local meteorologvical station located in the Great
% Lakes and aligns it with seismic data from the T4 network (TA/N4
% stations). Both data has been prepared for alignment by running through
% previous scripts that fill data gaps with NaNs 


clear all

% load in the data 

dirroot='.';

% load in the meteorolical data 

load([dirroot,'/Full_Met/Point_Iroquois_Circ.mat']);


%station={'E43','F42','G40','H43','I40','I42','I49','J47','J54','J55','J57','J59','K43','K50','K57','L40','L42','L48','L56','M44','M50','M55','M57','N41','N47','N49','N51','N58','O49','O52','O54','P43','P46','P48','P51','P53','Q51','Q52','Q54','R49','R50','R53','N53'};

station = {'IUWCI10BHZ'};

for kk=1:length(station)


psdname=[dirroot,'/Full_PSDs/',station{kk},'.mat'];
load(psdname)

%For PSDs that start before 2012

%start_date = datenum(2012,1,1);

%SI = find(PSD_Full(:,1) == start_date, 1, 'first');


PSD_Full = PSD_Full(1:end-8,:);




% Find when the start times align (asumes seismic data may start later than
% met data) 

Smet_I = find(PSD_Full(1,1) == Met_Full(:,1)); 

% Find when the End times align (asumes seismic data end earlier than
% met data) 

Emet_I = find(PSD_Full(end,1) == Met_Full(:,1)); 

% Cut down the Met data 

AMet = Met_Full(Smet_I:Emet_I,:); 

% Do the Alignment, and Save 

Met_PSD = [AMet, PSD_Full(:,2:end)];

 save(['./TA_Met_PSDs/',station{kk},'.mat'],'Met_PSD');

station{kk}
start_disp = datevec(Met_PSD(1,1))
end_disp = datevec(Met_PSD(end,1))



end


