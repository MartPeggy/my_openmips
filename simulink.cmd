::请按任意键继续...
pause
::杀进程
taskkill /f /t /im vish.exe
::打开Modelsim并执行do sim.tcl
cd D:\Code\Modelsim\mycode
D:
vsim openrisc.mpf -do wave.do
