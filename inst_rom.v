//************************************************
//* @FilePath     : \my_OpenMIPS\inst_rom.v
//* @Date         : 2022-04-28 12:04:38
//* @LastEditTime : 2022-07-09 14:04:20
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 指令存储器
//************************************************

//^序号    接口名   宽度    输入/输出     作用
//^ 1       ce      1       in       使能信号
//^ 2       addr    32      in       要读取的指令地址
//^ 3       inst    32      out      读出的指令

`include "defines.v"
module inst_rom(
           input wire ce,
           input wire [ `InstAddrBus ] addr,
           output reg [ `InstBus ] inst
       );
// 二维数组，大小是 InstMemNum 宽度为 InstBus
reg [ `InstBus ] inst_mem [ 0: `InstMemNum - 1 ];

// 初始化指令存储器
initial
    $readmemh ( "inst_rom.data", inst_mem );

always @ ( * )
    begin
        if ( ce == `ChipDisable )
            begin
                inst <= `ZeroWord;
            end
        else
            begin
                inst <= inst_mem [ addr [ `InstMemNumLog2 + 1: 2 ] ];
            end
    end

endmodule
