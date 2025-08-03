;{- Code Header
; ==- Basic Info -================================
;     Name: WinApi_GetConsoleProcessList.pbi
;  Version: 0.0.1
;   Author: Herwin Bozet (NibblePoker)
;
; ==- Compatibility -=============================
;  Compiler version:
;    * PureBasic 6.0 LTS
;    * PureBasic 6.0 LTS - C Backend
; 
; ==- Links & License -===========================
;  License: Unlicense
;  GitHub: ???
;}

EnableExplicit

CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
	#WinApi_GetConsoleProcessList_LibPath$ = "../Libs/X86/kernel32.lib"
CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x64
	#WinApi_GetConsoleProcessList_LibPath$ = "../Libs/X64/kernel32.lib"
CompilerElse
	CompilerError "Please use x64 or x86 compilers for this include !"
CompilerEndIf

Import #WinApi_GetConsoleProcessList_LibPath$
	GetConsoleProcessList_.l(*lpdwProcessList, dwProcessCount.l) As "GetConsoleProcessList"
EndImport

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 27
; Folding = -
; EnableXP
; DPIAware