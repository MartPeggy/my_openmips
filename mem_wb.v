//************************************************
//* @FilePath     : \my_OpenMIPS\mem_wb.v
//* @Date         : 2022-04-27 21:45:59
//* @LastEditTime : 2022-07-12 14:10:37
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 将访存阶段的运算结果传递给写回阶段
//* @Description  : wb:WriteBack (写回)
//************************************************

//^序号     接口名          宽度    输入输出
//^ 1       clk             1       in
//^ 2       rst             1       in
//^ 3       mem_wb          5       in
//^ 4       mem_wreg        1       in
//^ 5       mem_wdata       32      in
//^ 6       wb_wd           5       out
//^ 7       wb_wreg         1       out
//^ 8       wb_wdata        32      out
// & 增加接口
//^ 1       mem_hi          32      in
//^ 2       mem_lo          32      in
//^ 3       mem_whilo       1       in
//^ 4       wb_hi           32      out
//^ 5       wb_lo           32      out
//^ 6       wb_whilo        i       out
//  & 增加流水线暂停信号
//^ 1       stall           6       in        

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
           output reg wb_whilo,

           input wire [ 5: 0 ] stall
       );

// stall[4]==Stop 访存阶段暂停
// stall[5]==Nostop 回写阶段继续
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
        else if ( stall[ 4 ] == `Stop && stall[ 5 ] == `NoStop )
            begin
                wb_wd <= 4'b0000;
                wb_wreg <= `WriteDisable;
                wb_wdata <= `ZeroWord;
                wb_hi <= `ZeroWord;
                wb_lo <= `ZeroWord;
                wb_whilo <= `WriteDisable;
            end
        else if ( stall[ 4 ] == `NoStop )
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
