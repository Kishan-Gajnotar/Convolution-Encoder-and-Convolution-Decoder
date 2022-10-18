clearvars;
clc;
%% Convulational Encoder
size=input("Give Number Of Message Bits To Be Sent := ");
MessageStream=zeros(1,size);

%Random Message Generator
for i=1:1:size
    MessageStream(i)=randi(2,1)-1;
end

n=2*size+4;

MessageStream=[0,0,MessageStream,0,0];

fprintf("\n Message :=");
disp(MessageStream);

%Encoding part
k=1;
EncodedMessage=zeros(1,n);
for i=1:2:n
    EncodedMessage(i)=xor(MessageStream(k+1),xor(MessageStream(k),MessageStream(k+2))); % G1=[1 1 1];
    EncodedMessage(i+1)=xor(MessageStream(k),MessageStream(k+2));                       % G2=[1 0 1];
    k=k+1;
end

fprintf(" EncodedMessage := ");
disp(EncodedMessage);

%%channal

choice=input(" input 1 for BSC channel\n input 2 for BEC channel\n input 3 for Gaussin channel \n Enter the Choice := ");

if (choice==1) 
    
%%BSC(Binary Symmetric Channel)
     BSCreceivedStream=EncodedMessage;
     pError=0.2;
    
     for i=1:1:n
         errorevent= rand < pError; 
         %if rand function's value go beyond than pError errorevent value
         %become 1 and i th bit will be changed
         
         if(errorevent)
             if(EncodedMessage(i)==1)
                BSCreceivedStream(i)=0;
             else
                BSCreceivedStream(i)=1;
             end
         end
     end
    
    fprintf("\n Encoded Message with error of BSC := ");
    disp(BSCreceivedStream);
    
    ReceivedMessage=BSCreceivedStream;   
elseif (choice==2)
    
%%BEC(Binary erasure channel)
      BECreceivedStream=EncodedMessage;
      pError=0.2;
      
      for i=1:1:n
          errorevent= rand < pError;
          %if rand function's value go beyond than pError errorevent value
          %become 1 and i th bit will be erased
          
          if(errorevent)
              BECreceivedStream(i)=NaN;
          end
      end
      
      fprintf("\n Encoded Message with error of BEC :=");
      disp(BECreceivedStream);
      
      ReceivedMessage=BECreceivedStream;
else
    
%%Gaussion chennal
    r=1/2;
    rDecisionBoundary=0;
    
    GaussianreceivedStream=EncodedMessage;
    GaussianreceivedStream(GaussianreceivedStream == 0)= -1;
    
    i=1;
    for ydb=0:n-1
      ylin=10^(ydb/10);
      sigma2=1/(2*r*ylin);
      sigma=sqrt(sigma2);
      N=sigma*randn;
      GaussianreceivedStream(i)=EncodedMessage(i)+N;
      
       for j=1:1:n
          if(GaussianreceivedStream(j)>rDecisionBoundary)
            GaussianreceivedStream(j)=1;
         else
            GaussianreceivedStream(j)=-1;
          end
       end
      i=i+1;
    end
    
     GaussianreceivedStream(GaussianreceivedStream == -1)= 0;
     
     fprintf("\n Encoded Message with error of Gaussin noise := ");
     disp(GaussianreceivedStream);
     
     ReceivedMessage=GaussianreceivedStream;
     
end

if(choice==1 || choice==2)
    
%%Hard-decision Decoding

NReceivedstream=zeros(1,length(ReceivedMessage)/2);
k=1;

for i=1:2:length(ReceivedMessage)
    NReceivedstream(k)=ReceivedMessage(i)*10+ReceivedMessage(i+1);
    k=k+1;
end

%here s1=00 s2=01 s3=10 s4=11

%here i have taken s1 s2 s3 s4 insted of s0 s1 s2 s3
%transitiontable=(s1 to s1=bit 0) Or (s1 to s3=bit 1)
%                (s3 to s2=bit 0) or (s3 to s4=nit 1)
%                like this..
transitionTable=[0 -1 1 -1;0 -1 1 -1;-1 0 -1 1;-1 0 -1 1];

%for outputTable if we are on 00 and input bit 0 then output 00 or for 
%bit 1 output is 1 (which is row 1)
outputTable=[00 11;11 00;10 01;01 10];

%Possible Next States for Current States;  
nextState=[1 3;1 3;2 4;2 4];


pathMatrix(1:4,1:length(NReceivedstream)+1)=-1;
branchMatrix(1:4,1:length(NReceivedstream)+1)=99999;

for i=0:1:length(NReceivedstream)
    
    if(i==0)
        pathMatrix(1,1)=1;
        branchMatrix(1,1)=0;
    else
        
        for s=1:1:4
            if(pathMatrix(s,i)~=-1)
                
               nextstate1=nextState(s,1);
               nextstate2=nextState(s,2);
               
               output1=outputTable(s,1);
               output2=outputTable(s,2);
               
               H1=HammingDistance(output1,NReceivedstream(i))+branchMatrix(s,i);
               H2=HammingDistance(output2,NReceivedstream(i))+branchMatrix(s,i);
               
               if( branchMatrix(nextstate1,i+1)>H1)&&(branchMatrix(nextstate1,i+1)~=99999)
                    branchMatrix(nextstate1,i+1)=H1;
                    pathMatrix(nextstate1,i+1)=s;
               end
               
               if(branchMatrix(nextstate1,i+1)==99999)
                    branchMatrix(nextstate1,i+1)=H1;
                     pathMatrix(nextstate1,i+1)=s;
               end
               
               if( branchMatrix(nextstate2,i+1)>H2)&&(branchMatrix(nextstate2,i+1)~=99999)   
                    branchMatrix(nextstate2,i+1)=H2;
                    pathMatrix(nextstate2,i+1)=s;
               end
               
               if(branchMatrix(nextstate2,i+1)==99999)
                   branchMatrix(nextstate2,i+1)=H2;
                   pathMatrix(nextstate2,i+1)=s;
               end
               
            end
        end
    end
end
               
%%Trace back part

 minh=min(branchMatrix(:,length(branchMatrix))); 
 locminh=find(branchMatrix(:,length(branchMatrix))==minh);
 x=length(pathMatrix);
 
 decodedmessage=zeros(1,length(ReceivedMessage)/2);
 
 %path = transition of states
for l=x:-1:1
    if(l==x)
        path(l)=locminh(1);
    else
        path(l)=pathMatrix(path(l+1),l+1);
    end
end
for l=1:1:length(path)-1
    decodedmessage(l)=transitionTable(path(l),path(l+1));
end

fprintf(" Original Message:= ");
disp(MessageStream(3:length(MessageStream)));
fprintf(" Decoded Message := ")
disp(decodedmessage);

else
%%Soft-decision Decoding
end    
    
%%Monte carlo 
