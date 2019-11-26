% File BwCapacityScenarios
%
% This is a set of scenarios for the Coded Modulation Library.
%
% The records in this file are used to plot Throughput of hybrid-ARQ.
%
% NOTE: - These records do not specify simulations that are run.
%         The file can only be used with CmlPlot, not with CmlSimulate.
%         It requires that simulations already be run for each block
%         transmission.
%
% Last updated on July 4, 2006

% determine where your root directory is
load( 'CmlHome.mat' );

% determine where to store your files
base_name = 'bwcapacity';
if ispc
    data_directory = strcat( cml_home, '\output\', base_name, '\' );
else
    data_directory = strcat( cml_home, '/output/', base_name, '/' );
end
if ~exist( data_directory, 'dir' )
    mkdir(data_directory);
end

B=[ 1:0.1:2 2.2:0.2:3 4:10 15 20];
record = 0;

% 2FSK
for i=1:length(B)
    record = record+1;
    sim_param(record).comment = sprintf( '2FSK (B=%3.1f)', B(i) );
    sim_param(record).sim_type = 'bwcapacity';
    sim_param(record).input_filename = 'load hFskFadingCap';
    sim_param(record).scenarios = [1:100];
    if (i==length(B))
        sim_param(record).linetype = 'k--';
    else
        sim_param(record).linetype = 'k-';
    end
    sim_param(record).legend = sim_param(record).comment;
    sim_param(record).bwconstraint = B(i);
    sim_param(record).bwdatabase = 'BW99percent';
    sim_param(record).filename = strcat( data_directory, ['FSK2B' int2str(10*B(i)) '_Fading_CSI.mat'] );
end

% 4FSK
for i=1:length(B)
    record = record+1;
    sim_param(record).comment = sprintf( '4FSK (B=%3.1f)', B(i) );
    sim_param(record).sim_type = 'bwcapacity';
    sim_param(record).input_filename = 'load hFskFadingCap';
    sim_param(record).scenarios = [101:200];
    if (i==length(B))
        sim_param(record).linetype = 'b--';
    else
        sim_param(record).linetype = 'b-';
    end
    sim_param(record).legend = sim_param(record).comment;
    sim_param(record).bwconstraint = B(i);
    sim_param(record).bwdatabase = 'BW99percent';
    sim_param(record).filename = strcat( data_directory, ['FSK4B' int2str(10*B(i)) '_Fading_CSI.mat'] );
end

% 8FSK
for i=1:length(B)
    record = record+1;
    sim_param(record).comment = sprintf( '8FSK (B=%3.1f)', B(i) );
    sim_param(record).sim_type = 'bwcapacity';
    sim_param(record).input_filename = 'load hFskFadingCap';
    sim_param(record).scenarios = [201:300];
    if (i==length(B))
        sim_param(record).linetype = 'r--';
    else
        sim_param(record).linetype = 'r-';
    end
    sim_param(record).legend = sim_param(record).comment;
    sim_param(record).bwconstraint = B(i);
    sim_param(record).bwdatabase = 'BW99percent';
    sim_param(record).filename = strcat( data_directory, ['FSK8B' int2str(10*B(i)) '_Fading_CSI.mat'] );
end

% 16FSK
for i=1:length(B)
    record = record+1;
    sim_param(record).comment = sprintf( '16FSK (B=%3.1f)', B(i) );
    sim_param(record).sim_type = 'bwcapacity';
    sim_param(record).input_filename = 'load hFskFadingCap';
    sim_param(record).scenarios = [301:400];
    if (i==length(B))
        sim_param(record).linetype = 'c--';
    else
        sim_param(record).linetype = 'c-';
    end
    sim_param(record).legend = sim_param(record).comment;
    sim_param(record).bwconstraint = B(i);
    sim_param(record).bwdatabase = 'BW99percent';
    sim_param(record).filename = strcat( data_directory, ['FSK16B' int2str(10*B(i)) '_Fading_CSI.mat'] );
end

% 32FSK
for i=1:length(B)
    record = record+1;
    sim_param(record).comment = sprintf( '32FSK (B=%3.1f)', B(i) );
    sim_param(record).sim_type = 'bwcapacity';
    sim_param(record).input_filename = 'load hFskFadingCap';
    sim_param(record).scenarios = [401:500];
    if (i==length(B))
        sim_param(record).linetype = 'm--';
    else
        sim_param(record).linetype = 'm-';
    end
    sim_param(record).legend = sim_param(record).comment;
    sim_param(record).bwconstraint = B(i);
    sim_param(record).bwdatabase = 'BW99percent';
    sim_param(record).filename = strcat( data_directory, ['FSK32B' int2str(10*B(i)) '_Fading_CSI.mat'] );
end

% 64FSK
for i=1:length(B)
    record = record+1;
    sim_param(record).comment = sprintf( '64FSK (B=%3.1f)', B(i) );
    sim_param(record).sim_type = 'bwcapacity';
    sim_param(record).input_filename = 'load hFskFadingCap';
    sim_param(record).scenarios = [501:600];
    if (i==length(B))
        sim_param(record).linetype = 'g--';
    else
        sim_param(record).linetype = 'g-';
    end
    sim_param(record).legend = sim_param(record).comment;
    sim_param(record).bwconstraint = B(i);
    sim_param(record).bwdatabase = 'BW99percent';
    sim_param(record).filename = strcat( data_directory, ['FSK64B' int2str(10*B(i)) '_Fading_CSI.mat'] );
end
