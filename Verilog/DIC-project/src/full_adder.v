					 				//Initial Verilog program 
/*
module Full_Adder(
	input A,
	input B,
	input C,
	output Co,
	output S
	);

assign {Co, S} = C + A + B;	

endmodule
*/

`timescale 1ns/100ps

module Full_Adder_8bit(A,B,Cin,S,Co);

input [7:0]A;

input [7:0]B;

input Cin;
wire [6:0]C;

output Co;

output [7:0]S;

Full_Adder a1(A[0],B[0],Cin,S[0],C[0]);
Full_Adder a2(A[1],B[1],C[0],S[1],C[1]);
Full_Adder a3(A[2],B[2],C[1],S[2],C[2]);
Full_Adder a4(A[3],B[3],C[2],S[3],C[3]);
Full_Adder a5(A[4],B[4],C[3],S[4],C[4]);
Full_Adder a6(A[5],B[5],C[4],S[5],C[5]);
Full_Adder a7(A[6],B[6],C[5],S[6],C[6]);
Full_Adder a8(A[7],B[7],C[6],S[7],Co);

endmodule

module Full_Adder(A,B,C,S,Co);	  

input A;
input B;
input C;
output S;
output Co;
	

assign #1 S = A ^ B ^ C;
assign #0.5 Co = (A & B) | (B & C) | (A & C);


endmodule
