% generate skeleton for the filter top level design file
clear variables;
close all;

% coef_matrix=[-51183 0 54334 35300 -37548 -65282 0 77162 52281 -57520 -102636 0 125205 85472 -94348 -168338 0 203860 138326 -151613 -268422 0 319748 215151 -233874 -410730 0 481845 321925 -347605 -606652 0 703812 467962 -503121 -874770 0 1009011 669563 -718926 -1249232 0 1442572 959070 -1032742 -1801698 0 2105406 1411393 -1535356 -2712016 0 3276858 2246254 -2511267 -4588193 0 6103068 4488093 -5516536 -11528135 0 27051046 50211924 50211924 27051046 0 -11528135 -5516536 4488093 6103068 0 -4588193 -2511267 2246254 3276858 0 -2712016 -1535356 1411393 2105406 0 -1801698 -1032742 959070 1442572 0 -1249232 -718926 669563 1009011 0 -874770 -503121 467962 703812 0 -606652 -347605 321925 481845 0 -410730 -233874 215151 319748 0 -268422 -151613 138326 203860 0 -168338 -94348 85472 125205 0 -102636 -57520 52281 77162 0 -65282 -37548 35300 54334 0 -51183 ];
% L = length(coef_matrix);
% half_coef_matrix = coef_matrix(1:L/2);
L = 32;

% defining parameters
engine_size_c = L/2; % use half of L because of symmetry
din_width_c = 25;
coeff_width_c = 27;
preadder_outwidth_c = din_width_c + 1;
mult_outwidth_c = preadder_outwidth_c + coeff_width_c;
dout_width_c = mult_outwidth_c + ceil(log2(L/2));
sumof2_bitwidth_c = mult_outwidth_c+1;
chainout_bitgrowth = ceil(log2(1:L/2));
chainout_bitwidth_c = chainout_bitgrowth + mult_outwidth_c;

h = fir1(L-1, 0.4);
h = h/max(h);                              %% Floating point coefficients
qh = round(h*power(2,coeff_width_c-1)-1);                   %% Quantization of filter coefficients
half_qh = qh(1:L/2);
% generate input sine wave for testing
fid = fopen('sine_parallel_fir_input.txt','wt');
fc = 0.2;
fo = fc/2; % half of cutoff freq.
t = 0:1/fc/20:1600;
x = cos(2*pi*fo*t);
qx = floor(x*power(2, din_width_c-2))-1;
for k=1:length(x)
    fprintf(fid,'%d\n',qx(k));
end;
fclose(fid);

% define file
fid = fopen('template_parallel_fir.vhd','wt');

% print filter coeffi
fprintf(fid, 'constant coeff_c : coeff_type := (');
for k = 1:L/2
   fprintf(fid, '%d, ',qh(k));
end
fprintf(fid, ');\n');
% define the chainout adder width
fprintf(fid, 'constant chainout_bitwidth_c : chainout_width_type_c := (');
for k = 1:engine_size_c
   fprintf(fid, '%d, ',chainout_bitgrowth(k) + mult_outwidth_c);
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
fprintf(fid, 'type tap_array is array (engine_size_c) of signed(din_width_c -1 downto 0);\n');
fprintf(fid, 'signal taps : tap_array;\n');

% define each multiplier chainout signal with proper bitwidth
% first define chainout signal array to be of max size, then within each
% generate statement use a local signal of smaller size.  therefore a table
% is needed to define the bit width of the local signals
fprintf(fid, 'type chainout_array is array (engine_size_c) of signed(dout_width_c -1 downto 0);\n');
fprintf(fid, 'signal chainout : chainout_array;\n');

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