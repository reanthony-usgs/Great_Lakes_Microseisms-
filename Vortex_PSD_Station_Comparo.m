% This Script takes the Assembled and Aligned Meteorological and PSD
% datasets (Met_PSDs) and plots median PSDs under differing environmental
% conditions (e.g. Wind_Speed, Wave_Height).

% It loops through all years and makes a PSD file for just the Vortex Year
% and non-Vortex Years 


% Then in finds the median PSD for each when the wind exceeds some
% threshold. These PSDs for Vortex and non-vortex years are plotted as is
% the difference 

clear all 

% load in the data

dirroot='.';

% Set wind Speed Threshold (in m/s)

WS_thres = 3;

MetSta = 'IRQC';
network='IU';
station='T47';
cmp='BHZ';
locid='--';

years = [2012,2013,2014,2016,2017];


% Load in the data - Full dataset
%file = [MetSta,'_',network,station,locid,cmp,'.mat'];
%psdname=[dirroot,'/Met_PSDs/',file];
%load(psdname);

% load in the data - TA
file = [station,'.mat'];
psdname=[dirroot,'/TA_Met_PSDs/',file];
load(psdname);


load ./Full_PSDs/BH_Periods.mat

% Remove all NaNs and Inf

Met_PSD = Met_PSD(all(isfinite(Met_PSD(:,5)),2),:);

Smet_PSD = Met_PSD(1,:);

for jj=1:length(years)

    % Optionally Set the Start and End Dates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    start_date = [years(jj),2,28,0,0,0];
    start_date = datenum(start_date);

    end_date = [years(jj),3,24,0,0,0];
    end_date = datenum(end_date);

    %start_date = Met_PSD(2,1);
    %end_date = Met_PSD(end-1,1);

    SI = find(Met_PSD(:,1) >= start_date,1,'first');
    EI = find(Met_PSD(:,1) >= end_date,1,'first');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Cut Down to dates of interest 
    
    
    if years(jj) == 2014
        
        Vortex_PSD = Met_PSD(SI:EI,:);
        
    else
        
        TMet_PSD = Met_PSD(SI:EI,:);
        
        Smet_PSD = [Smet_PSD; TMet_PSD];
        
    end
    
end

% Now, we have Met_PSDs for the two time periods of interst. Compute the
% median PSDS for a given wind speed and plot. 


PSD_Vortex = Vortex_PSD(:,8:end)';
metdata_Vortex=Vortex_PSD(:,2:7);


PSDs=Smet_PSD(:,8:end)';
metdata=Smet_PSD(:,2:7);

    
MI = find(metdata(:,4)*0.51444 >= WS_thres & metdata(:,4)*0.51444 < 100 );
MI_V = find(metdata_Vortex(:,4)*0.51444 >= WS_thres & metdata_Vortex(:,4)*0.51444 < 100 );


Moderate_PSD = nanmedian(PSDs(:,MI),2);
Moderate_PSD_V = nanmedian(PSD_Vortex(:,MI_V),2);

PSD_Difference = Moderate_PSD - Moderate_PSD_V;

% Make the Plots


Period_lines =  [0.1, 0.2, 0.3, 0.5, 1, 2,3,5,10,20];
ticks = (Period_lines);


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

figure(10);clf 

H1 = semilogx(Periods,Moderate_PSD_V,'b');
hold on
H2 = semilogx(Periods,Moderate_PSD,'r');
H3 = semilogx(pd1,LNMA,'k:');

H4 = semilogx(pd2,HNMA,'k:');
%H5 = semilogx(log10(Periods),Calm_PSD,'b');
%H6 = semilogx(log10(Periods),Wind_PSD,'r');
%legend('High Discharge Median','Low Discharge Median')

set(gca,'FontSize',30)
xlim([0.06 30])
ylim([-170 -110])
set(gca,'ydir','normal')

set(H3,'LineWidth',3.0);
set(H4,'LineWidth',3.0);
set(H1,'LineWidth',3.0);
set(H2,'LineWidth',3.0);

set(gca,'xtick',ticks)
set(gca,'Xticklabel',Period_lines)
set(gca,'xdir','normal')

xlabel('Period (s)')
ylabel('dB (rel. 1 (m/s^2)^2/Hz)')
legend('2014 Polar Vortex', 'Non-Frozen Years')


% Save the Output 

save(['./Vortex_Months_Median_IRQC/Normal_',station,'.mat'],'Moderate_PSD');
save(['./Vortex_Months_Median_IRQC/Vortex_',station,'.mat'],'Moderate_PSD_V');
save(['./Vortex_Months_Median_IRQC/Difference_',station,'.mat'],'PSD_Difference');

% Format for Adam

Adam = [Periods, Moderate_PSD, Moderate_PSD_V, PSD_Difference];

save(['./For_Adam/',station,'.txt'],'Adam','-ascii');


    
    
    

   