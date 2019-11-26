% File BwCapacityAWGNBICM
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
% Last updated on July 23, 2006

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

B = 2;
record = 0;

% 4FSK, gray mapping
for i=1:length(B)
    record = record+1;
    sim_param(record).comment = sprintf( '4FSK, gray mapping (B=%3.1f)', B(i) );
    sim_param(record).sim_type = 'bwcapacity';
    sim_param(record).input_filename = 'load hFskAWGNBICMCap';
    sim_param(record).scenarios = [1:100];
    if ( B(i) == max(B) )
        sim_param(record).linetype = 'b--';
    else
        sim_param(record).linetype = 'b-.';
    end
    sim_param(record).legend = sim_param(record).comment;
    sim_param(record).bwconstraint = B(i);
    sim_param(record).bwdatabase = 'BW99percent';
    sim_param(record).filename = strcat( data_directory, ['FSK4B' int2str(10*B(i)) '_AWGN_BICM_gray.mat'] );
end

% 4FSK, natural mapping
for i=1:length(B)
    record = record+1;
    sim_param(record).comment = sprintf( '4FSK, natural mapping (B=%3.1f)', B(i) );
    sim_param(record).sim_type = 'bwcapacity';
    sim_param(record).input_filename = 'load hFskAWGNBICMCap';
    sim_param(record).scenarios = [101:200];
    if ( B(i) == max(B) )
        sim_param(record).linetype = 'b:';
    else
        sim_param(record).linetype = 'b:';
    end
    sim_param(record).legend = sim_param(record).comment;
    sim_param(record).bwconstraint = B(i);
    sim_param(record).bwdatabase = 'BW99percent';
    sim_param(record).filename = strcat( data_directory, ['FSK4B' int2str(10*B(i)) '_AWGN_BICM_natural.mat'] );
end

% 8FSK, gray mapping
for i=1:length(B)
    record = record+1;
    sim_param(record).comment = sprintf( '8FSK, gray mapping (B=%3.1f)', B(i) );
    sim_param(record).sim_type = 'bwcapacity';
    sim_param(record).input_filename = 'load hFskAWGNBICMCap';
    sim_param(record).scenarios = [201:300];
    if ( B(i) == max(B) )
        sim_param(record).linetype = 'k-';
    else
        sim_param(record).linetype = 'r-.';
    end
    sim_param(record).legend = sim_param(record).comment;
    sim_param(record).bwconstraint = B(i);
    sim_param(record).bwdatabase = 'BW99percent';
    sim_param(record).filename = strcat( data_directory, ['FSK8B' int2str(10*B(i)) '_AWGN_BICM_gray.mat'] );
end

% 8FSK, natural mapping
for i=1:length(B)
    record = record+1;
    sim_param(record).comment = sprintf( '8FSK, natural mapping (B=%3.1f)', B(i) );
    sim_param(record).sim_type = 'bwcapacity';
    sim_param(record).input_filename = 'load hFskAWGNBICMCap';
    sim_param(record).scenarios = [301:400];
    if ( B(i) == max(B) )
        sim_param(record).linetype = 'r-';
    else
        sim_param(record).linetype = 'r:';
    end
    sim_param(record).legend = sim_param(record).comment;
    sim_param(record).bwconstraint = B(i);
    sim_param(record).bwdatabase = 'BW99percent';
    sim_param(record).filename = strcat( data_directory, ['FSK8B' int2str(10*B(i)) '_AWGN_BICM_natural.mat'] );
end

% 8FSK, dt mapping
for i=1:length(B)
    record = record+1;
    sim_param(record).comment = sprintf( '8FSK, dt mapping (B=%3.1f)', B(i) );
    sim_param(record).sim_type = 'bwcapacity';
    sim_param(record).input_filename = 'hFskAWGNBICMCapacity';
    sim_param(record).scenarios = [1:5];
    if ( B(i) == max(B) )
        sim_param(record).linetype = 'b*';
    else
        sim_param(record).linetype = 'b:';
    end
    sim_param(record).legend = sim_param(record).comment;
    sim_param(record).bwconstraint = B(i);
    sim_param(record).bwdatabase = 'BW99percent';
    sim_param(record).filename = strcat( data_directory, ['FSK8B' int2str(10*B(i)) '_AWGN_BICM_dt.mat'] );
end


