% This script takes in raw meteroroligcal data in format (Year, Jday, Hour,
% Min, Data) and converts everything to datenum and averaged on the same
% time-scale as 2-Hour PSD estimates. Gaps are filled with Nans. Output
% will be stored in Folder "Full_Weather" 


%%%             IMPORTANT !!!!!                     %%%%%%%%

%%%% Code Assumes that the 3rd meteorological data field is wind direction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all

Datafile_Name='Point_Iroquois_Met'; 

% Give Seismic PSD window length to adjust to (in days)
PSD_Window = 1/24;

% Number of data streams in met data
Num_Data_Fields = 6;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% load in the data
dirroot='.';
filename=[dirroot,'/Raw_Met_Data/',Datafile_Name,'.txt'];
eval('Met = load(filename);');

% Remova anomolouys pt.
% Met(226726,:) = [];

% Pull out just the datastreams 
Raw_Data = Met(:,5:end);

% find missing data and set to NaN (99.9)

% Temperature data
MD = find(Raw_Data(:,1) == 999.9);
Raw_Data(MD,1) = Inf;

% Wind Speed
ME = find(Raw_Data(:,4) == 99.9);
Raw_Data(ME,4) = Inf;

% Wind Direction and convert to radians
MF = find(Raw_Data(:,3) == 999);
Raw_Data(MF,3) = Inf;
Raw_Data(:,3) = deg2rad(Raw_Data(:,3));


% Convert to datenum (slight trick)
jj = zeros(1,length(Met));

for jj=1:length(Met)
    date2(jj) = datenum(Met(jj,1),0,0) + Met(jj,2) + datenum(0,0,0,Met(jj,3),Met(jj,4),0);
end

wtf = datevec(date2);


%% Plot to see how uniformly sampled the dataset is

% add an hour to dates to get things to line up better



diff_date = diff(date2);
diff_date = [diff_date,1/24];


figure(1); clf
plot(date2, diff_date, 'rx')
datetick('x',11)
%ylim([0 20])
%xlim([date2(1) date2(end)])
ylabel('Data Gap Length (Days)')


%% Make the new Vector resampled on same timescale as PSDs

Dates_Full = (date2(1):PSD_Window:date2(end)); 

date2 = date2 + 0.005;

Met_all = NaN(length(Dates_Full), Num_Data_Fields);
Hit_Index_Hist = zeros(length(Dates_Full),1);

for kk = 1:length(Dates_Full)-1 
    
    Hit_Ind = find(date2 >= Dates_Full(kk) & date2 < Dates_Full(kk+1));
    
    Hit_Index_Hist(kk) = length(Hit_Ind);
    
    if ~isempty(Hit_Ind)
        
        if length(Hit_Ind) == 1
            Met_all(kk,:) = Raw_Data(Hit_Ind,:);
            
        else
    
        Int_data = Raw_Data(Hit_Ind,:);
        
        Met_all(kk,[1:2,4:end]) = mean(Int_data(:,[1:2,4:end]));
        
        Met_all(kk,3) = circ_mean(Int_data(:,3));
        
        end
      
        
        
    end
end
    
% Compile into a single large_matrix with averaging between adjacent estimates

Met_Full = zeros(length(Met_all),Num_Data_Fields+1);

Met_Full(:,1) = Dates_Full'; 

Met_all = [Met_all;NaN(1,Num_Data_Fields)];

%%

for mm = 1:length(Met_Full)
    
    Met_Full(mm,[2:3,5:end]) = mean(Met_all(mm:mm+1,[1:2,4:end]));
    Met_Full(mm,4) = circ_mean(Met_all(mm:mm+1,3));
end



    









