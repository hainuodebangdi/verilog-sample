/****************************************Copyright (c)**************************************************
**                                      Dongdong   Studio 
**                                     
**---------------------------------------File Info-----------------------------------------------------
** File name:           lm75_rd
** Last modified Date:  2012-10-25
** Last Version:        1.1
** Descriptions:        lm75_rd
**------------------------------------------------------------------------------------------------------
** Created by:          dongdong
** Created date:        2009-11-11
** Version:             1.0
** Descriptions:        The original version
**
**------------------------------------------------------------------------------------------------------
** Modified by:			
** Modified date:		
** Version:				
** Descriptions:		
**
**------------------------------------------------------------------------------------------------------
********************************************************************************************************/
module lm75_rd ( 
              //input 
              sys_clk           ,
              sys_rst_n         ,

              sda_port          ,
              //output 
              LED               , 
              clk_sclk          
              );

//input ports

input                    sys_clk             ;    //system clock;
input                    sys_rst_n           ;    //system reset, low is active;
inout                    sda_port            ;  
 
//output ports
output                   clk_sclk            ;

output reg [7:0]         LED                 ;

//reg define 
reg    [WIDTH-1:0]       counter             ;
reg    [9:0]             counter_div         ;

reg                      clk_50k             ;
reg                      clk_200k            ;

reg                      clk_sclk            ;

reg                      sda                 ;

reg                      enable              ;

reg    [WIDTH-1:0]       data_out            ;

reg    [31:0]            counter_init        ;     
  
reg    [10:0]            buff                ;  

//wire define 

wire   [2:0]             device_addr         ;

wire                     sda_input           ;

//parameter define 
parameter WIDTH = 8;
parameter SIZE  = 8;

/*******************************************************************************************************
**                              Main Program    
**  
********************************************************************************************************/

//lm75 device address is 000, this value is no care ;
assign device_addr = 3'b000;       

// counter for gen a clk_50k : need count to 1000, for 50M/1000 = 50K hz 
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            counter_div <= 10'b0;
        else if (counter_div >= 10'd999)
            counter_div <= 10'b0;
        else
            counter_div <= counter_div + 10'b1;
end

// gen a clk_50k use counter_div :  not use counter_div 0 - 500 is for i2c bus request start timing 
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            clk_50k <= 10'b0;
        else  if ((counter_div >= 375) && (counter_div < 875))    
            clk_50k <= 10'b1;
        else
            clk_50k <= 10'b0;
end

// counter for init for LM75A 
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            counter_init <= 32'h0;
        else if ( counter_init < 32'h5f5e100 ) 
            counter_init  <= counter_init + 32'b1;            
        else ;                  
end

// gen a 200K CLK for work counter count
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            clk_200k <= 10'b0;
        else  if ((counter_div >= 0  ) && (counter_div < 125))
            clk_200k <= 10'b0;
        else  if ((counter_div >= 125) && (counter_div < 250))
            clk_200k <= 10'b1;  
        else  if ((counter_div >= 250) && (counter_div < 375))
            clk_200k <= 10'b0;                        
        else  if ((counter_div >= 375) && (counter_div < 500))
            clk_200k <= 10'b1;
        else  if ((counter_div >= 500) && (counter_div < 625))
            clk_200k <= 10'b0;
        else  if ((counter_div >= 625) && (counter_div < 750))
            clk_200k <= 10'b1;  
        else  if ((counter_div >= 750) && (counter_div < 875))
            clk_200k <= 10'b0;                        
        else  if ((counter_div >= 875) && (counter_div < 1000))
            clk_200k <= 10'b1;    
        else ;
end

// when LM75A init finish, work counter start to add
always @(posedge clk_200k or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            counter <= 8'h0;
        else if ( counter_init == 32'h5f5e100 )
            counter <= counter + 8'b1; 
        else ;    
end

//generate real clk for SCLK ,when the i2c bus is idle, make the clk wire high level
always @(*) begin 
        if ( counter >= 2 && counter <= 118 )
            clk_sclk = clk_50k;
        else  
            clk_sclk = 1'b1;
end

// output SDA data with LM75 data sheet request 
always @(*) begin 
    case ( counter )
          0 : sda = 1'b1 ;       
          1 : sda = 1'b1 ;          
          2 : sda = 1'b1 ;       
          3 : sda = 1'b0 ;               
          4 : sda = 1'b0 ;              //SOP
             
          5 : sda = 1'b1 ;             
          6 : sda = 1'b1 ;             
          7 : sda = 1'b1 ;             
          8 : sda = 1'b1 ;              // 1
                                       
          9 : sda = 1'b0 ;             
         10 : sda = 1'b0 ;             
         11 : sda = 1'b0 ;              
         12 : sda = 1'b0 ;              //0
                                       
         13 : sda = 1'b0 ;             
         14 : sda = 1'b0 ;             
         15 : sda = 1'b0 ;             
         16 : sda = 1'b0 ;               //0
                                       
         17 : sda = 1'b1 ;             
         18 : sda = 1'b1 ;             
         19 : sda = 1'b1 ;                      
         20 : sda = 1'b1 ;               //1  
                                       
                                       
         21 : sda = device_addr[2] ;         
         22 : sda = device_addr[2] ;      
         23 : sda = device_addr[2] ;       
         24 : sda = device_addr[2] ;               
                                       
         25 : sda = device_addr[1] ;         
         26 : sda = device_addr[1] ;      
         27 : sda = device_addr[1] ;              
         28 : sda = device_addr[1] ;     
                                       
         29 : sda = device_addr[0] ;         
         30 : sda = device_addr[0] ;      
         31 : sda = device_addr[0] ;         
         32 : sda = device_addr[0] ;   
 
        33 : sda = 1'b1 ;                
        34 : sda = 1'b1 ;       
        35 : sda = 1'b1 ;          
        36 : sda = 1'b1 ;                         // read LM75A ,bit[0] =  1  
         
        33 + 4 : sda = 1'bz ;                
        34 + 4 : sda = 1'bz ;       
        35 + 4 : sda = 1'bz ;          
        36 + 4 : sda = 1'bz ;                     //ACK ,sda should be input 
        
        37 + 4 : sda = 1'bz ;               
        38 + 4 : sda = 1'bz ;       
        39 + 4 : sda = 1'bz ;         
        40 + 4 : sda = 1'bz ;                     //D7
           
        41 + 4: sda = 1'bz ;          
        42 + 4: sda = 1'bz ;       
        43 + 4: sda = 1'bz ;         
        44 + 4: sda = 1'bz ;                      //D6
              
        45 + 4: sda = 1'bz;          
        46 + 4: sda = 1'bz;       
        47 + 4: sda = 1'bz;               
        48 + 4: sda = 1'bz;                       //D5
                  
        49 + 4: sda = 1'bz ;         
        50 + 4: sda = 1'bz ;       
        51 + 4: sda = 1'bz ;          
        52 + 4: sda = 1'bz ;                      //D4
                  
        53 + 4: sda = 1'bz ;        
        54 + 4: sda = 1'bz ;       
        55 + 4: sda = 1'bz ;          
        56 + 4: sda = 1'bz ;                      //D3  
              
        57 + 4: sda = 1'bz ;               
        58 + 4: sda = 1'bz ;       
        59 + 4: sda = 1'bz ;         
        60 + 4: sda = 1'bz ;                      //D2 
                 
        61 + 4: sda = 1'bz ;          
        62 + 4: sda = 1'bz ;       
        63 + 4: sda = 1'bz ;                          
        64 + 4: sda = 1'bz ;                       //D1  
              
        65 + 4: sda = 1'bz ;          
        66 + 4: sda = 1'bz ;       
        67 + 4: sda = 1'bz ;               
        68 + 4: sda = 1'bz ;                       //D0
              
        69 + 4: sda = 1'b0 ;         
        70 + 4: sda = 1'b0 ;       
        71 + 4: sda = 1'b0 ;          
        72 + 4: sda = 1'b0 ;                      //Master ACK , output 0
             
        73 + 4: sda = 1'bz ;                                               
        74 + 4: sda = 1'bz ;                                               
        75 + 4: sda = 1'bz ;                                              
        76 + 4: sda = 1'bz ;                      //D7            
                                                                          
        77 + 4: sda = 1'bz ;                                              
        78 + 4: sda = 1'bz ;                                              
        79 + 4: sda = 1'bz ;                                              
        80 + 4: sda = 1'bz ;                      //D6             
                                                                           
        81 + 4: sda = 1'bz ;                                              
        82 + 4: sda = 1'bz ;                                              
        83 + 4: sda = 1'bz ;                                              
        84 + 4: sda = 1'bz ;                      //D5            
                                                                          
        85 + 4: sda = 1'bz ;                                              
        86 + 4: sda = 1'bz ;                                              
        87 + 4: sda = 1'bz ;                                              
        88 + 4: sda = 1'bz ;                       //D4            
                                                                           
        89 + 4: sda = 1'bz ;                                              
        90 + 4: sda = 1'bz ;                                              
        91 + 4: sda = 1'bz ;                                              
        92 + 4: sda = 1'bz ;                        //D3           
                                                                          
        93 + 4: sda = 1'bz ;                                              
        94 + 4: sda = 1'bz ;                                              
        95 + 4: sda = 1'bz ;                                              
        96 + 4: sda = 1'bz ;                         //D2          
                                                                           
        97 + 4: sda = 1'bz ;                                              
        98 + 4: sda = 1'bz ;                                              
        99 + 4: sda = 1'bz ;                                              
       100 + 4: sda = 1'bz ;                         //D1          
                                                                          
       101 + 4: sda = 1'bz ;                                              
       102 + 4: sda = 1'bz ;                                              
       103 + 4: sda = 1'bz ;                                              
       104 + 4: sda = 1'bz ;                          //D0          
                                                                          
       105 + 4: sda =   1'bz ;                                            
       106 + 4: sda =   1'bz ;             
       107 + 4: sda =   1'bz ;               
       108 + 4: sda =   1'bz ;                        //NO ACK       
       
       109 + 4: sda = 1'b0 ;                              
       110 + 4: sda = 1'b0 ;   
                               
       111 + 4: sda = 1'b1 ;                              
       112 + 4: sda = 1'b1 ;                        
       113 + 4: sda = 1'b1 ;                          //EOP 
    
       default :  sda = 1'bz ;                        // I2C bus is idle ,realse the I2c bus 
   endcase    
end

// output SDA data enable with LM75 data sheet request 
always @(*) begin 
    case (counter)      
         1 :     enable = 1'b1 ;          
         2 :     enable = 1'b1 ;       
         3 :     enable = 1'b1 ;               
         4 :     enable = 1'b1 ;               //SOP
         
         5 :     enable = 1'b1 ;                              
         6 :     enable = 1'b1 ;                                
         7 :     enable = 1'b1 ;                                  
         8 :     enable = 1'b1 ;               // 1               
                                                              
         9 :     enable = 1'b1 ;                                  
        10 :     enable = 1'b1 ;                                  
        11 :     enable = 1'b1 ;                                  
        12 :     enable = 1'b1 ;               //0                
                                                              
        13 :     enable = 1'b1 ;                                  
        14 :     enable = 1'b1 ;                                  
        15 :     enable = 1'b1 ;                                  
        16 :     enable = 1'b1 ;                //0               
                                                              
        17 :     enable = 1'b1 ;                                  
        18 :     enable = 1'b1 ;                                  
        19 :     enable = 1'b1 ;                                  
        20 :     enable = 1'b1 ;                //1               
                                                                                                                       
        21 :     enable = 1'b1 ;                        
        22 :     enable = 1'b1 ;                        
        23 :     enable = 1'b1 ;                        
        24 :     enable = 1'b1 ;                //slave_addr[2]         
                                                              
        25 :     enable = 1'b1 ;                        
        26 :     enable = 1'b1 ;                        
        27 :     enable = 1'b1 ;                        
        28 :     enable = 1'b1 ;               //slave_addr[1]         
                                                              
        29 :     enable = 1'b1 ;                        
        30 :     enable = 1'b1 ;                        
        31 :     enable = 1'b1 ;                        
        32 :     enable = 1'b1 ;                //slave_addr[0] 
                          
        33 :     enable = 1'b1 ;                                                    
        34 :     enable = 1'b1 ;                                                    
        35 :     enable = 1'b1 ;                                                    
        36 :     enable = 1'b1 ;              // read LM75A ,bit[0] =  1  
        
        69 + 4:  enable = 1'b1 ;                                              
        70 + 4:  enable = 1'b1 ;                                              
        71 + 4:  enable = 1'b1 ;                                              
        72 + 4:  enable = 1'b1 ;              //Master ACK , output 0  
    
        109 + 4: enable = 1'b1 ;                                
        110 + 4: enable = 1'b1 ;     
                               
        111 + 4: enable = 1'b1 ;                                 
        112 + 4: enable = 1'b1 ;                           
        113 + 4: enable = 1'b1 ;             //EOP 
               
       default  : enable = 1'b0 ;            //read data and idle ,i2c bus is hign 
   endcase    
end 

// output sda data when sda enable is 1, else output Z state
assign sda_port = ( enable == 1'b1 )?  sda : 1'bz;
   
// sample LM75A temperature data
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            buff <= 11'b0;
        end
        else  begin
            case (counter) 
            39 + 4 :    buff[10] <= sda_port;          //[10]
            43 + 4 :    buff[9]  <= sda_port;          //[9]                 
            47 + 4 :    buff[8]  <= sda_port;          //[8]         
            51 + 4 :    buff[7]  <= sda_port;          //[7]          
            55 + 4 :    buff[3]  <= sda_port;          //[3]           
            59 + 4 :    buff[5]  <= sda_port;          //[5]           
            63 + 4 :    buff[4]  <= sda_port;          //[4] 
            67 + 4 :    buff[3]  <= sda_port;          //[3] 
            75 + 4 :    buff[2]  <= sda_port;          //[2] 
            79 + 4 :    buff[1]  <= sda_port;          //[1]     
            83 + 4 :    buff[0]  <= sda_port;          //[0]     
            default:                        ;   
            endcase 
        end   
end 
     
//disp buff[7:0] to the led, sample only when the temperature data is stable
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            LED <= 7'b0;
        else if ( counter == 90 ) 
            LED <= buff[7:0] ;       
        else ;        
end 
      
endmodule

//end of RTL code                       