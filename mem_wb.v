//************************************************
//* @FilePath     : \my_OpenMIPS\mem_wb.v
//* @Date         : 2022-04-27 21:45:59
//* @LastEditTime : 2022-07-09 13:52:30
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 将访存阶段的运算结果传递给写回阶段
//* @Description  : wb:WriteBack (写回)
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

// & 增加接口

`include "defines.v"
module mem_wb(
           input wire clk,
           input wire rst,

           //来自访存阶段的信息
           input wire [ `RegAddrBus ] mem_wd,
           input wire mem_wreg,
           input wire [ `RegBus ] mem_wdata,

           input wire [ `RegBus ] mem_hi,
           input wire [ `RegBus ] mem_lo,
           input wire mem_whilo,

           //送到回写阶段的信息
           output reg [ `RegAddrBus ] wb_wd,
           output reg wb_wreg,
           output reg [ `RegBus ] wb_wdata,

           output reg [ `RegBus ] wb_hi,
           output reg [ `RegBus ] wb_lo,
           output reg wb_whilo
       );

// 时序逻辑，在时钟上升沿传递信号到下一个模块
always @ ( posedge clk )
    begin
        if ( rst == `RstEnable )
            begin
                wb_wd <= 4'b0000;
                wb_wreg <= `WriteDisable;
                wb_wdata <= `ZeroWord;
                wb_hi <= `ZeroWord;
                wb_lo <= `ZeroWord;
                wb_whilo <= `WriteDisable;
            end
        else
            begin
                wb_wd <= mem_wd;
                wb_wreg <= mem_wreg;
                wb_wdata <= mem_wdata;
                wb_hi <= mem_hi;
                wb_lo <= mem_lo;
                wb_whilo <= mem_whilo;
            end    //if
    end      //always

endmodule
