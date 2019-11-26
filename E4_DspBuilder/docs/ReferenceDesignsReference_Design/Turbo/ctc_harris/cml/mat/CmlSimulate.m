function [sim_param, sim_state] = CmlSimulate( varargin )
% CmlSimulate runs a set of simulations.
%
% The calling syntax is:
%     [sim_param, sim_state] = CmlSimulate( scenario_filename, cases )
%
%     Outputs:
%     sim_param = A structure containing simulation parameters.
%     sim_state = A structure containing the simulation state.
%     Note: See readme.txt for a description of the structure formats.
%
%     Required inputs:
%	  scenario_filename = the name of the file containing an array of sim_param structures.
%     cases = a list of the array indices to simulate.
%
%     Note: Multiple scenario files can be specified.  In this case, the argument list
%     should contain each scenario file to be used followed by the list of array indices
%     to read from that file.
%     
%     Example:
%     [sim_param, sim_state] = CmlSimulate( 'Scenario1', [1 2 5], 'Scenario2', [1 4 6] );
%
%     Copyright (C) 2005-2006, Matthew C. Valenti
%
%     Last updated on June 28, 2006
%
%     Function CmlSimulate is part of the Iterative Solutions Coded Modulation
%     Library (ISCML).  
%
%     The Iterative Solutions Coded Modulation Library is free software;
%     you can redistribute it and/or modify it under the terms of 
%     the GNU Lesser General Public License as published by the 
%     Free Software Foundation; either version 2.1 of the License, 
%     or (at your option) any later version.
%
%     This library is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     Lesser General Public License for more details.
%
%     You should have received a copy of the GNU Lesser General Public
%     License along with this library; if not, write to the Free Software
%     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

% setup structures and retrieve data
[sim_param, sim_state] = ReadScenario( varargin{:} );
number_cases = length( sim_param );

tic;
for i = 1:length(sim_param)
    if (sim_param(i).rtl_simulation == 1)
        dump_dir = sim_param(i).dump_dir;
        if (length(dump_dir) == 0)
           error(sprintf('You have to set dump_dir in your test scenario %d.', i));
        end;
        
        files(1).name = strcat(dump_dir, '/ctc_blksize.txt');
        files(2).name = strcat(dump_dir, '/ctc_data_input.txt');
        files(3).name = strcat(dump_dir, '/ctc_decoded_output_gold.txt');
        files(4).name = strcat(dump_dir, '/ctc_output_u_gold.txt');
        files(5).name = strcat(dump_dir, '/ctc_iter_data.txt');
        files(6).name = strcat(dump_dir, '/ctc_encoder_input.txt');
        files(7).name = strcat(dump_dir, '/ctc_encoder_input_info.txt');
        files(8).name = strcat(dump_dir, '/ctc_encoder_output_gold.txt');

        for j = 1:length(files)
            if (exist(files(j).name,'file'))
                delete(files(j).name);
            end;
        end;
    end;
end;

for ( case_number=1:number_cases )
    fprintf( '\n\nRecord %d\n', case_number );
    if ( ( strcmp( sim_param(case_number).sim_type, 'throughput' ) ) )
        % calculate the throughput
        [sim_param(case_number), sim_state(case_number)] = CalculateThroughput( sim_param(case_number), sim_state(case_number) );
    elseif ( ( strcmp( sim_param(case_number).sim_type, 'bwcapacity' ) ) )
        % calculate the bandwidth constrained capacity of CPFSK
        [sim_param(case_number), sim_state(case_number)] = CalculateMinSNR( sim_param(case_number), sim_state(case_number) );
    elseif ( ( strcmp( sim_param(case_number).sim_type, 'minSNRvsB' ) ) )
        % calculate the throughput
        fprintf( '\n minSNRvsB\n\n' );
        [sim_param(case_number), sim_state(case_number)] = CalculateMinSNRvsB( sim_param(case_number), sim_state(case_number) );
    else
        % This is a simulation, not a calculation
        % Initialize code_param
        [sim_param(case_number), code_param] = InitializeCodeParam( sim_param(case_number) );

        % Call SingleSimulate for this case

        % determine if mat or exe is called
        if ( sim_param(case_number).compiled_mode == 0 )
            % run the matlab version
            sim_state(case_number) = SingleSimulate( sim_param(case_number), sim_state(case_number), code_param );
        else
            % run the compiled exe in stand-alone mode
            save('SimSetup.mat','code_param');
            save_param = sim_param(case_number);
            save_state = sim_state(case_number);

            save('SimState.mat','save_param','save_state');
            !SingleSimulate &
        end
    end
end
toc;
