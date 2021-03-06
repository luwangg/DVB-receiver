%This is a tutorial document. 
%It's an implementation of the sum-product and min-sum algorithms in 
%MATLAB for a small LDPC code in order to learn the algorithms. 
%The LDPC codes used in DVB-S2/X are different and the models 
%will be in a different file.

%by Abraxas3d updated at GRCon2018 as a test.

m = 2;
%for modulo 2 arithmetic

p = [0 0 0 0 0 1 0];
CM = gallery('circul',p);
%returns the circulant matrix whose first row is the vector v.

Z = zeros(length(p),length(p));

RC_compliant = [CM, CM ; CM, Z];
%creates a row-column compliant matrix


%A matrix over GF(q) for which no two columns or two rows have more
%than one location where they both have nonzero entries is said to 
%satisfy the row-column constraint.

%for a k by t matrix A over GF9q) we label the rows and columns
%0 to k-1 and 0 to t-1 and a(i, j) is the entry at i, j. 

%An LDPC code over a finite field GF(q) is a q-ary linear block code
%given by the null space of a sparse parity check matrix H over GF(q). 

%an LDPC code is regular if H has constant row and column weight.

%bipartite graph: 
%Variable Nodes are the columns of H
%Check Nodes are the rows of H.
%If they share a non-zero entry, then they are connected. 

%The LDPC code C is the null space of H.

%The n VNs represent the n code symbols of a codeword in C. zz
%The m CNs represent the m parity check constraints 
%that the code symbols must satisfy.

%The number of edges incident with a VN or a CN in the Tanner graph
%is called the degree of that node. 
%The degree of VN(j) equals the wight of the jth column of H
%The degree of CN(i) equals the weight of the ith row of H. 

%A path is defined as an alternating sequence of nodes and edges, 
%beginning and ending with nodes. 
%Number of edges on a path is the length of the path. 
%A closed path that begins and ends on the same node is a cycle. 
%A cycle path is even. It has an even number of edges. 
%There are no paths of length 2.
%The length of the shortest cycle in the graph is teh girth of the graph. 

%If we construct a matrix H that is row-column compliant, 
%Then the Tanner graph of the code C contains no cycle of length 4 
%and it's girth is at least 6.

%Example page 10 "LDPC Code Designs, Constructions, and Unification"
%There are J rows, h0 through h4
% sj = e dot product hj, which is zero when no errors.

% v0 = s0, s1
% v1 = s0, s2
% v2 = s0, s3
% v3 = s0, s4
% v4 = s1, s2
% v5 = s1, s3
% v6 = s1, s4
% v7 = s2, s3
% v8 = s2, s4
% v9 = s3, s4




H = [1 1 1 1 0 0 0 0 0 0;
     1 0 0 0 1 1 1 0 0 0;
     0 1 0 0 1 0 0 1 1 0;
     0 0 1 0 0 1 0 1 0 1;
     0 0 0 1 0 0 1 0 1 1]
 


%Columns of H are the VNs. 
%The LDPC code C is the null space of H.

%The VNs are the n code symbols of a codeword in code C. 
%The number of VNs that connect to the VN vj by paths of length 2 is called
%the connection number of the VN vj. The connection numbers of VNs in the
%Tanner graph give a measurement of the Connectivity of the graph. Constant
%colm weight and row weight mean all the VNs have the same connection
%number. They all reach the same number of VNs, by paths of length 2. 

C = null(H, 'r');

C = mod(C, m);

%C = null(H) is an orthonormal basis for the null space of H obtained 
%from the singular value decomposition. That is, H*C has negligible 
%elements, size(C,2) is the nullity of H, and transpose(C)*C = I.

%Null Space
%Every vector in the null space is orthogonal to every vector in the 
%original space. Every vector inner product, when taking any vector from 
%the original space and multiplying it by a vector in the null space, is 0.

%C is the set of all codewords in the null space of an n-k by n matrix H,
%whose rank is n-k. 

check_null_space = H*C;

check_null_space = mod(check_null_space, m);

vector_check = [1 0 1 1 1]*[0; 0; 0; 1; 1];
vector_check = mod(vector_check, m);


Ce1 = C + [1     0     1     1     1;
           1     0     0     0     1;
           1     0     0     0     1;
           0     1     0     0     1;
           1     1     1     1     1;
           0     1     0     0     0;
           0     0     1     0     0;
           0     0     0     1     0;
           0     0     0     0     1;
           0     0     0     0     1];
       
       
%OK so now we have some error patterns detected. 
%first five rows, diagonalf flip.
%second five rows, walking pair of errors.
%last row, no errors. 
       
test_tanner_graph = Ce1*H;
test_tanner_graph = mod(test_tanner_graph, m);


%From Error Control Coding by Lin, Costello, page 876
%Initialization

J = 5; %number of rows in H, which is the number of check nodes
n = 10; %number of columns in H, which is the number of bits in codeword

j = 0; %index for J
l = 0; %index for n

Imax = 10; %maximum number of iterations to go through before declaring
%a hard decision

q_zero = zeros(J, n); %matrix of probabilities that entries are zero.
q_one = zeros(J, n);  %matrix of probabilities that entries are one.
%these matrices have non-zero entries that correspond 
%to the entries in the parity check matrix. 

B = zeros(J, n); %support of hj. Where there's a one, put the bit index.
A = zeros(J, n); %sets of orthogonal parity check matrix rows

Al = zeros(J, n, 2); %warning, hardcoded 2. Holds all the Al sets.

sigma_zero = zeros(J, n); %used to update probabilities
sigma_one = zeros(J, n); %used to update probabilities

alpha_zero = zeros(J, n); %used to update probabilities
alpha_one = zeros(J, n); %used to update probabilities

for I = transpose(H)
    j = j + 1; %start at row 1 becuase of the way MATLAB indexes
    %disp('Current row:')
    %disp(j)
    %disp(I)
    for l = 1:1:length(I) %run through each bit starting at bit 1
        %disp('Current bit in this row:')
        %disp(I(l))
        if (I(l)) == 1
            %disp('I found a one')
            %if there's a one, then create a q_zero and a q_one entry
            %set the a priori probability for that entry. Isn't it 0.5?
            q_zero(j,l) = 0.5;
            q_one(j,l) = 0.5;
            %Also create the "support" of hj in a matrix B
            B(j,l) = l;
            
        end
    end
end

%disp('q of j,l is 0')
sparse_q_zero = sparse(q_zero);
%disp(sparse_q_zero)
%disp('q of j,l is 1')
sparse_q_one = sparse(q_one);
%disp(sparse_q_one)
sparse_B = sparse(B);
%disp(sparse_B)



%learn how to manipulate sparse matrices
%sparse_q_one(5,9) = 983299
%[i,j,s] = find(A) generates new matrix of non-zero entries in A
%worked out well, will help make for clean reduced-memory use
%indexing of the probabilities. 



%For every bit position l, there is a set of of rows in H that are
%that are orthogonal on this bit position. These sets are called Al.
%Gather up sets based on rows that have a one at bit position l. 
%Any row with a one in bit position l goes into Al.
%Take any column from matrix A. The non-zero entries in the column
%are the rows that you need from the matrix H that check that column's 
%bit position. 

% A0 = [s0 s1]
% A1 = [s0 s2]
% A2 = [s0 s3]
% A3 = [s0 s4]
% A4 = [s1 s2]
% A5 = [s1 s3]
% A6 = [s1 s4]
% A7 = [s2 s3]
% A8 = [s2 s4]
% A9 = [s3 s4]

% A0 = [H(1,:); H(2,:)]
% A1 = [H(1,:); H(3,:)]
% A2 = [H(1,:); H(4,:)]
% A3 = [H(1,:); H(5,:)]
% A4 = [H(2,:); H(3,:)]
% A5 = [H(2,:); H(4,:)]
% A6 = [H(2,:); H(5,:)]
% A7 = [H(3,:); H(4,:)]
% A8 = [H(3,:); H(5,:)]
% A9 = [H(4,:); H(5,:)]

l = 0; %important to initialize the bit position to zero
for I = H
    l = l + 1; %start at column 1 becuase of the way MATLAB indexes
    %disp('Current column:')
    %disp(l)
    %disp(I)
    for j = 1:1:length(I) %run through each bit starting at bit 1
        %disp('Current bit in this column:')
        %disp(I(j))
        if (I(j)) == 1
            %disp('I found a one')
            %disp('replace it with j:')
            %disp(j)
            %if there's a one, then mark an entry for A
            A(j,l) = j;
            
        end
    end
end

A

l = 0; %important to initialize the bit position to zero
r = 0; %number of rows of H per entry in Al

%v = genvarname({'A', 'A', 'A', 'A'})


for I = A %take columns of A
    r = 1; %page counter. starts at column 1 because of the way MATLAB indexes
    l = l + 1; %column counterstarts at column 1 because of the way MATLAB indexes
    %this value l is the l in Al
    for j = 1:1:length(I) %run through each bit of the column starting at bit 1
        if ne(I(j), 0) %if we have a non-zero entry, then us it to get that row j from H and put it in Al
        txt = sprintf('A%d', l);
        %disp(txt) %the Al we are building up
        %disp(I(j)) %the nonzero jth element of the lth column of A
        %disp(H(j,:)) %the jth row of H
        %"The preferred method is to store related data in a single array.
        Al(l, :, r) = H(j,:);
        r = r + 1; %advance to next page within Al. Column not reloaded yet.
        
        end
    end
end


Al


%There's another index set involved, called B(hj) or "support of hj"
%we made it before by looping through H.
%each row of B turns each 1 of the row of H into the column position.
%In this row, this particular column position l has a 1. 
%then make it sparse
%now we use the supports of hj to index the summation and product of sigma
%Using sparse(B) may be much more efficient. Indexing is confusing though.


B

for Row = transpose(B) %for each row of B
    %disp(Row)
    %disp('New Row')
    for show = transpose(Row) %for each element in that row of B
        %disp('element')
        if ne(show, 0) %the nonzero element in a row of B
            %is the bit place in that row where we had 
            %a non-zero entry in H.
            %how does this help??
            
            %disp('New Element')
            %disp(show)
            
            
        end
        
        
        
    end
end


%for each bit position, for each row, and each hj in a set Al, 
%compute the probabilities of sigma_zero and sigma_one

%From Lin/Costello
%The implementation of sum product algorithm is based on the computation
%of the marginal a posteriori probabilities
%P(v of l given y)
%for l between zero and n, where y is the soft-decision received sequence.
%Then, the log liklihood ratio for each code bit is given by
%L(vl) = log [ (Pthat vl = 1 given y) / (P that vl = 0 given y) ]

%so there is a conditional probability (q) that the transmitted code bit vl has
%the value x, given the check-sums computed based on the check vectors in
%Al, not including hj, at the ith decoding iteration. 

%sigma_x is the conditional probability that the check-sum sj is satisfied
%given vl = x and the other code bites in H(hj) have a separable
%distribution (I think this is the q).


G = [1 1 0 1 0 0 0; 0 1 1 0 1 0 0; 1 1 1 0 0 1 0; 1 0 1 0 0 0 1]
vv = [1 0 1 1]*G;
vv = mod(vv,m)

HofG = null(G, 'r')
HofG = mod(HofG, m)

vcheck = [1 0 0 1 1 1 1]
mod(vcheck*HofG, m)

HofG = transpose(HofG)
%p(y|x=a)=1/sqrt(2*pi)*exp(-(y-a)^2/(2s))
%p(r|x=1)=1/sqrt(2*pi)*exp(-(y-1)^2/(2*0.1))


r= [-1.1	 -1.2	 -0.9	   -0.3	   -0.8	   -1.5	    -1.1	    -1.2	    -0.2	     -1.1]
entry = (2*r)/((0.1)*(0.1))
entry = abs(entry)/250


prob1 = (1/sqrt(2*pi))*exp((-(r-1).^2)/(2*0.1))
prob0 = (1/sqrt(2*pi))*exp((-(r+1).^2)/(2*0.1))

ach = [0.12, 0.04, 0.28, 0.59]
ach4 = ach(1)*(1-ach(2))*(1-ach(3)) + ach(2)*(1-ach(1))*(1-ach(3)) + ach(3)*(1-ach(1))*(1-ach(2)) + ach(1)*ach(2)*ach(3)
ach3 = ach(1)*(1-ach(2))*(1-ach(4)) + ach(2)*(1-ach(1))*(1-ach(4)) + ach(4)*(1-ach(1))*(1-ach(2)) + ach(1)*ach(2)*ach(4)
ach2 = ach(1)*(1-ach(4))*(1-ach(3)) + ach(4)*(1-ach(1))*(1-ach(3)) + ach(3)*(1-ach(1))*(1-ach(4)) + ach(1)*ach(4)*ach(3)
ach1 = ach(4)*(1-ach(2))*(1-ach(3)) + ach(2)*(1-ach(4))*(1-ach(3)) + ach(3)*(1-ach(4))*(1-ach(2)) + ach(4)*ach(2)*ach(3)
