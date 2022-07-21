//************************************************
//* @FilePath     : \my_OpenMIPS\openmips_min_sopc.v
//* @Date         : 2022-07-04 18:44:36
//* @LastEditTime : 2022-07-21 12:09:22
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

// 连接数据存储器
wire mem_we_i;
wire[ `RegBus ] mem_addr_i;
wire[ `RegBus ] mem_data_i;
wire[ `RegBus ] mem_data_o;
wire[ 3: 0 ] mem_sel_i;
wire mem_ce_i;

// 例化处理器 OpenMIPS
openmips openmips0(
             .clk( clk ),
             .rst( rst ),

             .rom_addr_o( inst_addr ),
             .rom_data_i( inst ),
             .rom_ce_o( rom_ce ),

             .ram_we_o( mem_we_i ),
             .ram_addr_o( mem_addr_i ),
             .ram_sel_o( mem_sel_i ),
             .ram_data_o( mem_data_i ),
             .ram_data_i( mem_data_o ),
             .ram_ce_o( mem_ce_i )
         );

// 例化指令存储器ROM
inst_rom inst_rom0(
             .ce( rom_ce ),
             .addr( inst_addr ),
             .inst( inst )
         );
// 例化数据存储器RAM
data_ram data_ram0(
             .clk( clk ),
             .we( mem_we_i ),
             .addr( mem_addr_i ),
             .sel( mem_sel_i ),
             .data_i( mem_data_i ),
             .data_o( mem_data_o ),
             .ce( mem_ce_i )
         );

endmodule //openmips_min_sopc
