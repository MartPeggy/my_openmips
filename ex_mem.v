//************************************************
//* @FilePath     : \my_OpenMIPS\ex_mem.v
//* @Date         : 2022-04-27 21:38:56
//* @LastEditTime : 2022-07-12 14:07:47
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 执行阶段信息传递到访存模块
//* @Description  : MEM：memory 存储器（访存）
//************************************************

//^序号     接口名          宽度    输入输出
//^ 1       clk             1       in
//^ 2       rst             1       in
//^ 3       ex_wd           5       in
//^ 4       ex_wreg         1       in
//^ 5       ex_wdata        32      in
//^ 6       mem_wd          5       out
//^ 7       mem_wreg        1       out
//^ 8       mem_wdata       32      out
// & 增加接口如下
//^ 1       ex_hi           1       in
//^ 2       ex_lo           32      in
//^ 3       ex_whilo        32      in
//^ 4       mem_hi          1       out
//^ 5       mem_lo          32      out
//^ 6       mem_whilo       32      out
// & 增加流水线暂停信号
//^ 1       stall           6       in
// & 增加多周期指令
//^ 1       hilo_i          64      in
//^ 2       cnt_i           2       in
//^ 3       hilo_o          64      out
//^ 4       cnt_o           2       out

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
           output reg mem_whilo,

           input wire [ 5: 0 ] stall,

           input wire [ `DoubleRegBus ] hilo_i,
           input wire [ 1: 0 ] cnt_i,
           output reg [ `DoubleRegBus ] hilo_o,
           output reg [ 1: 0 ] cnt_o
       );

// stall[3]==Stop 执行阶段暂停
// stall[4]==Nostop 访存阶段继续
// 在流水线暂停时将cnt和hilo送回ex模块
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

                hilo_o <= { `ZeroWord, `ZeroWord };
                cnt_o <= 2'b00;
            end
        else if ( stall[ 3 ] == `Stop && stall[ 4 ] == `NoStop )
            begin
                mem_wd <= 4'b0000;
                mem_wreg <= `WriteDisable;
                mem_wdata <= `ZeroWord;
                mem_hi <= `ZeroWord;
                mem_lo <= `ZeroWord;
                mem_whilo <= `WriteDisable;

                hilo_o <= hilo_i;
                cnt_o <= cnt_i;
            end
        else if ( stall[ 3 ] == `NoStop )
            begin
                mem_wd <= ex_wd;
                mem_wreg <= ex_wreg;
                mem_wdata <= ex_wdata;
                mem_hi <= ex_hi;
                mem_lo <= ex_lo;
                mem_whilo <= ex_whilo;

                hilo_o <= { `ZeroWord, `ZeroWord };
                cnt_o <= 2'b00;
            end
        else
            begin
                hilo_o <= hilo_i;
                cnt_o <= cnt_i;
            end
    end

endmodule
