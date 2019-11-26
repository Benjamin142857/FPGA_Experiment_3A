% generate skeleton for the filter top level design file
clear variables;
close all;

L = 128;
R = 4;
chan = 4;

% defining parameters
engine_size_c = L/R; 
din_width_c = 25;
coeff_width_c = 27;
mult_outwidth_c = din_width_c + coeff_width_c;
dout_width_c = mult_outwidth_c + ceil(log2(L));
sumof2_bitwidth_c = mult_outwidth_c+1;

fc = 0.2/R;
h = fir1(L-1, fc*2); % fir1 cutoff is 2fc
h = h/max(h);                              %% Floating point coefficients
qh = round(h*power(2,coeff_width_c-1)-1);                   %% Quantization of filter coefficients
t1 = reshape(qh, R, engine_size_c);
t2 = t1.'; % transpose, a engine_size_c by R matrix
qh_matrix = fliplr(t2); % here I flip the polyphases for decimation already
% generate input sine wave for testing
fid = fopen('sine_decimation_fir_input.txt','wt');
fc = 0.2;
fo = fc/2; % half of cutoff freq.
t = 0:1/fc/100:160;
x = cos(2*pi*fo*t);
qx = floor(x*power(2, din_width_c-2))-1;
for k=1:length(x)
    fprintf(fid,'%d\n',qx(k));
end;
fclose(fid);

% define file
fid = fopen('template_decimation_fir.vhd','wt');

% print filter coeffi
fprintf(fid, 'constant coeff_matrix_c : coeff_matrix_type := (');
for k = 1:engine_size_c
    fprintf(fid, '\n');    
    fprintf(fid, '%d => (', k-1);
    for n = 1:R
        fprintf(fid, '%d, ',qh_matrix(k, n));
    end
    fprintf(fid, '),');
end
fprintf(fid, ');\n');


% define coefficient signals; should I used a big vector instead?
% for k = 1:L/2
%    fprintf(fid, 'signal coeff_%d : signed(coeff_width_c -1 downto 0);\n',k);
% end
fprintf(fid, 'type coeff_array is array (engine_size_c) of signed(coeff_width_c -1 downto 0);\n');
fprintf(fid, 'signal coeff : coeff_array;\n');
% make delay taps into a component, use generate to instantiate L-1 such
% components; as a result, each tap is a signal;
% for k = 1:L-1
%    fprintf(fid, 'signal tap_%d : signed(din_width_c -1 downto 0);\n',k);
% end

% note that the first tap is din
% fprintf(fid, 'type tap_array is array (engine_size_c) of signed(din_width_c -1 downto 0);\n');
% fprintf(fid, 'signal taps : tap_array;\n');
% 
% define each multiplier chainout signal with proper bitwidth
% first define chainout signal array to be of max size, then within each
% generate statement use a local signal of smaller size.  therefore a table
% is needed to define the bit width of the local signals
% fprintf(fid, 'type chainout_array is array (engine_size_c) of signed(dout_width_c -1 downto 0);\n');
% fprintf(fid, 'signal chainout : chainout_array;\n');

% % if have to define chainout signals one by one
% for k = 0:engine_size_c-1
%     fprintf(fid, 'signal chainout%d : signed(%d -1 downto 0);\n', k, chainout_bitwidth_c(k+1));
% end
% 
% for k = 0:engine_size_c-1
%     fprintf(fid, 'mult_map%d : process (reset, clk) is\n', k);
%     fprintf(fid, 'begin  -- process mult\n');
%     fprintf(fid, 'if rising_edge(clk) then \n');
%     fprintf(fid, 'if reset = ''1'' then \n');
%     fprintf(fid, 'chainout%d <= (others => ''0'' ); \n', k);
%     fprintf(fid, 'elsif reg_in_valid = ''1'' then \n');
%     if k == 0
%         fprintf(fid, 'chainout0 <= preadder_out(0)*coeff(0);\n');
%     else
%         fprintf(fid, 'chainout%d <= resize(chainout%d + preadder_out(%d)*coeff(%d), chainout_bitwidth_c(%d));\n', k, k-1, k, k, k);
%     end
%     fprintf(fid, 'end if;\n');
%     fprintf(fid, 'end if;\n');    
%     fprintf(fid, 'end process mult_map%d;\n', k);
%     fprintf(fid, '\n');
% end

fclose(fid);