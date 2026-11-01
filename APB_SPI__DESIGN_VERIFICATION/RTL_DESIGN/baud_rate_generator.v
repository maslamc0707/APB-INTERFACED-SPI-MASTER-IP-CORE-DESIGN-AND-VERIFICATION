`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2026 16:38:21
// Design Name: 
// Module Name: baud_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module baud_generator(input PCLK,
                       input PRESETn,
                       input [1:0] spi_mode, // indicates run_mode, wait_mode and stop_mode
                       input spiswai,
                       input [2:0] sppr, // SPI Baud Rate Preselection Bits
                       input [2:0] spr, // SPI Baud Rate Selection Bits
                       input cpol, // 0 - Idle Low, 1- Idle High
                       input cpha,
                       input ss, // Slave Selection
                       output reg sclk,
                       output reg flag_low,
                       output reg flag_high,
                       output reg flags_low,
                       output reg flags_high,
                       output  [11:0]BaudRateDivisor);

  wire pre_sclk;
  reg[11:0] count;

  // Baud Rate Divisor
  assign BaudRateDivisor=((sppr+1)*(2**(spr+1)));


  // Logic to generate pre_sclk based on the cpol
  assign pre_sclk=cpol? 1'b1 : 1'b0;

  // Logic to generate the Sclk
  always@(posedge PCLK or negedge PRESETn)
    begin
      if(!PRESETn)
        begin
          count<=12'b0;
          sclk<=pre_sclk;
        end
      else if((~ss) && (spi_mode == 2'b00 || (spi_mode == 2'b01 && (~spiswai))) )
        begin
          if(count==(BaudRateDivisor-1'b1))
            begin
              count<=12'b0;
              sclk<=~sclk;
            end
          else
            count <= count+1'b1;
        end
      else
        begin
          sclk <= pre_sclk;
          count<=12'b0;
        end
    end

  // Logic to generate the flag to receive miso data
  always@(posedge PCLK or negedge PRESETn)
    begin
      if(!PRESETn)
        begin
          flag_low <= 1'b0;
          flag_high <= 1'b0;
        end
      else
        begin
          if((!cpha && cpol)||(cpha && !cpol))
            begin
              if(sclk)
                if(count == (BaudRateDivisor-1'b1))
                  flag_high<= 1'b1;
                else
                  flag_high <= 1'b0;
              else
                flag_high <= 1'b0;
            end
          else
            begin
              if(~sclk)
                if(count == (BaudRateDivisor-1'b1))
                  flag_low<= 1'b1;
                else
                  flag_low <= 1'b0;
              else
                flag_low<= 1'b0;
            end
        end
    end

  // Logic to generate the flag to send mosi data
  always@(posedge PCLK or negedge PRESETn)
    begin
      if(!PRESETn)
        begin
          flags_low <= 1'b0;
          flags_high <= 1'b0;
        end
      else
        begin
          if((!cpha && cpol)||(cpha && !cpol))
            begin
              if(sclk)
                if(count == (BaudRateDivisor-2'b10))
                  flags_high<= 1'b1;
                else
                  flags_high <= 1'b0;
              else
                flags_high <= 1'b0;
            end
          else
            begin
              if(~sclk)
                if(count == (BaudRateDivisor-2'b10))
                  flags_low<= 1'b1;
                else
                  flags_low <= 1'b0;
              else
                flags_low<= 1'b0;
            end
        end
    end
 endmodule
