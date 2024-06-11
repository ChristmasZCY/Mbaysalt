function st=evalparam(x,u2,xeval,yeval)

xst=u2{1}(x(1),x(2));
yst=u2{2}(x(1),x(2));

st(1)=xst-xeval;
st(2)=yst-yeval;