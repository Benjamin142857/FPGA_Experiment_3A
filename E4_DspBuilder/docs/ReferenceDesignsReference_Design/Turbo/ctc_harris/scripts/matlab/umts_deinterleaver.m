function [output out1 out2 lastfifosize fifomax] = umts_deinterleaver (LL,P)


output = Deinterleave([0:LL-1],CreateUmtsInterleaver(LL));

    pw_size = ceil((LL)/P);
	for index=1:LL
       %% calculate paralling ram addresses
       out1(index) = floor(output(index) / pw_size);
       out2(index) = mod(output(index), pw_size);
    end

 %% Calculate conflicts
 FIFO = zeros(1,P);
 fifomax = 0;
 num_conflicts = 0;
 for i = 1:pw_size
     for j = 1:P
       index = i + (j-1)*pw_size;
       if(index <= LL)
         tempM(j) = out1(index);
         FIFO(out1(index)+1) = FIFO(out1(index)+1) + 1;
         tM(i,j) = tempM(j);
       end
     end
     if (max(FIFO) > fifomax)
         fifomax = max(FIFO);
     end
     for j = 1:P
         if  FIFO(j) > 0
              FIFO(j) =  FIFO(j)-1;
         end
     end
     
     if (length(tempM) ~= length(unique(tempM)))
         num_conflicts = num_conflicts +1;
     end
 end
 
 lastfifosize = max(FIFO);