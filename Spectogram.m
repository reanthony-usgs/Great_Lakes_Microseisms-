%Spectrogram of PSDs
clear all
dirroot='.';

network='TA';
station='F45A';
cmp='BHZ';
locid='--';

% set the start date 
start_date = [2011,10,1,0,0,0];
start_date = datenum(start_date);

end_date = [2014,7,2,0,0,0];
end_date = datenum(end_date);



psdname=[dirroot,'/PSD_Database/',network,station,locid,cmp,'psd.dat'];
eval('PSD = load(psdname);');


periods=unique(sort(PSD(1:96,7)));
b = length(periods);


%convert all dates to a datenum

H = length(PSD)/b;
date2 = zeros(H,1);

for jj=1:H
    jj
    date2(jj) = datenum(PSD(b*jj,1),PSD(b*jj,2),PSD(b*jj,3),PSD(b*jj,4),PSD(b*jj,5),PSD(b*jj,6));
end


% set the start date to the full range
%start_date = date2(1);
%end_date = date2(end-6);

% Find breaks in the data
gaps = diff(date2);
End_Indexs = find(gaps > (1/15));


% Reshape into matrix
PSD_M = reshape(PSD(:,8),b,length(PSD(:,7))/b);

%set the last PSDs before gaps to NaN
PSD_M(:,End_Indexs) = NaN;

% Cut down to Interest Dates

S_Index = find(date2 > start_date,1, 'first');

E_Index = find(date2 > end_date,1, 'first');

PSD_M = PSD_M(:,S_Index:E_Index);

 


% correct for minus sign issue
%PSD_M = PSD_M*-1;





%% make the figure

% Make the Y-Axis Tick Labels in Hz
%Hz_lines = [15,10,5,3,1,0.5,0.2,0.1,0.05,0.01];

%ticks = log10(1./Hz_lines);
%HZ_label = (1./10.^(ticks));

% Make the Y-Axis Tick Labels in Period
Period_lines =  [0.1, 0.2, 0.3, 0.5, 1, 2,3,5,10,20];
ticks = log10(Period_lines);


Date_ticks = [start_date,start_date+92,start_date+183,start_date+274,start_date+366,start_date+458,start_date+548,start_date+639,start_date+731,start_date+823,start_date+913,start_date+1004];
Date_tick_labels ={'Oct','Jan','Apr','Jul', 'Oct', 'Jan', 'Apr','Jul', 'Oct', 'Jan', 'Apr','Jul'};



fignum = '15'
figure(str2num(fignum)); clf

uimagesc(date2(S_Index:E_Index-1), log10(periods), PSD_M)
colormap(jet);
colorbar
datetick('x',7)
ylim([-1.18 1.5])
xlim([start_date end_date])
ylabel('Period (s)' ,'fontsize',24)
xlabel('Month', 'fontsize',24);
caxis([-160 -115])
ax = gca;
%c = ax.Color;
ax.LineWidth = 3;
set(gca,'ytick',ticks)
set(gca,'xtick',Date_ticks)
set(gca,'Yticklabel',Period_lines)
set(gca, 'Xticklabel',Date_tick_labels)
set(gca,'ydir','normal')
set(gca,'FontSize',20)
hold on
%plot(datenum(2013,4,1)*ones(length(periods),1),log10(periods),'k','linewidth',3)
%plot(datenum(2013,5,1)*ones(length(periods),1),log10(periods),'k','linewidth',3)


plot(datenum(2014,2,28)*ones(length(periods),1),log10(periods),'k','linewidth',3)
plot(datenum(2014,3,24)*ones(length(periods),1),log10(periods),'k','linewidth',3)


%title({'Spectrogram',cmp, station})



