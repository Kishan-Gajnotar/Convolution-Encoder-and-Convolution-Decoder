%%
% Monte Carlo Simulatios
clearvars;
clc;
%% Encoder part
        size=500;
        User_message=zeros(1,size);
        
        %Random Message Generator
        for i=1:1:size
            User_message(i)=randi(2,1)-1;
        end
        
        n=2*size+4;
        
        User_message=[0,0,User_message,0,0];
    
        %Encoding part
        k=1;
        encoded_message=zeros(1,n);
        for i=1:2:n
            encoded_message(i)=xor(User_message(k+1),xor(User_message(k),User_message(k+2))); % G1=[1 1 1];
            encoded_message(i+1)=xor(User_message(k),User_message(k+2));                       % G2=[1 0 1];
            k=k+1;
        end
        
   fprintf("Encoding complete.....\n");     
%% Monte Carlo Trials

choice=input("\n input 1 for BSC channel\n input 2 for BEC channel\n input 3 for Gaussin channel \n Enter the Choice := ");

r=1/2; %rate of the encoder
SNRdB=0:0.5:8;
SNRlin=10.^(SNRdB/10);
Nsim=20000;
Nerr=0;

if(choice==1 || choice==2)
% For BSC and BEC Channel    
  %  p=qfun(sqrt(2*r*SNRlin));
  p=[ 0.1587    0.1447    0.1309    0.1173    0.1040    0.0912    0.0789    0.0673    0.0565    0.0466    0.0377    0.0298    0.0230    0.0173    0.0126    0.0089    0.0060
];   %% hear q function doesn't workm so this array was writen from online matlab. 
else
% For Gaussian Channel
   SD=1;
   sigma2 = SD*SD./(2*r*SNRlin);
   sigma = sqrt(sigma2);
end

BER=zeros(length(SNRlin),Nsim);

for x = 1:1:length(SNRlin)
    for y = 1:1:Nsim
      
        %% Channels
        if (choice==1)
            
            %%BSC(Binary Symmetric Channel)
            BSCreceived_stream=encoded_message;
            pError=p(x);
            
            for i=1:1:n
                error_prob= rand < pError;
                %if rand function's value go beyond than pError errorevent value
                %become 1 and i th bit will be changed
                
                if(error_prob)
                    if(encoded_message(i)==1)
                        BSCreceived_stream(i)=0;
                    else
                        BSCreceived_stream(i)=1;
                    end
                end
            end
            
            received_message=BSCreceived_stream;
            %fprintf('BSC received message :: ');
            %disp(received_message);
            
        elseif (choice==2)
            
            %%BEC(Binary erasure channel)
            BECreceived_stream=encoded_message;
            pError=p(x);
            
            for i=1:1:n
                error_prob= rand < pError;
                %if rand function's value go beyond than pError errorevent value
                %become 1 and i th bit will be erased
                
                if(error_prob)
                    BECreceived_stream(i)=NaN;
                end
            end
         
            received_message=BECreceived_stream;
            
        else
            
            %%Gaussian channel
            s=1;
            rDecisionBoundary=0;
            
            Gaussian_received_msg=encoded_message;
            Gaussian_received_msg(Gaussian_received_msg == 0)= -s;
            Gaussian_received_msg(Gaussian_received_msg == 1)= s;
            
            % Matlab’s function randn generates Gaussian distributed random
            % variable with variance of 1. Multiply by sigma to make the variance
            % sigma^2
            p=randn;
            noise = sigma(x)*p;  % noise for particular SNR
            
            Gaussian_received_msg=Gaussian_received_msg + noise;
        
            received_message=Gaussian_received_msg;
        
        end
        
        %% Viterbi Decoder
        if(choice==1 || choice==2)
            
            %% Hard-decision Decoding
            
            NReceived_Message=zeros(1,length(received_message)/2);
           
            k=1;
            for i=1:1:length(received_message)
                if(isnan(received_message(i)) && encoded_message(i)==0)
                    received_message(i)=1;
                end
                if(isnan(received_message(i)) && encoded_message(i)==1)
                    received_message(i)=0;
                end
            end
            
            for i=1:2:length(received_message)
                NReceived_Message(k)=received_message(i)*10+received_message(i+1);
                k=k+1;
            end
            
            %here s1=00 s2=01 s3=10 s4=11
            
            %here i have taken s1 s2 s3 s4 insted of s0 s1 s2 s3
            %transitiontable=(s1 to s1=bit 0) Or (s1 to s3=bit 1)
            %                (s3 to s2=bit 0) or (s3 to s4=nit 1)
            %                like this..
            transition_table=[0 -1 1 -1;0 -1 1 -1;-1 0 -1 1;-1 0 -1 1];
            
            %for outputTable if we are on 00 and input bit 0 then output 00 or for
            %bit 1 output is 1 (which is row 1)
            output_table=[00 11;11 00;10 01;01 10];
            
            %Possible Next States for Current States;
            next_state=[1 3;1 3;2 4;2 4];
            
            
            path_matrix(1:4,1:length(NReceived_Message)+1)=-1;
            branch_matrix(1:4,1:length(NReceived_Message)+1)=99999;
            
            for i=0:1:length(NReceived_Message)
                
                if(i==0)
                    path_matrix(1,1)=1;
                    branch_matrix(1,1)=0;
                else
                    
                    for s=1:1:4
                        if(path_matrix(s,i)~=-1)
                            
                            next_state_1=next_state(s,1);
                            next_state_2=next_state(s,2);
                            
                            output1=output_table(s,1);
                            output2=output_table(s,2);
                            
                            H1=H_D(output1,NReceived_Message(i))+branch_matrix(s,i);
                            H2=H_D(output2,NReceived_Message(i))+branch_matrix(s,i);
                            
                            if( branch_matrix(next_state_1,i+1)>H1)&&(branch_matrix(next_state_1,i+1)~=99999)
                                branch_matrix(next_state_1,i+1)=H1;
                                path_matrix(next_state_1,i+1)=s;
                            end
                            
                            if(branch_matrix(next_state_1,i+1)==99999)
                                branch_matrix(next_state_1,i+1)=H1;
                                path_matrix(next_state_1,i+1)=s;
                            end
                            
                            if( branch_matrix(next_state_2,i+1)>H2)&&(branch_matrix(next_state_2,i+1)~=99999)
                                branch_matrix(next_state_2,i+1)=H2;
                                path_matrix(next_state_2,i+1)=s;
                            end
                            
                            if(branch_matrix(next_state_2,i+1)==99999)
                                branch_matrix(next_state_2,i+1)=H2;
                                path_matrix(next_state_2,i+1)=s;
                            end
                            
                        end
                    end
                end
            end
            
            %%Trace back part
            
            minh=min(branch_matrix(:,length(branch_matrix)));
            locminh=find(branch_matrix(:,length(branch_matrix))==minh);
            m=length(path_matrix);
            
            decoded_message=zeros(1,length(received_message)/2);
            
            %path = transition of states
            for l=m:-1:1
                if(l==m)
                    path(l)=locminh(1);
                else
                    path(l)=path_matrix(path(l+1),l+1);
                end
            end
            for l=1:1:length(path)-1
                decoded_message(l)=transition_table(path(l),path(l+1));
            end

        else
            %% Soft-decision Decoding
            
            transition_table=[0 -1 1 -1;0 -1 1 -1;-1 0 -1 1;-1 0 -1 1];
            
            %for outputTable if we are on 00 and input bit 0 then output 00 or for
            %bit 1 output is 1 (which is row 1)
            output_table=[-1 -1 1 1;1 1 -1 -1;1 -1 -1 1;-1 1 1 -1];
            
            %Possible Next States for Current States;
            next_state=[1 3;1 3;2 4;2 4];
            
            
            path_matrix(1:4,1:length(received_message)/2+1)=-1;
            branch_matrix(1:4,1:length(received_message)/2+1)=99999;
            branch_matrix(1,1)=0;branch_matrix(2,1)=Inf;branch_matrix(3,1)=Inf;branch_matrix(4,1)=Inf;
            z=1;
            
            for i=0:1:length(received_message)/2
                
                if(i==0)
                    path_matrix(1,1)=1;
                else
                    
                    for s=1:1:4
                        if(path_matrix(s,i)~=-1)
                            
                            next_state_1=next_state(s,1);
                            next_state_2=next_state(s,2);
                            
                            output1=[output_table(s,1),output_table(s,2)];
                            output2=[output_table(s,3),output_table(s,4)];
                            
                            H1=norm(output1-[received_message(z),received_message(z+1)])+branch_matrix(s,i);
                            H2=norm(output2-[received_message(z),received_message(z+1)])+branch_matrix(s,i);
                            
                            if( branch_matrix(next_state_1,i+1)>H1)&&(branch_matrix(next_state_1,i+1)~=99999)
                                branch_matrix(next_state_1,i+1)=H1;
                                path_matrix(next_state_1,i+1)=s;
                            end
                            
                            if(branch_matrix(next_state_1,i+1)==99999)
                                branch_matrix(next_state_1,i+1)=H1;
                                path_matrix(next_state_1,i+1)=s;
                            end
                            
                            if( branch_matrix(next_state_2,i+1)>H2)&&(branch_matrix(next_state_2,i+1)~=99999)
                                branch_matrix(next_state_2,i+1)=H2;
                                path_matrix(next_state_2,i+1)=s;
                            end
                            
                            if(branch_matrix(next_state_2,i+1)==99999)
                                branch_matrix(next_state_2,i+1)=H2;
                                path_matrix(next_state_2,i+1)=s;
                            end
                            
                        end
                    end
                end
                if(i~=0)
                    z=z+2;
                end
            end
            
            %%Trace back part
            
            minh=min(branch_matrix(:,length(branch_matrix)));
            locminh=find(branch_matrix(:,length(branch_matrix))==minh);
            m=length(path_matrix);
            
            decoded_message=zeros(1,length(received_message)/2);
            
            %path = transition of states
            for l=m:-1:1
                if(l==m)
                    path(l)=locminh(1);
                else
                    path(l)=path_matrix(path(l+1),l+1);
                end
            end
            for l=1:1:length(path)-1
                decoded_message(l)=transition_table(path(l),path(l+1));
            end
        end
        
        Nerr = sum(xor(decoded_message,User_message(3:length(User_message))));
            Perr = Nerr/(Nsim) ;
            BER(x,y)=Perr;
            % resetting the values
            Nerr=0;
    end
    if(mod(x+1,3)==0)
       string=[num2str(floor(((x+1)/18)*100)) ,'% decoding completed ...'];
       disp(string);
    end
end
NewBER = mean(BER,2);
NewBER = transpose(NewBER);

close all;
figure(1);
semilogy(SNRdB,NewBER,'linewidth',2);
xlabel('SNR (Signal To Noise Ratio) in dB Scale');
ylabel('BER variying with different values of SNR');
grid on;


