//************************************************
//* @FilePath     : \my_OpenMIPS\openmips_min_sopc_tb.v
//* @Date         : 2022-07-04 19:09:01
//* @LastEditTime : 2022-07-04 19:09:01
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : Testbench
//************************************************

`include "defines.v"
`timescale 1ns/1ps

module openmips_min_sopc_tb();

reg CLOCK_50;
reg rst;


initial
    begin
        CLOCK_50 = 1'b0;

        forever
            #10 CLOCK_50 = ~CLOCK_50;
    end

initial
    begin
        rst = `RstEnable;
        #195 rst = `RstDisable;
        #1000 $stop;
    end

openmips_min_sopc openmips_min_sopc0(
                      .clk( CLOCK_50 ),
                      .rst( rst )
                  );

endmodule
