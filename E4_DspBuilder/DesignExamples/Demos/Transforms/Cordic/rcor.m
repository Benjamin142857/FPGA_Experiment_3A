
j=1;
for i=-90:1:90
	[x,y] = get_sincos_fxp(i, 20);
	xx(j)=x;
	yy(j)=y;
    j=j+1;
end;
	
figure(1)
plot(xx,'r')
hold on
plot(yy,'b')
hold off	
figure(2)

plot(xx,yy)	 