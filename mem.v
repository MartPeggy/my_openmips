//************************************************
//* @FilePath     : \my_OpenMIPS\mem.v
//* @Date         : 2022-04-27 21:42:44
//* @LastEditTime : 2022-07-12 14:10:14
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 访存模块
//* @Description  : MEM：Memory(访存)
//************************************************

//^序号     接口名          宽度    输入输出    作用
//^ 1       rst             1       in
//^ 2       wd_i            5       in      访存阶段的指令要写入的目的寄存器地址
//^ 3       wreg_i          1       in      访存阶段的指令是否要写入目的寄存器
//^ 4       wdata_i         32      in      访存阶段的指令要写入目的寄存器的值
//^ 5       wd_o            5       out     访存阶段的指令最终要写入的目的寄存器地址
//^ 6       wreg_o          1       out     访存阶段的指令最终是否要写入目的寄存器
//^ 7       wdata_o         32      out     访存阶段的指令最终要写入目的寄存器的值
// & 增加接口如下
//^ 1       whilo_i         1       in      访存阶段的指令是否要写入HILO寄存器
//^ 2       hi_i            32      in      访存阶段的指令要写入HI寄存器的值
//^ 3       lo_i            32      in      访存阶段的指令要写入LO寄存器的值
//^ 4       whilo_o         1       out     访存阶段的指令最终是否要写入HILO寄存器
//^ 5       hi_o            32      out     访存阶段的指令最终要写入HI寄存器的值
//^ 6       lo_o            32      out     访存阶段的指令最终要写入LO寄存器的值


`include "defines.v"
module mem(
           input wire rst,

           //来自执行阶段的信息
           input wire [ `RegAddrBus ] wd_i,
           input wire wreg_i,
           input wire [ `RegBus ] wdata_i,

           input wire [ `RegBus ] hi_i,
           input wire [ `RegBus ] lo_i,
           input wire whilo_i,

           //送到回写阶段的信息
           output reg [ `RegAddrBus ] wd_o,
           output reg wreg_o,
           output reg [ `RegBus ] wdata_o,

           output reg [ `RegBus ] hi_o,
           output reg [ `RegBus ] lo_o,
           output reg  whilo_o

       );

// 纯组合逻辑，将上一个模块的值传递给下个模块
always @ ( * )
    begin
        if ( rst == `RstEnable )
            begin
                wd_o <= 4'b0000;
                wreg_o <= `WriteDisable;
                wdata_o <= `ZeroWord;
                hi_o <= `ZeroWord;
                lo_o <= `ZeroWord;
                whilo_o <= `WriteDisable;
            end
        else
            begin
                wd_o <= wd_i;
                wreg_o <= wreg_i;
                wdata_o <= wdata_i;
                hi_o <= hi_i;
                lo_o <= lo_i;
                whilo_o <= whilo_i;
            end    //if
    end      //always

endmodule
