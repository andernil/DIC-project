//-----------------------------------------------------------------------------
//
// Title       : camera_tb
// Design      : DIC-project
// Author      : Anders
// Company     : NTNU
//
//-----------------------------------------------------------------------------
//
// File        : c:\Users\Anders\Documents\AIM-spice\DIK-project\Verilog\DIC-project\src\camera_tb.v
// Generated   : Wed Nov  8 12:06:36 2017
// From        : interface description file
// By          : Itf2Vhdl ver. 1.22
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------
`timescale 1 ms / 100 us	   //Timescale of 1ms as it is the clock frequency


module camera_tb;

reg init_in, reset_in, clk_in, exp_inc_in, exp_dec_in;

wire nre1_out, nre2_out, adc_out, expose_out, erase_out;

parameter size = 2, exp_size = 5;			  


camera_control uut(			//Map the inputs and outputs of the testbench to the module
.init(init_in),
.reset(reset_in),
.clk(clk_in),
.exp_inc(exp_inc_in),
.exp_dec(exp_dec_in),
.nre1(nre1_out),
.nre2(nre2_out),
.expose(expose_out),
.erase(erase_out),
.adc(adc_out)
);			   

always
#0.5 clk_in = ~clk_in; // Generate a clock signal at 1kHz

initial
begin	
	clk_in = 1'b0;		   	//Reset clock
  	reset_in = 1'b1;		
  	#1; reset_in = 1'b0;	//Reset is active-low
	#1; reset_in = 1'b1;
	#1; exp_inc_in = 1'b1;	//Increase exposure time 1ms for each clock cycle
	#20;		   			//Wait 20ms before continuing, giving an exposure time of 30ms.
	#1; init_in = 1'b1;	    //Initialise the camera operation
	#1; init_in = 1'b0;
	#40;
	$finish;				//$finish to stop the simulation after the 40ms delay
end

initial
begin		  				//Define the monitor outputs. Writes the different states to the console. Using uut.variable enables the monitoring of internal signals in the camera controller
$monitor("time = %2d, clk_in =%b, init_in=%b, reset_in=%b, exp_inc_in=%b, exp_dec_in=%b, nre1_out=%b, nre2_out=%b, expose_out=%b, erase_out=%b, adc_out= %b, exp_time= %d, exp_count = %d, adc_read_cycle = %d", $time,clk_in,init_in,reset_in,exp_inc_in,exp_dec_in,nre1_out,nre2_out,expose_out,erase_out,adc_out,uut.exp_time, uut.exp_count, uut.adc_read_cycle);
end
endmodule
