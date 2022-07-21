//************************************************
//* @FilePath     : \my_OpenMIPS\data_ram.v
//* @Date         : 2022-07-20 15:35:14
//* @LastEditTime : 2022-07-21 10:10:51
//* @Author       : mart
//* @Tips         : CA+I 头注释 CA+P TB
//* @Description  : Data_RAM 数据存储器
//************************************************

//^序号     接口名          宽度    输入输出    作用
//^ 1       ce              1       in      数据存储器使能信号
//^ 2       clk             1       in      时钟信号
//^ 3       data_i          32      in      要写入的数据
//^ 4       addr            32      in      要访问的地址
//^ 5       we              1       in      是否为写操作，1为写
//^ 6       sel             4       in      字节选择信号
//^ 7       data_o          32      out     读出的数据

`include "./defines.v"
module data_ram (
           input wire clk,
           input wire ce,
           input wire we,
           input wire [ `DataAddrBus ] addr,
           input wire [ 3: 0 ] sel,
           input wire [ `DataBus ] data_i,
           output reg [ `DataBus ] data_o
       );

// 四个字节数组
reg [ `ByteWidth ] data_mem0[ 0: `DataMemNum - 1 ];
reg [ `ByteWidth ] data_mem1[ 0: `DataMemNum - 1 ];
reg [ `ByteWidth ] data_mem2[ 0: `DataMemNum - 1 ];
reg [ `ByteWidth ] data_mem3[ 0: `DataMemNum - 1 ];

// 写操作
always @ ( * )
    begin
        if ( ce == `ChipDisable )
            begin
                // data_o <= `ZeroWord;
            end
        else if ( we == `WriteEnable )
            begin
                if ( sel[ 3 ] == 1'b1 )
                    begin
                        data_mem3[ addr[ `DataMemNumLog2 + 1: 2 ] ] <= data_i[ 31: 24 ];
                    end

                if ( sel[ 2 ] == 1'b1 )
                    begin
                        data_mem2[ addr[ `DataMemNumLog2 + 1: 2 ] ] <= data_i[ 23: 16 ];
                    end

                if ( sel[ 1 ] == 1'b1 )
                    begin
                        data_mem1[ addr[ `DataMemNumLog2 + 1: 2 ] ] <= data_i[ 15: 8 ];
                    end

                if ( sel[ 0 ] == 1'b1 )
                    begin
                        data_mem0[ addr[ `DataMemNumLog2 + 1: 2 ] ] <= data_i[ 7: 0 ];
                    end
            end
    end

// 读操作
always @ ( * )
    begin
        if ( ce == `ChipDisable )
            begin
                data_o <= `ZeroWord;
            end
        else if ( we == `WriteDisable )
            begin
                data_o <= { data_mem3[ addr[ `DataMemNumLog2 + 1: 2 ] ],
                            data_mem2[ addr[ `DataMemNumLog2 + 1: 2 ] ],
                            data_mem1[ addr[ `DataMemNumLog2 + 1: 2 ] ],
                            data_mem0[ addr[ `DataMemNumLog2 + 1: 2 ] ] };
            end
        else
            begin
                data_o <= `ZeroWord;
            end
    end

endmodule //data_ram
