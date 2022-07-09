//************************************************
//* @FilePath     : \my_OpenMIPS\ex_mem.v
//* @Date         : 2022-04-27 21:38:56
//* @LastEditTime : 2022-07-09 14:05:26
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 执行阶段信息传递到访存模块
//* @Description  : MEM：memory 存储器（访存）
//************************************************

//^序号    接口名   宽度    输入/输出
//^ 1
//^ 2
//^ 3
//^ 4
//^ 5
//^ 6
//^ 7
//^ 8

// & 增加接口如下


`include "defines.v"
module ex_mem(
           input wire clk,
           input wire rst,

           //来自执行阶段的信息
           input wire [ `RegAddrBus ] ex_wd,
           input wire ex_wreg,
           input wire [ `RegBus ] ex_wdata,

           input wire [ `RegBus ] ex_hi,
           input wire [ `RegBus ] ex_lo,
           input wire ex_whilo,

           //送到访存阶段的信息
           output reg [ `RegAddrBus ] mem_wd,
           output reg mem_wreg,
           output reg [ `RegBus ] mem_wdata,

           output reg [ `RegBus ] mem_hi,
           output reg [ `RegBus ] mem_lo,
           output reg mem_whilo
       );

always @ ( posedge clk )
    begin
        if ( rst == `RstEnable )
            begin
                mem_wd <= 4'b0000;
                mem_wreg <= `WriteDisable;
                mem_wdata <= `ZeroWord;
                mem_hi <= `ZeroWord;
                mem_lo <= `ZeroWord;
                mem_whilo <= `WriteDisable;
            end
        else
            begin
                mem_wd <= ex_wd;
                mem_wreg <= ex_wreg;
                mem_wdata <= ex_wdata;
                mem_hi <= ex_hi;
                mem_lo <= ex_lo;
                mem_whilo <= ex_whilo;
            end    //if
    end      //always

endmodule
