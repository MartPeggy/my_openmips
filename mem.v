//************************************************
//* @FilePath     : \my_OpenMIPS\mem.v
//* @Date         : 2022-04-27 21:42:44
//* @LastEditTime : 2022-07-04 18:27:18
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 访存模块
//* @Description  : MEM：Memory(访存)
//************************************************


`include "defines.v"
module mem(
           input wire rst,

           //来自执行阶段的信息
           input wire [ `RegAddrBus ] wd_i,
           input wire                 wreg_i,
           input wire [ `RegBus     ] wdata_i,

           //送到回写阶段的信息
           output reg [ `RegAddrBus ] wd_o,
           output reg                 wreg_o,
           output reg [ `RegBus     ] wdata_o
       );

// 纯组合逻辑，将上一个模块的值传递给下个模块
always @ ( * )
    begin
        if ( rst == `RstEnable )
            begin
                wd_o    <= 4'b0000;
                wreg_o  <= `WriteDisable;
                wdata_o <= `ZeroWord;
            end
        else
            begin
                wd_o    <= wd_i;
                wreg_o  <= wreg_i;
                wdata_o <= wdata_i;
            end    //if
    end      //always
endmodule
