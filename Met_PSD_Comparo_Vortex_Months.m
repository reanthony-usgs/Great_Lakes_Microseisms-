% This Script takes the Assembled and Aligned Meteorological and PSD
% datasets (Met_PSDs) and plots median PSDs under differing wind speeds for
% just the months around the Polar Vortex Lake Freeze for non-Vortex
% Years.These PSDs have been previously windowed to only contain the
% calander time period around the FTP.


% The Output is then used to compare to the Frozen Lake PSD


clear all 

% load in the data

dirroot='.';


station='ECSD';
cmp='BHZ';
Start_Year = 2012;
End_Year = 2017;

% Select Percentiles 




% Load in the data
file = [station,cmp,'_All.mat'];
psdname=[dirroot,'/Non_Vortex_Years/',station,'/',file];
load(psdname);

load ./Full_PSDs/BH_Periods.mat

% Remove all NaNs and Inf

Met_PSD = Smet_PSD(all(isfinite(Smet_PSD(:,5)),2),:);


% Optionally Set the Start and End Dates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_date = [Start_Year,2,28,0,0,0];
start_date = datenum(start_date);

end_date = [End_Year,3,24,0,0,0];
end_date = datenum(end_date);

%start_date = Met_PSD(2,1);
%end_date = Met_PSD(end-1,1);

SI = find(Met_PSD(:,1) >= start_date,1,'first');
EI = find(Met_PSD(:,1) >= end_date,1,'first');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cut Down to dates of interest 

PSDs=Met_PSD(SI:EI,8:end)';
metdata=Met_PSD(SI:EI,2:7);
dates=Met_PSD(SI:EI,1);

% Truncated Meteorological PSD
TMet_PSD = Met_PSD(SI:EI,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define Calm Periods (Wind_Speed < 2 m/s) 

CI = find(metdata(:,4)*0.51444 >= 0 &metdata(:,4)*0.51444 < 3 ); 
Calm_PSD = nanmedian(PSDs(:,CI),2);

% Define Moderate Winds (Wind Speed 3 - 8 m/s)

MI = find(metdata(:,4)*0.51444 >= 3 &metdata(:,4)*0.51444 < 100 ); 
Moderate_PSD = nanmedian(PSDs(:,MI),2);

% Define Windy Periods (Wind_Speed > 10 m/s) 

WI = find(metdata(:,4)*0.51444 > 7); 
Wind_PSD = nanmedian(PSDs(:,WI),2);


%% Make the figure
Hz_lines = [15,10,5,3,1,0.5,0.2,0.1,0.05];

ticks = (1./Hz_lines);
HZ_label = (1./ticks);

%Make the Peterson curves
fs=250;
dlP=.05;
PSDTOL=15;
[LNMA,HNMA,lpd1,lpd2]=peterson_acc(dlP,fs);

%Smoothed Peterson curves for plotting
NMplotind=(0.001:dlP:10);
LNMAp=spline(lpd1,LNMA,NMplotind);
HNMAp=spline(lpd2,HNMA,NMplotind);

pd1 = 10.^(lpd1);
pd2 = 10.^(lpd2);

figure(55);clf 

H1 = semilogx(Periods,Calm_PSD,'b');
hold on
H2 = semilogx(Periods,Wind_PSD,'r');
H5 = semilogx(Periods,Moderate_PSD,'g');
H3 = semilogx(pd1,LNMA,'k:');

H4 = semilogx(pd2,HNMA,'k:');
%H5 = semilogx(log10(Periods),Calm_PSD,'b');
%H6 = semilogx(log10(Periods),Wind_PSD,'r');
%legend('High Discharge Median','Low Discharge Median')

set(gca,'FontSize',30)
xlim([0.06 30])
ylim([-180 -90])
set(gca,'ydir','normal')

set(H5,'LineWidth',3.0);
set(H4,'LineWidth',3.0);
set(H3,'LineWidth',3.0);
set(H1,'LineWidth',3.0);
set(H2,'LineWidth',3.0);

set(gca,'xtick',ticks)
set(gca,'Xticklabel',HZ_label)
set(gca,'xdir','reverse')

xlabel('Frequency (Hz)')
ylabel('dB (rel. 1 (m/s^2)^2/Hz)')
