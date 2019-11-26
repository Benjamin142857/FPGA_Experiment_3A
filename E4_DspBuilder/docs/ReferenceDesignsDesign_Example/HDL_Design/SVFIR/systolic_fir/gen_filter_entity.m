% generate skeleton for the filter top level design file
clear variables;
close all;

coef_matrix=[103188 67747 -75861 -143186 0 208547 157491 -192299 -378316 0 548852 404403 -478970 -912354 0 1245085 893421 -1034232 -1933299 0 2576322 1841494 -2137162 -4036195 0 5667571 4257561 -5326068 -11286771 0 26948102 50193808 50193808 26948102 0 -11286771 -5326068 4257561 5667571 0 -4036195 -2137162 1841494 2576322 0 -1933299 -1034232 893421 1245085 0 -912354 -478970 404403 548852 0 -378316 -192299 157491 208547 0 -143186 -75861 67747 103188 ];
L = length(coef_matrix);

% defining parameters
engine_size_c = L/2; % use half of L because of symmetry
din_width_c = 25;
coeff_width_c = 27;
preadder_outwidth_c = din_width_c + 1;
mult_outwidth_c = preadder_outwidth_c + coeff_width_c;
dout_width_c = mult_outwidth_c + ceil(log2(L/2));
chainout_bitgrowth = ceil(log2(1:L/2));
chainout_bitwidth_c = chainout_bitgrowth + mult_outwidth_c;

% generate input sine wave for testing
fid = fopen('sine_systolic_fir_input.txt','wt');
fc = 0.2;
fo = fc/2; % half of cutoff freq.
t = 0:1/fc/20:200;
x = cos(2*pi*fo*t);
qx = floor(x*power(2, din_width_c-2))-1;
for k=1:length(x)
    fprintf(fid,'%d\n',qx(k));
end;
fclose(fid);

% define file
fid = fopen('template_systolic_fir.vhd','wt');

% define the chainout adder width
fprintf(fid, 'constant chainout_bitwidth_c : array(engine_size_c) of natural := (');
for k = 1:engine_size_c
   fprintf(fid, '%d ',chainout_bitgrowth(k) + mult_outwidth_c);
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