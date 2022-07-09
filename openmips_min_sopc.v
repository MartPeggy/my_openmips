//************************************************
//* @FilePath     : \my_OpenMIPS\openmips_min_sopc.v
//* @Date         : 2022-07-04 18:44:36
//* @LastEditTime : 2022-07-09 14:02:55
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : SOPC:System On a Prog ram mable Chip
//* @Description  : 可编程片上系统
//************************************************

`include "defines.v"

module openmips_min_sopc (
           input wire clk,
           input wire rst
       );

// 连接指令存储器
wire [ `InstAddrBus ] inst_addr;
wire [ `InstBus ] inst;
wire rom_ce;

// 例化处理器 OpenMIPS
openmips openmips0(
             .clk( clk ),
             .rst( rst ),
             .rom_addr_o( inst_addr ),
             .rom_data_i( inst ),
             .rom_ce_o( rom_ce )
         );
         
// 例化指令存储器ROM
inst_rom inst_rom0(
             .ce( rom_ce ),
             .addr( inst_addr ),
             .inst( inst )
         );

endmodule //openmips_min_sopc
