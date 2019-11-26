% File: setup_vardownsampler.m
% Description: Script to set variables in Matlab workspace to configure vardownsample model
%               This design assumes fixed input sample rate and variable
%               decimation rate.  It has a polyphase structure, and the
%               kernal size (multiplier count) is fixed.  The total filter
%               length grows linearly with the decimation rate.

clear variables
close all

%% Multichannel setup
ChanCount=16;

%% clock and sample rate setup
ClockRate=256;
% NOTE: input sample rate must be fixed at compile time and should divide
% ClockRate
SampleRate= 16;
Period=floor(ClockRate / SampleRate);
SampleTime = 1;
%SampleTime = 1 / (ClockRate * 1e6);   % uncomment this line to simulate
%the model with realworld time 
ClockMargin = 0.0;

%% Decimation rate setup
Rmax = 16; % maximum sample rate the design supports
R = [1 2 5 8 2]; %sample rates being tested in the test bench
numRates = length(R);

%% Filter setup
% Option 1: fixed kernal size;
%           derive total filter length from kernal size
% Spec: total filter length = totlen;
L = 10; % muliplier engine (kernal size): number of multipliers;
fLen = L*R; % Filter length for each sample rate; linearly grows with Rate
fLenmax = L*Rmax; % worst case filter length; ie maximum filter length
Lmax = L; % the worst case subfilter length, allowing L to vary

%% Filter Setup
% % Option 2: fixed total filter length;
% %          derive kernal size from rate and total filter length
% fLen = [32 40 56 64 72];
% L = fLen(1)/R(1); % muliplier engine (kernal size): number of multipliers;
% if length(fLen) ~= numRates
%     disp('ERROR: The number of filters is different from the number of rates');
%     disp('Exit setup script');
%     return
% end
% % check if your total filter length gives you an integer kernal size
% if ceil(L) ~= floor(L)
%     disp('ERROR: The total filter length must be an integer multiple of the kernel size');
%     disp('Exit setup script');
%     return
% end
% if fLen./R ~= L
%     disp('ERROR: The multiplier engine size is different for different rates');
%     disp('Exit setup script');
%     return
% end
% fLenmax = L*Rmax;

%% Filter Design 
% design filter for each sample rate tested
% h is a matrix of coeff.; each row is a filter for a rate R
% shorter filters are zero padded so that them can all be stored in h
h = zeros(numRates, fLenmax); 
% The cutoff frequency is selected arbitrarily within Nyquist rate;
% customize it if needed.
fc = 1./R; % cutoff frequency
% treat flat rate filter differently (no decimation)
singleRateIndx = find(R == 1);
fc(singleRateIndx) = 0.9; % an arbitrary number here, as long as it is <1.0.
for n = 1:numRates
    h_tmp = fir1(fLen(n)-1, fc(n));
    % scale h_tmp to maximize dynamic range
    h_tmp = h_tmp/max(abs(h_tmp));
    h(n, 1:fLen(n)) = h_tmp;
end

%% Coefficient memory setup
% hmatrix is the coefficient memory initialization matrix.
% Note that the coefficients memory must be assigned based on worst case,
% so zero pad coefficients if needed.
% Initialize hmatrix according to the first 2 rates, since two banks are
% used. If only 1 rate is used in the design, the 2nd bank is initialized
% with 0.
% While coefficients are being read out from one bank, contents of the 
% other bank can be updated via Avalon MM.  Switching between coefficients 
% takes 1 cycle and happens simultaneously with rate change.
hmatrix = zeros(2*Rmax, L);
% comment out this if you have only single rate
for n=1:min(2, numRates)
    % store h in a look up table, each row is a polyphase component of size L
    hmatrix_tmp = reshape(h(n,1:L*R(n)), R(n), L);
    hmatrix((n-1)*Rmax+1:(n-1)*Rmax + R(n), 1:L) = hmatrix_tmp;
    clear hmatrix_tmp;
end

%% Bit Width setup for Variable tap delays and Multiplier engine
Nmax = Period*Rmax; % the maximum depth of each variable delay tap
% all address signals must have at least 1 bit width. use Max(1, **) to
% account for single channel single rate and R=1 case.
memAddrWidth = max(1,ceil(log2(Nmax))); % address signal width of the variable delay tap
addrWidth = max(1,ceil(log2(Rmax))); % coeff. counter address signals are of type uint(addrWidth)
coeffWidth = 16;
dataWidth = 16;
fihmatrix = fi(hmatrix, 1, coeffWidth, coeffWidth -1 );
resetCntWidth = max(1,ceil(log2(Nmax))); % counter width of the reset signal for delay taps; old used Nmax*L
%multWidth = 24;
adderOutWidth = dataWidth + coeffWidth + ceil(log2(L));
adderOutShift = 4*ones(1,numRates); % number of left shifts of the final adder output; the same length as the rate factor R
accumOutWidth = dataWidth + ceil(log2(Rmax))+0; % final accumulator bit growth is log2(Rmax)
accumOutShift = [1 4 3 2 4]; %number of left shifts of the final accumulator output; the same length as the rate factor R
% R = 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16, shift = 4,3,3,3,2...2
if length(accumOutShift) ~= numRates
    disp('ERROR: AccumOutShift needs to be the same length as numRates');
    return
end

%% Derived Parameters 
% wire count and cycle count is at the input to the system
BusClockRate = ClockRate/4;
BusSampleTime = SampleTime * ClockRate/BusClockRate;
ChanWireCount=ceil(ChanCount/Period);
ChanCycleCount=ceil(ChanCount/ChanWireCount);
RateWidth = ceil(log2(Rmax))+1; % should be no more than log2(RMax)+1
% adding 1 extra bit so 16 can be represented
% we assume FPGA clock rate is an integer multiple of the input sample rate
v_in = [ones(1,ChanCycleCount) zeros(1,Period-ChanCycleCount)];

disp(['Parameters set from setup_vardownsampler.m: ChanCount = ' num2str(ChanCount) '; ClockRate = ' num2str(ClockRate) '; SampleRate = ' num2str(SampleRate) '; Interpolation = ' num2str(R) ';']);

%% Memory map, the following is the base addresses for various programmable components
% Note address width is 16 which is specified in Control block
RateAddr = 1; % 32-bit control reg that stores the rate value; takes one word
AdderOutScale = RateAddr + 1; % address for final adder output scaling
AccumOutScale = AdderOutScale + 1; % address for final accumulator output scaling
FirAddr = AccumOutScale + 1; % 
% The entire FIR coeff. Address space is of size 2*Rmax*L 16-bit words.
% If the coefficient width exceeds 16, one can increase the address width so that each
% coefficient still occupies one address. Otherwise one needs to modify the
% coefficient-gen module to match the new address.


%% Simulation setup: real time change of decimation rate
% Sequence of events: 1. Change Rate
%                     2. Change Adder scaling
%                     3: change accumulator scaling
%                     4: Start updating coefficients of the next filter
%                     bank: R*L words need update
%                     5. Go back to step 1, repeat till all rates are
%                     covered
% Note: rate change can only happen at the start of a new period, so that
% all channels experience the same kind of changes
busPeriod = floor(ClockRate/BusClockRate);
numCycles = (3+ Rmax*L)*busPeriod + floor(Rmax*200/Period)*Period; % run one decimation rate for numCycles cycles
% busPeriod = Period;
busAddr = [];
busWriteData = [];
busWrite = [];
flag = 0;
for n = 1:numRates
    % first update control regs, do this for all rates
    busAddr = [busAddr ones(1,busPeriod)*RateAddr ones(1,busPeriod)*AdderOutScale ones(1,busPeriod)*AccumOutScale];
    busWriteData = [busWriteData ones(1,busPeriod)*R(n) ones(1,busPeriod)*adderOutShift(n) ones(1,busPeriod)*accumOutShift(n)];
    busWrite = [busWrite ones(1,busPeriod*3)];
    % second update filter coeff; do this only if numRates>2
    if (numRates > 2) && (n > 1) && (n ~= numRates) % 1st rate and last rate do not need to update filter
        if flag == 0
            coffset = FirAddr + 0;
        else
            coffset = FirAddr + Rmax;
        end
        htmp = reshape(h(n+1,1:L*R(n+1)), R(n+1), L); % use next rate, not current rate
        fihtmp = round(2^(coeffWidth-1)*htmp/max(abs(htmp(:))))-1;
        % convert the coefficients to two's complement, 32 bits
        ind = find(fihtmp<0);
        fihtmp(ind) = fihtmp(ind) + 2^32;
%         fihtmp = htmp;
        for k = 1:R(n+1)
            busAddr = [busAddr kron(coffset + ((k-1):2*Rmax:2*(L-1)*Rmax+(k-1)), ones(1,busPeriod))];
            busWriteData = [busWriteData kron(fihtmp(k,:), ones(1,busPeriod))];
        end
        % flip the flag signal so that next time we write to a different bank
        flag = ~(flag);
        busWrite = [busWrite ones(1,R(n+1)*L*busPeriod)];        
        % last zero pad for the idle cycles
        busAddr = [busAddr zeros(1, numCycles - (3+R(n+1)*L)*busPeriod)];
        busWriteData = [busWriteData zeros(1, numCycles - (3+R(n+1)*L)*busPeriod)];
        busWrite = [busWrite zeros(1, numCycles - (3+R(n+1)*L)*busPeriod)];
    else % only zero pad for fixed rate, 1st and last rate values
        busAddr = [busAddr zeros(1, numCycles - 3*busPeriod)];
        busWriteData = [busWriteData zeros(1, numCycles - 3*busPeriod)];
        busWrite = [busWrite zeros(1, numCycles - 3*busPeriod)];        
    end
end
simTime = length(busAddr);