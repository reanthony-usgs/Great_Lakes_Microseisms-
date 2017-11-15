% This script Compares integrated velocity power in a given band with wind
% direction given and wind speed

clear all 

% load in the data

dirroot='.';

% Station - C means circular averages for wind direction 
MetSta = 'BeaverC';
network='TA';
station='F45A';
cmp='BHZ';
locid='--';




% Load in the data
file = [MetSta,'_',network,station,locid,cmp,'.mat'];
psdname=[dirroot,'/Met_PSDs/',file];
load(psdname);

load ./Full_PSDs/BH_Periods.mat

% Remove all NaNs and Inf

Met_PSD = Met_PSD(all(isfinite(Met_PSD),2),:);


% Optionally Set the Start and End Dates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start_date = [2017,2,28,0,0,0];
%start_date = datenum(start_date);

%end_date = [2017,3,24,0,0,0];
%end_date = datenum(end_date);

start_date = Met_PSD(2,1);
end_date = Met_PSD(end-1,1);

SI = find(Met_PSD(:,1) >= start_date,1,'first');
EI = find(Met_PSD(:,1) >= end_date,1,'first');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cut Down to dates of interest 

PSDs=Met_PSD(SI:EI,9:end)';
metdata=Met_PSD(SI:EI,2:8);
dates=Met_PSD(SI:EI,1);

% Truncated Meteorological PSD
TMet_PSD = Met_PSD(SI:EI,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Integrate total power in frequency band of interest 
% look at the data file to find the location of the frequency bin of
% interest

sHbin = find(Periods > 0.2,1,'first');
sMbin = find(Periods > (1/3),1,'first');
sLbin = find(Periods > (2),1,'first');


%b1 = sHbin; b2 = sHbin+1; b3 = sHbin+2; b4 = sHbin+3; b5 = sHbin+4; b6 = sHbin+5; b7 = sHbin+6; b8 = sHbin+7; b9 = sHbin+8; b10 = sHbin+9; b11 = sHbin+10; b12 = sHbin+11; b13 = sHbin+12; disp('local wind microseism'); band = 'Local Wind Microseism Band (1-3 Hz)'
b1 = sMbin; b2 = sMbin+1; b3 = sMbin+2; b4 = sMbin+3; b5 = sMbin+4; b6 = sMbin+5; b7 = sMbin+6; b8 = sMbin+7; b9 = sMbin+8; b10 = sMbin+9; b11 = sMbin+10; b12 = sMbin+11; b13 = sMbin+12; disp('local wind microseism'); band = 'Local Wind Microseism Band (1-3 Hz)'
%b1 = sLbin; b2 = sLbin+1; b3 = sLbin+2; b4 = sLbin+3; b5 = sLbin+4; b6 = sLbin+5; b7 = sLbin+6; b8 = sLbin+7; b9 = sLbin+8; b10 = sLbin+9; b11 = sLbin+10; b12 = sLbin+11; b13 = sLbin+12; disp('local wind microseism'); band = 'Local Wind Microseism Band (1-3 Hz)'


d1P = 10.^((PSDs(b1+1,:))/10)*(1/Periods(b1)-1/Periods(b2));
d2P = 10.^((PSDs(b2+1,:))/10)*(1/Periods(b2)-1/Periods(b3));
d3P = 10.^((PSDs(b3+1,:))/10)*(1/Periods(b3)-1/Periods(b4));
d4P = 10.^((PSDs(b4+1,:))/10)*(1/Periods(b4)-1/Periods(b5));
d5P = 10.^((PSDs(b5+1,:))/10)*(1/Periods(b5)-1/Periods(b6));
d6P = 10.^((PSDs(b6+1,:))/10)*(1/Periods(b6)-1/Periods(b7));
d7P = 10.^((PSDs(b7+1,:))/10)*(1/Periods(b7)-1/Periods(b8));
d8P = 10.^((PSDs(b8+1,:))/10)*(1/Periods(b8)-1/Periods(b9));
d9P = 10.^((PSDs(b9+1,:))/10)*(1/Periods(b9)-1/Periods(b10));
d10P = 10.^((PSDs(b10+1,:))/10)*(1/Periods(b10)-1/Periods(b11));
d11P = 10.^((PSDs(b11+1,:))/10)*(1/Periods(b11)-1/Periods(b12));
d12P = 10.^((PSDs(b12+1,:))/10)*(1/Periods(b12)-1/Periods(b13));
d13P = 10.^((PSDs(b13+1,:))/10)*(1/Periods(b13)-1/Periods(b13+1));



%d4P = [d4P; 0];

Dm = d1P+d2P+d3P+d4P+d5P+d6P;%

%Dm = d7P+d8P+d9P+d10P+d11P+d12P+d13P;

Dm_N = Dm./(median(Dm)); 

% Remove bad times

BI = find(Dm_N > 10);
Dm_N(BI) = [];
metdata(BI,:) = [];
Dm(BI) = [];

% Remove below median times

LI = find(Dm_N < 1);
Dm_N(LI) = [];
metdata(LI,:) = [];
Dm(LI) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Make a polar plot of wind speed, direction, seismic power  

figure(11); clf
polarscatter(metdata(:,3),metdata(:,4)*.51444,40,Dm,'filled');
hold on
polarplot(5*ones(360,1),'k-','linewidth',3);
polarplot(7*ones(360,1),'k-','linewidth',3);


set(gca,'FontSize',20)
colormap(jet);
h=colorbar
rlim([0 15]);
caxis([0.2E-12 0.8E-12])
ax = gca;
d = ax.ThetaDir
ax.ThetaDir = 'clockwise';
ax.ThetaZeroLocation = 'top';


%% Make a 2D plot of direction vs seismic power 

MWI = find(metdata(:,4)*0.51444 >= 5 & metdata(:,4)*0.5144 <= 7);

S_Power = Dm(MWI);
S_metdata = metdata(MWI,:);

Edges = (-5:10:365);

Edge_Plot = (0:10:360);

[N,Edges2,bins] = histcounts(wrapTo360(rad2deg(S_metdata(:,3))),Edges);

for kk = 1:length(Edges)-1
    if N(kk) > 8
        power_median(kk) = nanmedian(S_Power(bins==kk));
    else
        power_median(kk) = NaN;
    end

end



figure(35);clf
plot(wrapTo360(rad2deg(S_metdata(:,3))),S_Power,'kx')
hold on
plot(Edge_Plot,power_median,'r-','linewidth',3)
plot(15*ones(2,1),[0,1.4E-12],'b--','linewidth',3)
plot(195*ones(2,1),[0,1.4E-12],'b--','linewidth',3)
plot(90*ones(2,1),[0,1.4E-12],'g--','linewidth',3)
set(gca,'FontSize',20)
xlabel('Wind direction (degrees)')
ylabel('2-3 Hz Power (m^{2}/s^{4})')
xlim([0 360])
ylim([0.2E-12 1.4E-12])

%% 

Edges = (0:2:360);





