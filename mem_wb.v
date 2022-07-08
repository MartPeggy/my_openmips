//************************************************
//* @FilePath     : \my_OpenMIPS\mem_wb.v
//* @Date         : 2022-04-27 21:45:59
//* @LastEditTime : 2022-07-04 18:28:19
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

`include "defines.v"
module mem_wb(
           input wire clk,
           input wire rst,

           //来自访存阶段的信息
           input wire [ `RegAddrBus ] mem_wd,
           input wire                 mem_wreg,
           input wire [ `RegBus     ] mem_wdata,

           //送到回写阶段的信息
           output reg [ `RegAddrBus ] wb_wd,
           output reg                 wb_wreg,
           output reg [ `RegBus     ] wb_wdata
       );

// 时序逻辑，在时钟上升沿传递信号到下一个模块
always @ ( posedge clk )
    begin
        if ( rst == `RstEnable )
            begin
                wb_wd    <= 4'b0000;
                wb_wreg  <= `WriteDisable;
                wb_wdata <= `ZeroWord;
            end
        else
            begin
                wb_wd    <= mem_wd;
                wb_wreg  <= mem_wreg;
                wb_wdata <= mem_wdata;
            end    //if
    end      //always
endmodule
