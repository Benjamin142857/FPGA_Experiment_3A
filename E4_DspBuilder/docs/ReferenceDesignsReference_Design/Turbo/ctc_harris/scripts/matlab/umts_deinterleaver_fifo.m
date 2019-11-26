function [fifolength] = umts_deinterleaver_fifo(P)

tic;
fifolength = 0;
for LL = 40:5114
    [output out1 out2 lastfifosize fifomax] = umts_deinterleaver (LL,P);
    if fifolength < fifomax
        fifolength = fifomax;
    end
%    fprintf('LL=%d, fifolength=%d\n',LL,fifolength);
end

fprintf('Deinterleaver: FIFO length for %d engines: %d\n',P,fifolength);
toc;
