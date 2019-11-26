% File MinSNRvsB
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
numB = length(B);

record = 1;
sim_param(record).comment = 'q=2';
sim_param(record).sim_type = 'minSNRvsB';
sim_param(record).input_filename = 'BwCapacityAWGN';
sim_param(record).scenarios = numB*(record-1)+1:numB*record;
sim_param(record).linetype = 'k-';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).filename = strcat( data_directory, 'FSK2SNRvsB_awgn.mat' );

record = 2;
sim_param(record).comment = 'q=4';
sim_param(record).sim_type = 'minSNRvsB';
sim_param(record).input_filename = 'BwCapacityAWGN';
sim_param(record).scenarios = numB*(record-1)+1:numB*record;
sim_param(record).linetype = 'b-';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).filename = strcat( data_directory, 'FSK4SNRvsB_awgn.mat' );

record = 3;
sim_param(record).comment = 'q=8';
sim_param(record).sim_type = 'minSNRvsB';
sim_param(record).input_filename = 'BwCapacityAWGN';
sim_param(record).scenarios = numB*(record-1)+1:numB*record;
sim_param(record).linetype = 'r-';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).filename = strcat( data_directory, 'FSK8SNRvsB_awgn.mat' );

record = 4;
sim_param(record).comment = 'q=16';
sim_param(record).sim_type = 'minSNRvsB';
sim_param(record).input_filename = 'BwCapacityAWGN';
sim_param(record).scenarios = numB*(record-1)+1:numB*record;
sim_param(record).linetype = 'c-';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).filename = strcat( data_directory, 'FSK16SNRvsB_awgn.mat' );

record = 5;
sim_param(record).comment = 'q=32';
sim_param(record).sim_type = 'minSNRvsB';
sim_param(record).input_filename = 'BwCapacityAWGN';
sim_param(record).scenarios = numB*(record-1)+1:numB*record;
sim_param(record).linetype = 'm-';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).filename = strcat( data_directory, 'FSK32SNRvsB_awgn.mat' );

record = 6;
sim_param(record).comment = 'q=64';
sim_param(record).sim_type = 'minSNRvsB';
sim_param(record).input_filename = 'BwCapacityAWGN';
sim_param(record).scenarios = numB*(record-1)+1:numB*record;
sim_param(record).linetype = 'g-';
sim_param(record).legend = sim_param(record).comment;
sim_param(record).filename = strcat( data_directory, 'FSK64SNRvsB_awgn.mat' );
