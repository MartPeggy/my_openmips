//************************************************
//* @FilePath     : \my_OpenMIPS\openmips_min_sopc_tb.v
//* @Date         : 2022-07-04 19:09:01
//* @LastEditTime : 2022-07-12 19:37:21
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : Testbench
//************************************************

`include "defines.v"
`timescale 1ns/1ps

module openmips_min_sopc_tb();

reg clk;
reg rst;


initial
    begin
        clk = 1'b0;

        forever
            #10 clk = ~clk;
    end

initial
    begin
        rst = `RstEnable;
        #195 rst = `RstDisable;
        #3000 $stop;
    end

openmips_min_sopc openmips_min_sopc0(
                      .clk( clk ),
                      .rst( rst )
                  );

endmodule
