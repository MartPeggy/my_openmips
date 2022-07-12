//************************************************
//* @FilePath     : \my_OpenMIPS\pc_reg.v
//* @Date         : 2022-04-24 09:06:59
//* @LastEditTime : 2022-07-12 14:12:02
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : PC模块(取值阶段)
//************************************************

//^序号     接口名          宽度    输入输出    作用
//^ 1       rst             1       in      复位信号
//^ 2       clk             1       in      时钟
//^ 3       pc              32      out     要读取的指令地址(Program Counter)
//^ 4       ce              1       out     指令存储器使能信号(Chip Enable)
//& 增加流水线暂停的端口
//^ 1       stall           6       in      流水线暂停信号
`include "defines.v"
module pc_reg (
           input wire clk,
           input wire rst,

           output reg [ `InstAddrBus ] pc,
           output reg ce,

           input wire [ 5: 0 ] stall
       );

// 这里always 均使用同步复位
// 复位时指令存储器禁用
always @( posedge clk )
    begin
        if ( rst == `RstEnable )
            begin
                ce <= `ChipDisable;
            end

        else
            begin
                ce <= `ChipEnable;
            end
    end

// 指令存储器禁用时，ce=0
// 指令存储器使能时且无流水线暂停信号时，ce=ce+4
// 流水线暂停时，保持pc不变
always @( posedge clk )
    begin
        if ( ce == `ChipDisable )
            begin
                pc <= `ZeroWord;
            end

        else if ( stall[ 0 ] == `NoStop )
            begin
                pc <= pc + 4'h4;
            end
    end

endmodule //pc_reg
