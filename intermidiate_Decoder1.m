%convolutionaldecoder
%In Ecoder We Use 1101 and 1111 polynomial

function output = intermidiate_Decoder1(input)

n=length(input)/2;
trailis=20*ones(8,n+1);   % here 20 means infinite
trailis(1,1)=0;
k=2;
code=zeros(1,2);
output=zeros(1,n);         %output arrays

%Making Trailis
%Here state A = "000"
%     state B = "001"
%     state C = "010"
%     state D = "011"
%     state E = "100"
%     state F = "101"
%     state G = "110"
%     state H = "111"

for i=1:2:2*n
    code(1,1)=input(1,i);
    code(1,2)=input(1,1+i);
    
    %state A
    h_distance1 = HammingDistance(code,[0 0]);  %for CHECKING HAMMING_DISTANCE WE USE FUNCTION
    h_distane2 = HammingDistance(code,[1 1]);
    trailis(1,k) = min(h_distance1+trailis(1,k-1),h_distane2+trailis(2,k-1)); 
                   %Assign minimum HammingDistance for Reach State A 

    %state B
    h_distance1 = HammingDistance(code,[0 1]);
    h_distane2 = HammingDistance(code,[1 0]);
    trailis(2,k) = min(h_distance1+trailis(3,k-1),h_distane2+trailis(4,k-1)); 
                  %Assign minimum HammingDistance for Reach State B 
    
    %state C
    h_distance1 = HammingDistance(code,[1 1]);
    h_distane2 = HammingDistance(code,[0 0]);
    trailis(3,k) = min(h_distance1+trailis(5,k-1),h_distane2+trailis(6,k-1)); 
                     %Assign minimum HammingDistance for Reach State C 
    
    %state D
    h_distance1 = HammingDistance(code,[1 0]);
    h_distane2 = HammingDistance(code,[0 1]);
    trailis(4,k) = min(h_distance1+trailis(7,k-1),h_distane2+trailis(8,k-1));
                     %Assign minimum HammingDistance for Reach State D 
     
    %state E
    h_distance1 = HammingDistance(code,[1 1]);
    h_distane2 = HammingDistance(code,[0 0]);
    trailis(5,k) = min(h_distance1+trailis(1,k-1),h_distane2+trailis(2,k-1)); 
                    %Assign minimum HammingDistance for Reach State E 
    
    %state F
    h_distance1 = HammingDistance(code,[1 0]);
    h_distane2 = HammingDistance(code,[0 1]);
    trailis(6,k) = min(h_distance1+trailis(3,k-1),h_distane2+trailis(4,k-1)); 
                    %Assign minimum HammingDistance for Reach State F 
    
    %state G
    h_distance1 = HammingDistance(code,[0 0]);
    h_distane2 = HammingDistance(code,[1 1]);
    trailis(7,k) = min(h_distance1+trailis(5,k-1),h_distane2+trailis(6,k-1));
                   %Assign minimum HammingDistance for Reach State G 
    
    %state H
    h_distance1 = HammingDistance(code,[0 1]);
    h_distane2 = HammingDistance(code,[1 0]);
    trailis(8,k) = min(h_distance1+trailis(7,k-1),h_distane2+trailis(8,k-1)); 
                    %Assign minimum HammingDistance for Reach State H 
                    
    k=k+1;
end
fprintf(" trailis is :\n");
disp(trailis);

%back Tracking trailis

m=trailis(1,n+1);
i=n+1;
state=1;
for k=1:8                %find Minimum Haming Distance in Last Coloum     
     if m >=trailis(k,i)   
         m=trailis(k,i);
         state=k;
     end 
end

for i=n:-1:1
    
     %Detect Output Using PathMatrix
     
   %state A
     if state==1           %If We Arrive at state A if the Input bit is 0 So output Will be 0
        
       output(1,i)=0;
       
       if trailis(1,i)<=trailis(2,i)  %For Arrive  at Stage A There Are only Two Path So Find
           state=1;                   %Minimum State Matric
       end
       
       if trailis(2,i)<trailis(1,i)
           state=2;
       end 
   
   %state B
   
     elseif state==2
       
          output(1,i)=0;    %If We Arrive at state B if the Input bit is 0 So output Will be 0
       
       if trailis(3,i)<=trailis(4,i)  %For Arrive  at Stage B There Are only Two Path So Find
           state=3;                    %Minimum State Matric                    
       end
       
       if trailis(4,i)<trailis(3,i)
           state=4;
       end 
       
   %state C
   
     elseif state==3
       
          output(1,i)=0;  %If We Arrive at state C if the Input bit is 0 So output Will be 0
       
       if trailis(5,i)<=trailis(6,i) %For Arrive  at Stage C There Are only Two Path So Find
           state=5;                  %Minimum State Matric
       end
       
       if trailis(6,i)<trailis(5,i)
           state=6;
       end
       
    %state D
   
     elseif state==4   %If We Arrive at state D if the Input bit is 0 So output Will be 0
       
          output(1,i)=0;
       
       if trailis(7,i)<=trailis(8,i) %For Arrive  at Stage D There Are only Two Path So Find
           state=7;                  %Minimum State Matric
       end
       
       if trailis(8,i)<trailis(7,i)
           state=8;
       end
       
     %state E
       elseif state==5
        
         output(1,i)=1;  %If We Arrive at state E if the Input bit is 1 So output Will be 1
       
       if trailis(1,i)<=trailis(2,i) %For Arrive  at Stage E There Are only Two Path So Find
           state=1;                  %Minimum State Matric
       end
       
       if trailis(2,i)<trailis(1,i)
           state=2;
       end 
   
   %state F
   
     elseif state==6   
       
          output(1,i)=1;  %If We Arrive at state F if the Input bit is 1 So output Will be 1
       
       if trailis(3,i)<=trailis(4,i) %For Arrive  at Stage F There Are only Two Path So Find
           state=3;                  %Minimum State Matric
       end
       
       if trailis(4,i)<trailis(3,i)
           state=4;
       end 
       
   %state G
   
     elseif state==7
       
          output(1,i)=1;  %If We Arrive at state G if the Input bit is 1 So output Will be 1
       
       if trailis(5,i)<=trailis(6,i) %For Arrive  at Stage G There Are only Two Path So Find
           state=5;                  %Minimum State Matric
       end
       
       if trailis(6,i)<trailis(5,i)
           state=6;
       end
       
    %state H
   
     elseif state==8
       
          output(1,i)=1;  %If We Arrive at state H if the Input bit is 1 So output Will be 1
       
       if trailis(7,i)<=trailis(8,i) %For Arrive  at Stage H There Are only Two Path So Find
           state=7;                  %Minimum State Matric
       end
       
       if trailis(8,i)<trailis(7,i)
           state=8;
       end
     end
 end
 output
end
       
  
   
   
    
    
    