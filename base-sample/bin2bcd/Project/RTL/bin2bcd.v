//-----------------------------------------------------------------------------------
// DESCRIPTION   :  Bin to Bcd converter
//                  Input (data_in) width : 4
//                  Output (data_out) width : 8
//                  Enable (EN) active : high
//
//-----------------------------------------------------------------------------------

module bin2bcd (
                data_in ,
                EN      ,
                data_out
                );

input  [3:0]  data_in   ;
input        EN         ;
output [7:0] data_out   ;
reg    [7:0] data_out   ;

always @(*) begin
    data_out = {8{1'b0}};                        // assign data_out is 0 when no other assign 
	if (EN == 1) begin
		case (data_in [3:1]) 
			3'b000 : data_out [7:1] = 7'b0000000;
			3'b001 : data_out [7:1] = 7'b0000001;
			3'b010 : data_out [7:1] = 7'b0000010;
			3'b011 : data_out [7:1] = 7'b0000011;
			3'b100 : data_out [7:1] = 7'b0000100;
			3'b101 : data_out [7:1] = 7'b0001000;
			3'b110 : data_out [7:1] = 7'b0001001;
			3'b111 : data_out [7:1] = 7'b0001010;
			default : data_out [7:1] = {7{1'b0}};
		endcase
		data_out [0] = data_in [0];
	end
end

endmodule

