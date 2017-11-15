% This Script Takes the Aligned Fluvial and Seismic/Infrasound Metrics and
% Plots the Spectrogram and Discharge Measurements on the same Plot 

clear all

% load in the data

dirroot='.';

MetSta = 'CWS';
network='T4';
station='D41A';
cmp='BHZ';
locid='--';


% Load in the data
file = [MetSta,'_',network,station,locid,cmp,'.mat'];
psdname=[dirroot,'/Buoy_Data/',file];
load(psdname);

load ./Full_PSDs/BH_Periods.mat

% Optionally Set the Start and End Dates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_date = [2013,4,1,0,0,0];
start_date = datenum(start_date);

end_date = [2013,4,30,0,0,0];
end_date = datenum(end_date);

%start_date = Met_PSD(1,1);
%end_date = Met_PSD(end,1);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SI = find(Buoy_PSD(:,1) >= start_date,1,'first');
EI = find(Buoy_PSD(:,1) >= end_date,1,'first');

PSDs=Buoy_PSD(SI:EI,11:end)';
rivdata=Buoy_PSD(SI:EI,2:10);
dates=Buoy_PSD(SI:EI,1);
ticks = (start_date:2:end_date);

% Replace 0 wind speed values with 0.5 for plotting 
Calm_I = find(rivdata(:,4) < 1.0); 
rivdata(Calm_I,4) = 1.0;


%% make the figure

day_vec = (start_date:1:end_date);



% Make the Y-Axis Tick Labels in 
Period_lines =  [0.1, 0.2, 0.3, 0.5, 1, 2,3,5,10,20];
ticks = log10(Period_lines);


fignum = '14'
figure(str2num(fignum)); clf

uimagesc(dates, log10(Periods), PSDs)
colormap(jet);
h=colorbar
ax = gca;
%c = ax.Color;
ax.LineWidth = 3;
datetick('x',7)
ylim([-1.18 1.5])
xlim([start_date end_date])
ylabel('Period (s)' ,'fontsize',24)
xlabel('Day of April 2013', 'fontsize',24);
%caxis([-160 -80])
%caxis([-60 30])
caxis([-160 -115])
set(gca,'ytick',ticks)
set(gca,'Yticklabel',Period_lines)
set(gca,'ydir','normal')
set(gca,'FontSize',20)

hold on
plot(dates,1*(log10((rivdata(:,9)))),'w-','linewidth',5);

yyaxis right 
plot(dates,.3048*rivdata(:,8),'k-','linewidth',7);
ylabel('Significant Wave Ht (m)')
ylim([0 4])
set(gca,'ycolor','k')


%plot(day_vec,log10(1/45)*ones(length(day_vec),1),'w--','linewidth',1);
%plot(day_vec,log10(1/30)*ones(length(day_vec),1),'w--','linewidth',1);

%plot(day_vec,log10(1/12)*ones(length(day_vec),1),'w--','linewidth',1);
%plot(day_vec,log10(1/22)*ones(length(day_vec),1),'w--','linewidth',1);

%plot(day_vec,log10(1/0.333)*ones(length(day_vec),1),'w--','linewidth',1);
%plot(day_vec,log10(1/2)*ones(length(day_vec),1),'w--','linewidth',1);
%plot(dates,log10(1./4*ones(length(dates),1)),'k-','linewidth',2);
%ylabel(hAx(2),'Discharge (CMS)') % right y-axis
%set(get(h,'title'),'string','dB','fontsize',28);
%title({station,'Sensor 2'})

