//************************************************
//* @FilePath     : \my_OpenMIPS\regfile.v
//* @Date         : 2022-04-24 13:41:01
//* @LastEditTime : 2022-07-04 14:56:18
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : 通用寄存器读写模块
//************************************************

`include "defines.v"
module regfile (
           input wire clk,
           input wire rst,

           // write 写端口
           input wire we,
           input wire [ `RegAddrBus ] waddr,
           input wire [ `RegBus ] wdata,

           // read 读端口1
           input wire re1,
           input wire [ `RegAddrBus ] raddr1,
           output reg [ `RegBus ] rdata1,

           // read 读端口2
           input wire re2,
           input wire [ `RegAddrBus ] raddr2,
           output reg [ `RegBus ] rdata2
       );

// 定义32个寄存器
reg [ `RegBus ] regs [ 0: `RegNum - 1 ];

// 写端口 ： 检测rst不为复位、we端口为使能状态且waddr不为0
always @( posedge clk )
    begin
        if ( rst == `RstDisable )
            begin
                if ( ( we == `WriteEnable ) && ( waddr != `RegNumLog2'h0 ) )
                    begin
                        regs[ waddr ] <= wdata;
                    end
            end
    end

// 读端口1
// 有复位信号 ：读出0
// 读取地址为0 ： 读出0
// 读出和写入为同一个寄存器 ： 直接输出要写入的值
// 不为以上任一种情况 ：读出对应地址的值
// 不为以上任一情况 ： 读出0

always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                rdata1 <= `ZeroWord;
            end
        else if ( raddr1 == `RegNumLog2'h0 )
            begin
                rdata1 <= `ZeroWord;
            end
        else if ( ( raddr1 == waddr ) && ( we == `WriteEnable ) && ( re1 == `ReadEnable ) )
            begin
                rdata1 <= wdata;
            end
        else if ( re1 == `ReadEnable )
            begin
                rdata1 <= regs[ raddr1 ];
            end
        else
            begin
                rdata1 <= `ZeroWord;
            end
    end

// 读端口2
always @( * )
    begin
        if ( rst == `RstEnable )
            begin
                rdata2 <= `ZeroWord;
            end
        else if ( raddr2 == `RegNumLog2'h0 )
            begin
                rdata2 <= `ZeroWord;
            end
        else if ( ( raddr2 == waddr ) && ( we == `WriteEnable ) && ( re2 == `ReadEnable ) )
            begin
                rdata2 <= wdata;
            end
        else if ( re2 == `ReadEnable )
            begin
                rdata2 <= regs[ raddr2 ];
            end
        else
            begin
                rdata2 <= `ZeroWord;
            end
    end


endmodule //regfile
