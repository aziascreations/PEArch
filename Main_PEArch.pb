;{- Code Header
; ==- Basic Info -================================
;     Name: Main_PEArch.pb
;  Version: 1.1.x
;   Author: Herwin Bozet (NibblePoker)
;
; ==- Compatibility -=============================
;  Compiler version:
;    * PureBasic 5.73 LTS (x86/x64)
;    * PureBasic 6.0 LTS (x64)
;    * PureBasic 6.0 LTS - C Backend (x64)
; 
; ==- Links & License -===========================
;  License: CC0 1.0 Universal (Public Domain)
;  GitHub: https://github.com/aziascreations/PB-PEArch
;}


;- Compiler directive
EnableExplicit

XIncludeFile "./Includes/ImageNtHeaderHelper.pbi"
XIncludeFile "./Includes/PB-Win32-GetConsoleProcessList/Includes/Win32_GetConsoleProcessList.pbi"


;- Constants
#IMAGE_FILE_MACHINE_UNKNOWN = $0
#IMAGE_FILE_MACHINE_ALPHA = $184
#IMAGE_FILE_MACHINE_ALPHA64 = $284
#IMAGE_FILE_MACHINE_AM33 = $1d3
#IMAGE_FILE_MACHINE_AMD64 = $8664
#IMAGE_FILE_MACHINE_ARM = $1c0
#IMAGE_FILE_MACHINE_ARM64 = $aa64
#IMAGE_FILE_MACHINE_ARM64EC = $A641
#IMAGE_FILE_MACHINE_ARM64X = $A64E
#IMAGE_FILE_MACHINE_ARMNT = $1c4
#IMAGE_FILE_MACHINE_AXP64 = $284
#IMAGE_FILE_MACHINE_EBC = $ebc
#IMAGE_FILE_MACHINE_I386 = $14c
#IMAGE_FILE_MACHINE_IA64 = $200
#IMAGE_FILE_MACHINE_LOONGARCH32 = $6232
#IMAGE_FILE_MACHINE_LOONGARCH64 = $6264
#IMAGE_FILE_MACHINE_M32R = $9041
#IMAGE_FILE_MACHINE_MIPS16 = $266
#IMAGE_FILE_MACHINE_MIPSFPU = $366
#IMAGE_FILE_MACHINE_MIPSFPU16 = $466
#IMAGE_FILE_MACHINE_POWERPC = $1f0
#IMAGE_FILE_MACHINE_POWERPCFP = $1f1
#IMAGE_FILE_MACHINE_R3000BE = $160
#IMAGE_FILE_MACHINE_R3000 = $162
#IMAGE_FILE_MACHINE_R4000 = $166
#IMAGE_FILE_MACHINE_R10000 = $168
#IMAGE_FILE_MACHINE_RISCV32 = $5032
#IMAGE_FILE_MACHINE_RISCV64 = $5064
#IMAGE_FILE_MACHINE_RISCV128 = $5128
#IMAGE_FILE_MACHINE_SH3 = $1a2
#IMAGE_FILE_MACHINE_SH3DSP = $1a3
#IMAGE_FILE_MACHINE_SH4 = $1a6
#IMAGE_FILE_MACHINE_SH5 = $1a8
#IMAGE_FILE_MACHINE_THUMB = $1c2
#IMAGE_FILE_MACHINE_WCEMIPSV2 = $169


;- Enumerations
Enumeration PEARCH_ErrorCodes
	#PEARCH_ERROR_None = 0
	
	#PEARCH_ERROR_ConsoleError = 1
	#PEARCH_ERROR_UnknownError = 2
	
	;#PEARCH_ERROR_INHH_ERROR_IdAlreadyUsed = 10
	;#PEARCH_ERROR_INHH_ERROR_IdNotfound = 11
	#PEARCH_ERROR_INHH_ERROR_CannotOpenFile = 12
	#PEARCH_ERROR_INHH_ERROR_CannotCreateFileMapping = 13
	#PEARCH_ERROR_INHH_ERROR_CannotMapViewOfFile = 14
	#PEARCH_ERROR_INHH_ERROR_CannotRetrieveHeaders = 15
	
	#PEARCH_ERROR_UnknownArgument = 20
	#PEARCH_ERROR_MissingFileArgument = 21
	#PEARCH_ERROR_TooManyFileArguments = 22
	
	#PEARCH_ERROR_UnknownAchitecture = 30
EndEnumeration


;- Globals
Global ExitCode.i = #PEARCH_ERROR_None

Global OptionAsHex.b = #False
Global OptionAsError.b = #False
Global OptionFullText.b = #False

Global InputFile$ = #Null$


;- Macros
Macro HandlePeArch(ShortText, FullText, Code)
	If OptionAsHex
		PrintN(Hex(Code, #PB_Word))
	Else
		If OptionFullText
			PrintN(FullText)
		Else
			PrintN(ShortText)
		EndIf
	EndIf
	If OptionAsError
		ExitCode = Code
	EndIf
EndMacro


;- Procedures
Procedure PrintUsageText(PrintFull.b = #False)
	Define UsageText$
	
	Restore UsageText
	
	Read.s UsageText$
	PrintN(UsageText$)
	
	If PrintFull
		Read.s UsageText$
		PrintN(UsageText$)
	EndIf
EndProcedure

; Checks if the current process was started via another process (CMD), or not.
Procedure.b IsProgramRunDirectly()
	; Will act as a DWORD[2]
	Define ProcessListBuffer.q
	ProcedureReturn Bool(GetConsoleProcessList_(@ProcessListBuffer, 2) <= 1)
EndProcedure


;- App's code
If Not OpenConsole("PEArch")
	ExitCode = #PEARCH_ERROR_ConsoleError
	Goto PEArch_End
EndIf


Define IParam.i
For IParam = 0 To CountProgramParameters()
	Define CurrentParam$ = ProgramParameter(IParam)
	
	If Len(CurrentParam$) > 0
		If Left(CurrentParam$, 1) <> "/"
			If InputFile$ = #Null$
				InputFile$ = CurrentParam$
			Else
				ConsoleError("More than one input file was given !")
				ExitCode = #PEARCH_ERROR_TooManyFileArguments
				PrintUsageText()
				Goto PEArch_End
			EndIf
		Else
			CurrentParam$ = UCase(CurrentParam$)
			
			If CurrentParam$ = "/ASHEX" Or CurrentParam$ = "/H"
				OptionAsHex = #True
			ElseIf CurrentParam$ = "/?"
				PrintUsageText(#True)
				Goto PEArch_End
			ElseIf CurrentParam$ = "/ASERROR" Or CurrentParam$ = "/E"
				OptionAsError = #True
			ElseIf CurrentParam$ = "/FULLTEXT" Or CurrentParam$ = "/F"
				OptionFullText = #True
			Else
				ConsoleError("Unknown argument: '" + CurrentParam$ + "'")
				ExitCode = #PEARCH_ERROR_UnknownArgument
				PrintUsageText()
				Goto PEArch_End
			EndIf
		EndIf
	EndIf
	
Next


If InputFile$ = #Null$
	ConsoleError("No input file given !")
	ExitCode = #PEARCH_ERROR_MissingFileArgument
	PrintUsageText()
	Goto PEArch_End
EndIf


Define *Headers.IMAGE_NT_HEADERS32 = ImageNtHeaderHelper::GetImageNtHeader32(0, InputFile$)
If *Headers = #Null
	Define HelperErrorCode.i = ImageNtHeaderHelper::GetLastError()
	
	Select HelperErrorCode
		Case ImageNtHeaderHelper::#INHH_ERROR_CannotOpenFile
			ConsoleError("Cannot open file !")
			ExitCode = #PEARCH_ERROR_INHH_ERROR_CannotOpenFile
			
		Case ImageNtHeaderHelper::#INHH_ERROR_CannotCreateFileMapping
			ConsoleError("Cannot create file mapping !")
			ExitCode = #PEARCH_ERROR_INHH_ERROR_CannotCreateFileMapping
			
		Case ImageNtHeaderHelper::#INHH_ERROR_CannotMapViewOfFile
			ConsoleError("Cannot map view of file into memory !")
			ExitCode = #PEARCH_ERROR_INHH_ERROR_CannotMapViewOfFile
			
		Case ImageNtHeaderHelper::#INHH_ERROR_CannotRetrieveHeaders
			ConsoleError("Cannot retrieve PE headers !")
			ExitCode = #PEARCH_ERROR_INHH_ERROR_CannotRetrieveHeaders
			
		Default 
			ConsoleError("Unknown 'ImageNtHeaderHelper' error ! ("+Str(HelperErrorCode)+")")
			ExitCode = #PEARCH_ERROR_UnknownError
	EndSelect
	
	If OptionAsError
		ExitCode = 0
	EndIf
	
	Goto PEArch_End
EndIf


Define PeArchId.u = *Headers\FileHeader\Machine

Select PeArchId
	Case #IMAGE_FILE_MACHINE_UNKNOWN
		HandlePeArch("UNKNOWN", "The content of this field is assumed To be applicable To any machine type", PeArchId)
	Case #IMAGE_FILE_MACHINE_ALPHA
		HandlePeArch("ALPHA", "Alpha AXP, 32-bit address space", PeArchId)
	Case #IMAGE_FILE_MACHINE_ALPHA64
		HandlePeArch("ALPHA64", "Alpha 64, 64-bit address space", PeArchId)
	Case #IMAGE_FILE_MACHINE_AM33
		HandlePeArch("AM33", "Matsushita AM33", PeArchId)
	Case #IMAGE_FILE_MACHINE_AMD64
		HandlePeArch("AMD64", "x64", PeArchId)
	Case #IMAGE_FILE_MACHINE_ARM
		HandlePeArch("ARM", "ARM little endian", PeArchId)
	Case #IMAGE_FILE_MACHINE_ARM64
		HandlePeArch("ARM64", "ARM64 little endian", PeArchId)
	Case #IMAGE_FILE_MACHINE_ARM64EC
		HandlePeArch("ARM64EC", "ABI that enables interoperability between native ARM64 And emulated x64 code.", PeArchId)
	Case #IMAGE_FILE_MACHINE_ARM64X
		HandlePeArch("ARM64X", "Binary format that allows both native ARM64 And ARM64EC code To coexist in the same file.", PeArchId)
	Case #IMAGE_FILE_MACHINE_ARMNT
		HandlePeArch("ARMNT", "ARM Thumb-2 little endian", PeArchId)
	Case #IMAGE_FILE_MACHINE_AXP64
		HandlePeArch("AXP64", "AXP 64 (Same As Alpha 64)", PeArchId)
	Case #IMAGE_FILE_MACHINE_EBC
		HandlePeArch("EBC", "EFI byte code", PeArchId)
	Case #IMAGE_FILE_MACHINE_I386
		HandlePeArch("I386", "Intel 386 Or later processors And compatible processors", PeArchId)
	Case #IMAGE_FILE_MACHINE_IA64
		HandlePeArch("IA64", "Intel Itanium processor family", PeArchId)
	Case #IMAGE_FILE_MACHINE_LOONGARCH32
		HandlePeArch("LOONGARCH32", "LoongArch 32-bit processor family", PeArchId)
	Case #IMAGE_FILE_MACHINE_LOONGARCH64
		HandlePeArch("LOONGARCH64", "LoongArch 64-bit processor family", PeArchId)
	Case #IMAGE_FILE_MACHINE_M32R
		HandlePeArch("M32R", "Mitsubishi M32R little endian", PeArchId)
	Case #IMAGE_FILE_MACHINE_MIPS16
		HandlePeArch("MIPS16", "MIPS16", PeArchId)
	Case #IMAGE_FILE_MACHINE_MIPSFPU
		HandlePeArch("MIPSFPU", "MIPS With FPU", PeArchId)
	Case #IMAGE_FILE_MACHINE_MIPSFPU16
		HandlePeArch("MIPSFPU16", "MIPS16 With FPU", PeArchId)
	Case #IMAGE_FILE_MACHINE_POWERPC
		HandlePeArch("POWERPC", "Power PC little endian", PeArchId)
	Case #IMAGE_FILE_MACHINE_POWERPCFP
		HandlePeArch("POWERPCFP", "Power PC With floating point support", PeArchId)
	Case #IMAGE_FILE_MACHINE_R3000BE
		HandlePeArch("R3000BE", "MIPS I compatible 32-bit big endian", PeArchId)
	Case #IMAGE_FILE_MACHINE_R3000
		HandlePeArch("R3000", "MIPS I compatible 32-bit little endian", PeArchId)
	Case #IMAGE_FILE_MACHINE_R4000
		HandlePeArch("R4000", "MIPS III compatible 64-bit little endian", PeArchId)
	Case #IMAGE_FILE_MACHINE_R10000
		HandlePeArch("R10000", "MIPS IV compatible 64-bit little endian", PeArchId)
	Case #IMAGE_FILE_MACHINE_RISCV32
		HandlePeArch("RISCV32", "RISC-V 32-bit address space", PeArchId)
	Case #IMAGE_FILE_MACHINE_RISCV64
		HandlePeArch("RISCV64", "RISC-V 64-bit address space", PeArchId)
	Case #IMAGE_FILE_MACHINE_RISCV128
		HandlePeArch("RISCV128", "RISC-V 128-bit address space", PeArchId)
	Case #IMAGE_FILE_MACHINE_SH3
		HandlePeArch("SH3", "Hitachi SH3", PeArchId)
	Case #IMAGE_FILE_MACHINE_SH3DSP
		HandlePeArch("SH3DSP", "Hitachi SH3 DSP", PeArchId)
	Case #IMAGE_FILE_MACHINE_SH4
		HandlePeArch("SH4", "Hitachi SH4", PeArchId)
	Case #IMAGE_FILE_MACHINE_SH5
		HandlePeArch("SH5", "Hitachi SH5", PeArchId)
	Case #IMAGE_FILE_MACHINE_THUMB
		HandlePeArch("THUMB", "Thumb", PeArchId)
	Case #IMAGE_FILE_MACHINE_WCEMIPSV2
		HandlePeArch("WCEMIPSV2", "MIPS little-endian WCE v2", PeArchId)
	Default
		If OptionAsHex
			HandlePeArch("WCEMIPSV2", "MIPS little-endian WCE v2", PeArchId)
		Else
			If OptionAsError
				ExitCode = 0
			Else 
				ExitCode = #PEARCH_ERROR_UnknownAchitecture
			EndIf
		EndIf
EndSelect


ImageNtHeaderHelper::FreeImageNtHeader32(0)


PEArch_End:
If IsProgramRunDirectly()
	PrintN("Press enter to exit...")
	Input()
EndIf

End ExitCode


;- Data section
DataSection
	UsageText:
	Data.s "PEArch.exe [/?] [/E|/AsError] [/H|/AsHex] [/F|/FullText] <File>" + #CRLF$ + 
	       "" + #CRLF$ +
	       "Options:" + #CRLF$ +
	       "  /?             Prints this help text, and some additional details." + #CRLF$ +
	       "  /E, /AsError   Gives out the result as an error code." + #CRLF$ +
	       "  /H, /AsHex     Prints the architecture as a hex number." + #CRLF$ +
	       "  /F, /FullText  Prints a longer description of the architecture." + #CRLF$
	Data.s "Errors:" + #CRLF$ +
	       "  0  - No error" + #CRLF$ +
	       "  1  - Console error" + #CRLF$ +
	       "  1  - Unknown error" + #CRLF$ +
	       "  12 - Unable to open the file" + #CRLF$ +
	       "  13 - Cannot create a file mapping" + #CRLF$ +
	       "  14 - Cannot map the file into memory" + #CRLF$ +
	       "  15 - Unable to retrieve the NT headers" + #CRLF$ +
	       "  20 - Unknown argument" + #CRLF$ +
	       "  21 - Missing file argument" + #CRLF$ +
	       "  22 - Too many file arguments" + #CRLF$ +
	       "  30 - The architecture is unknown, '/AsHex' will bypass it" + #CRLF$ +
	       #CRLF$ +
	       "Architectures:" + #CRLF$ +
	       "  0x0    - UNKNOWN     - The content of this field is assumed To be applicable To any machine type" + #CRLF$ + 
	       "  0x184  - ALPHA       - Alpha AXP, 32-bit address space" + #CRLF$ + 
	       "  0x284  - ALPHA64     - Alpha 64, 64-bit address space" + #CRLF$ + 
	       "  0x1d3  - AM33        - Matsushita AM33" + #CRLF$ + 
	       "  0x8664 - AMD64       - x64" + #CRLF$ + 
	       "  0x1c0  - ARM         - ARM little endian" + #CRLF$ + 
	       "  0xaa64 - ARM64       - ARM64 little endian" + #CRLF$ + 
	       "  0xA641 - ARM64EC     - ABI that enables interoperability between native ARM64 And emulated x64 code." + #CRLF$ + 
	       "  0xA64E - ARM64X      - Binary format that allows both native ARM64 And ARM64EC code To coexist in the same file." + #CRLF$ + 
	       "  0x1c4  - ARMNT       - ARM Thumb-2 little endian" + #CRLF$ + 
	       "  0x284  - AXP64       - AXP 64 (Same As Alpha 64)" + #CRLF$ +
	       "  0xebc  - EBC         - EFI byte code" + #CRLF$ + 
	       "  0x14c  - I386        - Intel 386 Or later processors And compatible processors" + #CRLF$ + 
	       "  0x200  - IA64        - Intel Itanium processor family" + #CRLF$ + 
	       "  0x6232 - LOONGARCH32 - LoongArch 32-bit processor family" + #CRLF$ + 
	       "  0x6264 - LOONGARCH64 - LoongArch 64-bit processor family" + #CRLF$ + 
	       "  0x9041 - M32R        - Mitsubishi M32R little endian" + #CRLF$ + 
	       "  0x266  - MIPS16      - MIPS16" + #CRLF$ + 
	       "  0x366  - MIPSFPU     - MIPS With FPU" + #CRLF$ + 
	       "  0x466  - MIPSFPU16   - MIPS16 With FPU" + #CRLF$ + 
	       "  0x1f0  - POWERPC     - Power PC little endian" + #CRLF$ + 
	       "  0x1f1  - POWERPCFP   - Power PC With floating point support" + #CRLF$ + 
	       "  0x160  - R3000BE     - MIPS I compatible 32-bit big endian" + #CRLF$ + 
	       "  0x162  - R3000       - MIPS I compatible 32-bit little endian" + #CRLF$ + 
	       "  0x166  - R4000       - MIPS III compatible 64-bit little endian" + #CRLF$ + 
	       "  0x168  - R10000      - MIPS IV compatible 64-bit little endian" + #CRLF$ + 
	       "  0x5032 - RISCV32     - RISC-V 32-bit address space" + #CRLF$ + 
	       "  0x5064 - RISCV64     - RISC-V 64-bit address space" + #CRLF$ + 
	       "  0x5128 - RISCV128    - RISC-V 128-bit address space" + #CRLF$ + 
	       "  0x1a2  - SH3         - Hitachi SH3" + #CRLF$ + 
	       "  0x1a3  - SH3DSP      - Hitachi SH3 DSP" + #CRLF$ + 
	       "  0x1a6  - SH4         - Hitachi SH4" + #CRLF$ + 
	       "  0x1a8  - SH5         - Hitachi SH5" + #CRLF$ + 
	       "  0x1c2  - THUMB       - Thumb" + #CRLF$ + 
	       "  0x169  - WCEMIPSV2   - MIPS little-endian WCE v2" + #CRLF$
EndDataSection

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 220
; FirstLine = 212
; Folding = -
; EnableXP
; DPIAware