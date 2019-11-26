
format long g;

samps = 200;

q = quantizer('single');

str = 'The range for single is:\n\t%g to %g and\n\t %g to  %g';
sprintf(str, -realmax('single'), -realmin('single'), ...
   realmin('single') , realmax('single'))

minsp = single(realmin('single'));

for i=1:samps

sign = floor(rand*2^1);
exp = floor(rand*(2^8));
mant = floor(rand*(2^23));

opabin = ([dec2bin(sign,1), dec2bin(exp,8), dec2bin(mant,23)]);
opa(i,2) = bin2dec(opabin);
opa(i,1) = i;

sign = floor(rand*2^1);
exp = floor(rand*(2^8));
mant = floor(rand*(2^23));

opbbin = ([dec2bin(sign,1), dec2bin(exp,8), dec2bin(mant,23)]);
opb(i,2) = bin2dec(opbbin);
opb(i,1) = i;


oparef(i,1) = single(bin2num(q,opabin));
opbref(i,1) = single(bin2num(q,opbbin));

if (abs(oparef(i,1)) < minsp)
    oparef(i,1) = 0.0;
end;

if (abs(opbref(i,1)) < minsp)
    opbref(i,1) = 0.0;
end;

spref(i,1) = oparef(i,1) * opbref(i,1);

if (abs(spref(i,1)) < minsp)
    spref(i,1) = 0.0;
end;


end;




