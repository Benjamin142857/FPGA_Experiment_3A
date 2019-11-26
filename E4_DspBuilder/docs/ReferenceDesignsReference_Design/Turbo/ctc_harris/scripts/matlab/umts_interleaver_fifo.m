function [fifolength] = umts_interleaver_fifo(P)
tic;
fifolength = 0;
for LL = 40:5114
    [output out1 out2 lastfifosize fifomax] = umts_interleaver (LL,P);
    if fifolength < fifomax
        fifolength = fifomax;
    end
%    fprintf('LL=%d, fifolength=%d\n',LL,fifolength);
end

fprintf('FIFO length for %d engines: %d\n',P,fifolength);

toc;