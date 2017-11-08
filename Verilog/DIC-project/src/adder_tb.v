`timescale 1ns / 100ps 
 
module fulladdertb; 
 
reg [7:0]input1;
reg [7:0]input2;
reg carryin;
 
wire [7:0]out;
wire carryout;
 
 
Full_Adder_8bit uut (
.A(input1),
.B(input2),
.Cin(carryin),
.S(out),
.Co(carryout)
);
 
initial
begin
input1 =00000000;
input2 =00000000;
carryin =0;
#20; input1 =8'b00000000;
#20; input2 =8'b00000000;
#20; input1 =8'b00000000;
#20; input1=8'b11111111; 
#20; carryin =1'b1;
#20; input2=8'b00000000;
#40;
end
 
 
initial
begin
$monitor("time = %2d, CIN =%1b, IN1=%1b, IN2=%1b, COUT=%1b, OUT=%1b", $time,carryin,input2, input1,carryout,out);
end
 
endmodule