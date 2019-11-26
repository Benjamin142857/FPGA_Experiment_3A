
clc
format long g;

q = quantizer('single');

for i=10:samps+8

ref = spref(i-8,1);    

resbin = dec2bin(hscout(i),32);
sphscout(i,1) = single(bin2num(q,resbin));
error = ref - sphscout(i,1);
if (error ~= 0)
    fprintf(1,'\nHSC MLabRef:%f HSC:%f',ref, sphscout(i,1));
end;

end;
    