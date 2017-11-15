% This Script Loads in Smoothed/Averaged PSDs and Fluvial data and then
% aligns the two parameters into one giant-ass matrix. Data Gaps in the
% seismic record are dealt with by being filled in the NaNs


% A period vector is also output, which corresponds to the last hundred or
% so columns of said giant-ass matrix. Time is in intervals of 30 minutes
% and steps downward. 

clear all

dirroot='.';

network='IU';
station='WCI';
cmp='BHZ';
locid='10';




% load in the seismic data

psdname=[dirroot,'/PSD_Database/',network,station,locid,cmp,'psd.dat'];
eval('PSD = load(psdname);');





%PSD(1:96,:) = [];


Periods=unique(sort(PSD(1:96,7)));
b = length(Periods);

% alright, now we want to get all the dates of the PSDs

%convert all PSD dates to a datenum

H = length(PSD)/b;
date2 = zeros(H,1);

for jj=1:H
    jj
    date2(jj) = datenum(PSD(b*jj,1),PSD(b*jj,2),PSD(b*jj,3),PSD(b*jj,4),PSD(b*jj,5),PSD(b*jj,6));
end

% Find breaks in the data
gaps = diff(date2);
End_Indexs = find(abs(gaps) > (1/15));


% Make a vector of full dates
Dates_All = (date2(1):(1/24):date2(end));


% Now reshape the PSD_Matrix

PSD_M = reshape(PSD(:,8),b,length(date2));
PSD_M = PSD_M';

% set the last PSDs before gaps to NaN
PSD_M(End_Indexs,:) = NaN;
% set first PSDs after gaps to NaN
PSD_M(End_Indexs+1,:) = NaN;

% NaNs will show locations of data gaps, find them

NaN_Loc = find(isnan(PSD_M(:,1)) == 1);
%%%%%%%%%%%%%%%%% Optional to remove annoying triplet 

BadI = [46];
NaN_Loc(BadI) = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Now we loop through and insert NaNs into the gaps in the seismic data

% First Make a Matrix of NaNs same length as fluvial matrix

NaN_PSD = NaN(length(Dates_All),b);

% Begin filling in using known NaN Locations in PSD Matrix 

NaN_PSD(1:NaN_Loc(1),:) = PSD_M(1:NaN_Loc(1),:); 

% Now loop through Known Gaps and infill missing data

for kk=1:(length(NaN_Loc)/2)-1
    Start_Gap(kk) = date2(NaN_Loc((2*kk)+1));
    End_Gap(kk) = date2(NaN_Loc((2*kk)));
    
    % End of data gap
    Time_diff_E = abs(Dates_All-End_Gap(kk));
    End_Index2 = find(Time_diff_E == min(Time_diff_E));
    
    % Start of next data gap
    Time_diff_S = abs(Dates_All-Start_Gap(kk));
    Start_Index2 = find(Time_diff_S == min(Time_diff_S));
    
    % Fill in the when Data Exists 
    %if kk==6
        %End_Index2 = End_Index2+1;
        %Start_Index2 = Start_Index2-1;
    %end
    
    NaN_PSD(End_Index2:Start_Index2,:) = PSD_M(NaN_Loc(2*kk):NaN_Loc((2*kk)+1),:);
    
end

%% Finally Fill in the last part of the PSD

F_End_Gap = date2(NaN_Loc(end));


Time_diff_E = abs(Dates_All-F_End_Gap);
End_IndexF = find(Time_diff_E == min(Time_diff_E));
    
NaN_PSD(End_IndexF:end,:) = PSD_M(NaN_Loc(end):end,:);


%% Assemble the large Matrix

PSD_Full = [Dates_All', NaN_PSD];
    
% Remove all NaN PSDs and make sure everything is aligned     
 
date2(isnan(PSD_M(:,1))) = [];

PSD_Full_NN = PSD_Full;

PSD_Full_NN(isnan(PSD_Full(:,2)),:) = [];



% plot to see where this is messing up
A = PSD_Full_NN(:,1) - date2(1:end);
figure(2)
clf
plot(PSD_Full_NN(:,1),A, 'rx')
datetick('x',6)

% Assemble the large Matrix

%FS_Aligned = [Fluvial_TS2, PSD_M];

% save 

save(['./TA_Full_PSDs/',station,'.mat'],'PSD_Full');


start_disp = PSD(1,1)
end_disp = PSD(end,1)













