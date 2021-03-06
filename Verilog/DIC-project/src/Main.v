`timescale 1 ms / 100 us

module camera_control(init, reset, clk, exp_inc, exp_dec, nre1, nre2, adc, expose, erase);	 
	
	input init, reset, clk, exp_inc, exp_dec;
	
	output nre1, nre2, adc, expose, erase;	 
	
	wire init, reset, clk, exp_inc, exp_dec;													 
	
	
	
	reg nre1, nre2, adc, expose, erase;		
	reg exp_finished, adc_conversion_finished, adc_conversion_state;	 //Exp_finished = TRUE when the camera is finished exposing, adc_conversion_finished = TRUE when the ADC-conversion is done
	//adc_conversion_state = TRUE when the first inputs have been read and translated
	
	parameter state_array_size = 2, exp_array_size = 5;			//The number of states is 3, so 2 bit is designated for the state-coutner. The exposure-time is max. 30ms, so a 5-bit register is needed.
	parameter num_adc_read_cycles = 3, adc_array_size = 2;		//The number of clock cycles the ADC has to read the input. Assumed to be 3ms. The array size for the adc-counter is 2-bit.
	parameter idle = 2'b00, capture = 2'b01, convert = 2'b11;   //Defining the different states of the state-machine.
	
	reg [state_array_size-1:0] state; 							//Array for the different states
	reg [exp_array_size-1:0] exp_time;							//Array for the exposure time
	reg [exp_array_size-1:0] exp_count;				  			//Array for the exposure time counter
	reg [adc_array_size-1:0] adc_read_cycle;					//Array for the number of read-cycle counter for the ADC
	
	always @(posedge clk)
		begin: FSM
			if (reset == 1'b1) begin	  						  //Reset is active-high. Resets all output variables.
					$display ("Reset enabled");
					state <= idle;
					nre1 <= 1;
					nre2 <= 1;
					adc <= 0;
					expose <= 0;
					erase <= 1;	
					exp_time <= 15;	  
			end else
				case(state)
					idle: 				
						if (init == 1'b1 && reset == 1'b0) begin									
								$display ("Initialising");							//Change state to Capture when idle is high.
								exp_finished <= 0;									//Reset all internal counters when initiating.
								exp_count <= 0;
								adc_conversion_finished <= 0;	
								adc_conversion_state <= 0;	
								adc_read_cycle <= 0;
								state <= capture;
						end else if (exp_inc == 1'b1 && exp_dec == 1'b0 && init == 1'b0) begin		//Increase the exposure time with 1ms every clock cycle the button is pressed	
								if (exp_time < 30) begin	 					  					//as long as the exposure time is smaller than 30.
										$display ("Exposure time increased by 1");
										exp_time <= exp_time + 1;						   
									end
						end else if (exp_dec == 1'b1 && exp_inc == 1'b0 && init == 1'b0) begin	   	//Decrease the exposure time with 1ms every clock cycle the button is pressed
								if (exp_time > 2) begin												//as long as the exposure time is bigger than 2.
										$display ("Exposure time decreased by 1");
										exp_time <= exp_time - 1;	
									end	 	
						end else begin
								$display ("State: Idle");							//Enable erase when idle.           
								erase <= 1;	  
								
							end
					capture:										  
						if (exp_finished == 0) begin	   
								$display ("Expose = 1, Erase = 0");
								expose <= 1;							   //The camera is in expose-mode until the counter exp_count has reached the specified exposure time.
								erase <= 0;
								if (exp_count < exp_time) begin			   //The count can be done every clock cycle as long as the clock frequency is equal to the change in time.
										exp_count <= exp_count + 1;
										$display ("Exposing");
								end else if (exp_count >= exp_time) begin  
										expose <= 0;
										exp_finished <= 1;
										$display("Exposure finished");
										state <= convert;					  //After the exposure is done the state-machien goes into the conversion state.
									end	  
							end	
					convert:
						if (adc_conversion_finished == 0) begin									//As long as the conversion is not done, the program converts from the two rows of 
								$display("Converting");											//amplifiers. Which row is read is controlled by adc_conversion_state which is 0 for row
								if (adc_conversion_state == 0) begin							//1 and 1 for row 2. 
										$display("Converting row 1");
										if (adc_read_cycle < num_adc_read_cycles) begin	  			//The ADC has 5 clock cycles to read the output of the amplifiers. This is not required																		
												if (adc_read_cycle == 1) begin 							//by the assignment. When the counter has not reached the limit, the ADC and NRE1/2 signal
														adc <= 1;											//is active. (The NRE gets 0 as it is a PMOS).
												end else begin
														adc <= 0;
													end
												nre1 <= 0;												 
												adc_read_cycle <= adc_read_cycle + 1;					
										end else if (adc_read_cycle >= num_adc_read_cycles) begin	//After the ADC has read for 5 cycles,  the ADC is turned off to give it a rest between reading 																	
												nre1 <= 1;												//samples. The conversion state is changed and the cycle counter is reset.
												adc_conversion_state <= 1;
												adc_read_cycle <= 0;	   
											end
									end	
								if (adc_conversion_state == 1) begin  							//The same as row 1, but after it is finished reading the ADC-conversion is complete
										$display("Converting row 2");								//and the state is changed to idle.
										if (adc_read_cycle < num_adc_read_cycles) begin	  
												if (adc_read_cycle == 1) begin 
														adc <= 1;
												end else begin
														adc <= 0;
													end
												nre2 <= 0;		
												adc_read_cycle <= adc_read_cycle + 1;  	
										end else if (adc_read_cycle >= num_adc_read_cycles) begin	 
												nre2 <= 1;
												adc_conversion_finished <= 1;  
											end
									end
							end		
						else if (adc_conversion_finished == 1) begin	
								$display("Conversion finished");					 			//After the conversion is finished the state goes to idle again, resetting the counters and erasing
								state <= idle;												  	//the charge from the capacitors.
								erase <= 1;
							end
				endcase			
		end	
	
	
endmodule	