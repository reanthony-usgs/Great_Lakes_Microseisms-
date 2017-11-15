% This script takes the Full Met_PSDs from two stations, aligns the
% stations and returns the difference PSD PDF for them. As well as median
% difference PSD for different wind speeds
clear all

% load in the desired PSD

dirroot='.';

MetSta = 'IRQC';
network='T4';
station='D41A';
cmp='BHZ';
locid='--';



% Load in the data for D41A
file = [MetSta,'_',network,station,locid,cmp,'.mat'];
psdname=[dirroot,'/Met_PSDs/',file];
load(psdname);

D41A = Met_PSD;

% remove extra data
D41A(1:4,:) = [];


MetSta = 'IRQC';
network='IU';
station='WCI';
cmp='BHZ';
locid='10';



% Load in the data for WCI
file = [MetSta,'_',network,station,locid,cmp,'.mat'];
psdname=[dirroot,'/Met_PSDs/',file];
load(psdname);

WCI = Met_PSD;

% Load in the D41A FTP Difference PSD (Figure 2b)
network='TA';
station4 = 'D41A'; % Kewena Peninsula 
cmp='BHZ';
locid='--';


% Load in the data for the Vortex
file = [network,station4,locid,cmp,'.mat'];
psdname=[dirroot,'/Vortex_Months_Median_PSDs/',file];
load(psdname);

V_PSD_Key = Moderate_PSD;


% Load in the data for all Non-vortex years 
file = ['N',network,station4,locid,cmp,'.mat'];
psdname=[dirroot,'/Vortex_Months_Median_PSDs/',file];
load(psdname);

NV_PSD_Key = Moderate_PSD;

FTP_Diff = NV_PSD_Key - V_PSD_Key;


% Get the difference PSD for WCI and D41A

Diff_PSD = D41A(:,8:end) - WCI(:,8:end);

Diff_PSD = Diff_PSD(all(isfinite(Diff_PSD),2),:);

WCI = WCI(all(isfinite(Diff_PSD),2),:);

% get period information 
load ./Full_PSDs/BH_Periods.mat

periods = Periods;
b = length(periods);



% get the median PSDs at different wind speed thresholds

% less than 3 m/s
LWI = find(WCI(:,5)*0.51444 <= 3 & WCI(:,5)*0.5144 >= 0);

% 3-7 m/s
MWI = find(WCI(:,5)*0.51444 <= 7 & WCI(:,5)*0.5144 >= 3);

%> 15
HWI = find(WCI(:,5)*0.51444 <= 100 & WCI(:,5)*0.5144 >= 15);



LW_PSD = median(Diff_PSD(LWI,:));
MW_PSD = median(Diff_PSD(MWI,:));
HW_PSD = median(Diff_PSD(HWI,:));



% Rearrange into a 2 column matrix - column 1 period, column2 value of
% difference

% Column 2 is easy to make by reshaping the matrix
Diff_Col = reshape(Diff_PSD,size(Diff_PSD,1)*size(Diff_PSD,2),1);

% Periods are a bit trickier 
PV = zeros(size(Diff_PSD,1)*size(Diff_PSD,2),1);

for n = 1:length(periods)
    
    PV((n-1)*size(Diff_PSD,1)+1:n*size(Diff_PSD,1)) = periods(n);
end


chart = [PV,Diff_Col];

counts = hist3(chart, {periods -30:1:30});

histcent = [-30:1:30];




%for jj=1:b
%   median_P(jj) = median(PSD(jj:b:length(PSD),8));
%   p5th_P(jj) = prctile(PSD(jj:b:length(PSD),8),5);
%   p95th_P(jj) = prctile(PSD(jj:b:length(PSD),8),95);
%end

%% Make the figure
%Hz_lines = [10,5,3,1,0.5,0.2,0.1,0.05,0.01];

%ticks = log10(1./Hz_lines);
%HZ_label = (1./10.^(ticks));


% Make the Y-Axis Tick Labels in 
Period_lines =  [0.1, 0.2, 0.5, 1, 2,3,5,10,30];
ticks = log10(Period_lines);




figure(30); clf
%bookfonts
set(gca,'FontSize',30)
imagesc(log10(periods),histcent,log10(filter2(ones(1,1)/1,counts')))
colormap(jet);
c=colorbar
pminplot=3;
xlim(log10([0.06 20]))
ylim([-20 30])
%caxis([0 5])
set(gca,'ydir','normal')
set(c,'Fontsize',30)

xlabel('Period (s)')
ylabel('Difference (dB)')
ylabel(c,'log_{10}(Counts)') 
ax = gca;
%c = ax.Color;
ax.LineWidth = 3;


hold on
%H2 = semilogx(lpd1,LNMA,'w:');
%H3 = semilogx(lpd2,HNMA,'w:');
%H1 = semilogx(log10(periods),LW_PSD,'k');
H2 = semilogx(log10(periods),MW_PSD,'w');
H3 = semilogx(log10(periods),HW_PSD,'k');
H4 = semilogx(log10(periods),FTP_Diff,'m');

%legend('3-7 m/s Wind','> 12 m/s Wind')


%set(H2,'LineWidth',5.0);
%set(H3,'LineWidth',5.0);
%set(H1,'LineWidth',1.0);
set(H2,'LineWidth',3.0);
set(H3,'LineWidth',5.0);
set(H4,'LineWidth',5.0);

set(gca,'xtick',ticks)
set(gca,'Xticklabel',Period_lines)
%set(gca,'xdir','reverse')
set(gca,'FontSize',30)

%title([station, ' ', cmp, ' PSD PDF']);