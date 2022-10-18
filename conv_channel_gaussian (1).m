clearvars;
clc;
j=1;
n=input('enter the number of binary string:');
A=zeros(1,n);
X1=zeros(1,length(A)+2);
X2=zeros(1,length(A)+2);
for i=1:n
    A(i)=randi(2,1)-1;
end
encoder=[0,0,A,0,0];
for k=1:(length(encoder)-2)
    X1(j)=xor(xor(encoder(k),encoder(k+1)),encoder(k+2));
    X2(j)=xor(encoder(k),encoder(k+2));
    j=j+1;
end
fprintf('input string: ');
disp(A);
fprintf('encoder window: ');
disp(encoder);
fprintf('X1:');
disp(X1);
fprintf('X2:');
disp(X2);
encoder_op=zeros(1,2*(length(A)+2));
M=1;
for p=1:1:2*(length(A)+2)
    if mod(p,2)==0
        encoder_op(p)=X2(M); 
         M=M+1;
    end
  
end
M=1;
for p=1:1:2*(length(A)+2)
    if mod(p,2)~=0
       encoder_op(p)=X1(M);
       M=M+1;
    end
    
end
fprintf('encoder output:');
disp(encoder_op);
  %% gaussian noise channel 
r=1/2;
r_op=zeros(1,length(encoder_op));

r_decision_boundary=0;
for i=1:2*(length(A)+2)
    if encoder_op(i)==0
        encoder_op(i)=-1;
    else
        encoder_op(i)=1;
    end
end

fprintf('encoder_o/p: ');
disp(encoder_op);
i=1;
for ydb=0:length(encoder_op)-1
    ylin=10.^(ydb/10);
    sigma2=1/(2*r*ylin);
    sigma=sqrt(sigma2);
    n=sigma*randn;
    r_op(i)=encoder_op(i)+n;
    for j=1:length(encoder_op)
        if r_op(j)>r_decision_boundary
            r_op(j)=1;
        else
            r_op(j)=-1;
        end
    end
    i=i+1;
end

fprintf('r_o/p: ');
disp(r_op);
for k=1:length(r_op)
    if r_op(k)==-1
        r_op(k)=0;
    end
end
fprintf('channel output string:');
disp(r_op);
        