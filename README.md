# my_OpenMIPS

实现一个自己的CPU，采用MIPS32架构

## Contents

- [MIPS32简介](#MIPS32简介)
- [使用的工具](#使用的工具)
- [预期目标](#预期目标)
- [模块划分](#模块划分)
- [可用指令](#可用指令)
- [贡献者](#贡献者)
- [License](#license)

## MIPS32简介

## 使用的工具

- **[VSCODE](https://code.visualstudio.com/)**
- vscode useful extension
  - **[Batch Runner](https://marketplace.visualstudio.com/items?itemName=NilsSoderman.batch-runner)**
  - **[Chinese (Simplified) (简体中文) Language Pack for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=MS-CEINTL.vscode-language-pack-zh-hans)**
  - **[Code alignment](https://marketplace.visualstudio.com/items?itemName=cpmcgrath.codealignment-vscode)**
  - **[Colorful Comments](https://marketplace.visualstudio.com/items?itemName=ParthR2031.colorful-comments)**
  - **[Comment Translate](https://marketplace.visualstudio.com/items?itemName=intellsmi.comment-translate)**
  - **[ctagsx](https://marketplace.visualstudio.com/items?itemName=jtanx.ctagsx)**
  - **[Error Lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens)**
  - **[filesize](https://marketplace.visualstudio.com/items?itemName=mkxml.vscode-filesize)**
  - **[koroFileHeader](https://marketplace.visualstudio.com/items?itemName=OBKoro1.korofileheader)**
  - **[Material Product Icons](https://marketplace.visualstudio.com/items?itemName=PKief.material-product-icons)**
  - **[MIPS Support](https://marketplace.visualstudio.com/items?itemName=kdarkhan.mips)**
  - **[One Dark Pro](https://marketplace.visualstudio.com/items?itemName=zhuangtongfa.Material-theme)**
  - **[Project Manager](https://marketplace.visualstudio.com/items?itemName=alefragnani.project-manager)**
  - **[Rainbow End](https://marketplace.visualstudio.com/items?itemName=jduponchelle.rainbow-end)**
  - **[TCL](https://marketplace.visualstudio.com/items?itemName=rashwell.tcl)**
  - **[Verilog Highlight](https://marketplace.visualstudio.com/items?itemName=tzylee.verilog-highlight)**
  - **[Verilog Snippet](https://marketplace.visualstudio.com/items?itemName=czh.czh-verilog-snippet)**
  - **[Verilog_Testbench](https://marketplace.visualstudio.com/items?itemName=Truecrab.verilog-testbench-instance)**
  - **[verilog-formatter](https://marketplace.visualstudio.com/items?itemName=IsaacT.verilog-formatter)**
  - **[Verilog-HDL/SystemVerilog/Bluespec SystemVerilog](https://marketplace.visualstudio.com/items?itemName=mshr-h.VerilogHDL)**
  - **[vscode-icons](https://marketplace.visualstudio.com/items?itemName=vscode-icons-team.vscode-icons)**
- **[ctags](https://github.com/universal-ctags/ctags)**
  - 可执行文件 [ctags-2022-07-13_p5.9.20220710.0-8-g7b5c7ef-x64.zip](https://github.com/universal-ctags/ctags-win32/releases/download/2022-07-13%2Fp5.9.20220710.0-8-g7b5c7ef/ctags-2022-07-13_p5.9.20220710.0-8-g7b5c7ef-x64.zip)
- [**Istyle**](http://code.google.com/p/istyle-verilog-formatter) 
  - 可执行文件 [iStyle_windows_x86_64.zip](https://github.com/0qinghao/istyle-verilog-formatter/releases/download/v1.21_x86_64/iStyle_windows_x86_64.zip)
- [**iverilog(Icarus Verilog)**](https://github.com/steveicarus/iverilog) 
  - 可执行文件 [iverilog-v12-20220611-x64_setup.exe](http://bleyer.org/icarus/iverilog-v12-20220611-x64_setup.exe)
- [**Modelsim**](http://www.modelsim.com/) 

## 预期目标

## 模块划分

- [取指 pc_reg](./pc_reg.v)
- [译码 id](./id.v)
- [执行 ex](./ex.v)
- [访存 mem](./mem.v)
- [回写 wb](./mem_wb.v)
- ......

## 可用指令

|  指令名  |    31 ~ 26     | 25 ~ 21 | 20 ~ 16 | 15 ~ 11 | 10 ~ 6 |    5 ~ 0    |
| :------: | :------------: | :-----: | :-----: | :-----: | :----: | :---------: |
| **ORI**  |  ORI *001101*  |   rs    |   rt    |   imm   |  imm   |     imm     |
| **AND**  | SPECIAL 000000 |   rs    |   rt    |   rd    | 00000  | AND 100100  |
|  **OR**  |    SPECIAL     |   rs    |   rt    |   rd    | 00000  |  OR 100101  |
| **XOR**  |    SPECIAL     |   rs    |   rt    |   rd    | 00000  | XOR 100110  |
| **NOR**  |    SPECIAL     |   rs    |   rt    |   rd    | 00000  | NOR 100111  |
| **ANDI** |  ANDI 001100   |   rs    |   rt    |   imm   |  imm   |     imm     |
| **XORI** |  XORI 001110   |   rs    |   rt    |   imm   |  imm   |     imm     |
| **LUI**  |   LUI 001111   |  00000  |   rt    |   imm   |  imm   |     imm     |
| **SLL**  |    SPECIAL     |  00000  |   rt    |   rd    |   sa   | SLL 000000  |
| **SRL**  |    SPECIAL     |  00000  |   rt    |   rd    |   sa   | SRL 000010  |
| **SRA**  |    SPECIAL     |  00000  |   rt    |   rd    |   sa   | SRA 000011  |
| **SLLV** |    SPECIAL     |   rs    |   rt    |   rd    | 00000  | SLLV 000100 |
| **SRLV** |    SPECIAL     |   rs    |   rt    |   rd    | 00000  | SRLV 000110 |
| **SRAV** |    SPECIAL     |   rs    |   rt    |   rd    | 00000  | SRAV 000111 |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
|          |                |         |         |         |        |             |
## 贡献者

- MartPeggy


## License

[MIT © Richard McRichface.](./LICENCE)
