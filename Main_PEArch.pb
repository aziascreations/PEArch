;{- Code Header
; ==- Basic Info -================================
;     Name: Main_PEArch.pb
;  Version: 3.0.0
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


; ------------------------------------------------------------------------------
;- Notes

; No notes currently available.


; ------------------------------------------------------------------------------
;- Compiler directive

EnableExplicit

XIncludeFile "./Includes/ImageNtHeaderHelper.pbi"
XIncludeFile "./Includes/PB-Win32-GetConsoleProcessList/Includes/Win32_GetConsoleProcessList.pbi"



; ------------------------------------------------------------------------------
;- Constants

; Used when printing the help text
; Could probably be defined in the RC file and then retrieved, but I won't implement it until it is really needed.
#LongestArchCodeLength = 11



; ------------------------------------------------------------------------------
;- Enumerations

;-> Error Codes
Enumeration PEARCH_ErrorCodes
	#PEARCH_ERROR_None = 0
	
	#PEARCH_ERROR_NoTerminal = 1
	#PEARCH_ERROR_UnknownError = 2
	
	;#PEARCH_ERROR_INHH_ERROR_IdAlreadyUsed = 10
	;#PEARCH_ERROR_INHH_ERROR_IdNotfound = 11
	#PEARCH_ERROR_INHH_ERROR_CannotOpenFile = 12
	#PEARCH_ERROR_INHH_ERROR_CannotCreateFileMapping = 13
	#PEARCH_ERROR_INHH_ERROR_CannotMapViewOfFile = 14
	#PEARCH_ERROR_INHH_ERROR_CannotRetrieveHeaders = 15
	#PEARCH_ERROR_INHH_ERROR_FailedToAllocateMemory = 16
	
	#PEARCH_ERROR_UnknownArgument = 20
	#PEARCH_ERROR_MissingFileArgument = 21
	#PEARCH_ERROR_TooManyFileArguments = 22
	
	#PEARCH_ERROR_UnknownAchitecture = 30
EndEnumeration


;-> Localized strings IDs
Enumeration LSCOM_StringIds
	#PEARCH_Locale_Usage_Text = 1000
	#PEARCH_Locale_Usage_Errors = 1001
	#PEAECH_Locale_Usage_Architectures = 1002
	
	#PEARCH_Locale_Text_PressAnyKeyToContinue = 2000
	
	#PEARCH_Locale_ArchBaseCode_UNKNOWN     = 4000
	#PEARCH_Locale_ArchBaseCode_ALPHA       = 4002
	#PEARCH_Locale_ArchBaseCode_ALPHA64     = 4004
	#PEARCH_Locale_ArchBaseCode_AM33        = 4006
	#PEARCH_Locale_ArchBaseCode_AMD64       = 4008
	#PEARCH_Locale_ArchBaseCode_ARM         = 4010
	#PEARCH_Locale_ArchBaseCode_ARM64       = 4012
	#PEARCH_Locale_ArchBaseCode_ARM64EC     = 4014
	#PEARCH_Locale_ArchBaseCode_ARM64X      = 4016
	#PEARCH_Locale_ArchBaseCode_ARMNT       = 4018
	#PEARCH_Locale_ArchBaseCode_AXP64       = 4020
	#PEARCH_Locale_ArchBaseCode_EBC         = 4022
	#PEARCH_Locale_ArchBaseCode_I386        = 4024
	#PEARCH_Locale_ArchBaseCode_IA64        = 4026
	#PEARCH_Locale_ArchBaseCode_LOONGARCH32 = 4028
	#PEARCH_Locale_ArchBaseCode_LOONGARCH64 = 4030
	#PEARCH_Locale_ArchBaseCode_M32R        = 4032
	#PEARCH_Locale_ArchBaseCode_MIPS16      = 4034
	#PEARCH_Locale_ArchBaseCode_MIPSFPU     = 4036
	#PEARCH_Locale_ArchBaseCode_MIPSFPU16   = 4038
	#PEARCH_Locale_ArchBaseCode_POWERPC     = 4040
	#PEARCH_Locale_ArchBaseCode_POWERPCFP   = 4042
	#PEARCH_Locale_ArchBaseCode_R3000BE     = 4044
	#PEARCH_Locale_ArchBaseCode_R3000       = 4046
	#PEARCH_Locale_ArchBaseCode_R4000       = 4048
	#PEARCH_Locale_ArchBaseCode_R10000      = 4050
	#PEARCH_Locale_ArchBaseCode_RISCV32     = 4052
	#PEARCH_Locale_ArchBaseCode_RISCV64     = 4054
	#PEARCH_Locale_ArchBaseCode_RISCV128    = 4056
	#PEARCH_Locale_ArchBaseCode_SH3         = 4058
	#PEARCH_Locale_ArchBaseCode_SH3DSP      = 4060
	#PEARCH_Locale_ArchBaseCode_SH4         = 4062
	#PEARCH_Locale_ArchBaseCode_SH5         = 4064
	#PEARCH_Locale_ArchBaseCode_THUMB       = 4066
	#PEARCH_Locale_ArchBaseCode_WCEMIPSV2   = 4068
	
	#PEARCH_Locale_ArchBaseCode_NEWUNKNOWN  = 4998
	
	#PEARCH_Locale_UnknownArgument = 5000
	#PEARCH_Locale_MissingFileArgument = 5001
	#PEARCH_Locale_TooManyFileArguments = 5002
	
	#PEARCH_Locale_INHH_CannotOpenFile = 6000
	#PEARCH_Locale_INHH_CannotCreateFileMapping = 6001
	#PEARCH_Locale_INHH_CannotMapViewOfFile = 6002
	#PEARCH_Locale_INHH_CannotRetrieveHeaders = 6003
	#PEARCH_Locale_INHH_FailedToAllocateMemory = 6004
	
	#PEARCH_Locale_INHH_UnknownErrorOnLoad = 6010
	#PEARCH_Locale_INHH_UnknownErrorOnHeaderRetrieval = 6011
EndEnumeration



; ------------------------------------------------------------------------------
;- Globals

Global ExitCode.i = #PEARCH_ERROR_None

Global OptionAsHex.b = #False
Global OptionAsError.b = #False
Global OptionFullText.b = #False

Global InputFile$ = #Null$



; ------------------------------------------------------------------------------
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



; ------------------------------------------------------------------------------
;- Procedures

Procedure.s LoadString(StringId.i, MaxLength.i = 4098)
	; Note: Resource strings are limited to a maximum of 4097 characters
	; See: https://learn.microsoft.com/en-us/windows/win32/menurc/stringtable-resource
	; Source: https://github.com/aziascreations/PB-Win32-Internationalization
	If MaxLength > 4098
		DebuggerWarning("LoadString was given a MaxLength bigger than 4098 !")
		MaxLength = 4098
	EndIf
	
	Protected *Buffer = AllocateMemory((MaxLength + 1) * SizeOf(Character))
	Protected Result$ = #Null$
	
	If *Buffer
		If LoadString_(GetModuleHandle_(#Null), StringId, *Buffer, MaxLength)
			Result$ = PeekS(*Buffer, MaxLength, #PB_Unicode)
		Else
			; See: https://learn.microsoft.com/en-us/windows/win32/debug/system-error-codes
			DebuggerWarning("LoadString failed for " + Str(StringId) + " - Error " + Str(GetLastError_()))
		EndIf
		FreeMemory(*Buffer)
	Else
		DebuggerWarning("LoadString failed to allocate memory for its internal buffer !")
	EndIf
	
	ProcedureReturn Result$
EndProcedure

Procedure PrintUsageText(PrintFull.b = #False)
	PrintN(LoadString(#PEARCH_Locale_Usage_Text))
	
	If PrintFull
		PrintN(LoadString(#PEARCH_Locale_Usage_Errors))
		
		PrintN(LoadString(#PEAECH_Locale_Usage_Architectures))
		
		; Template: `0x0000 - xxxxxxxxxxx - ABC123`
		Protected LookupTableOffset = 0
		
		While Not(PeekU(?ArchTextLookups + (LookupTableOffset * 4)) = 0 And PeekU(?ArchTextLookups + (LookupTableOffset * 4) + 2) = 0)
			PrintN("  0x" +
			       RSet(Hex(PeekU(?ArchTextLookups + (LookupTableOffset * 4))), 4, "0") +
			       " - " +
			       LSet(LoadString(PeekU(?ArchTextLookups + (LookupTableOffset * 4) + 2) + 0, #LongestArchCodeLength + 1), #LongestArchCodeLength, " ") +
			       " - " +
			       LoadString(PeekU(?ArchTextLookups + (LookupTableOffset * 4) + 2) + 1))
			
			LookupTableOffset = LookupTableOffset + 1
		Wend
		
		PrintN("  0x???? - " +
		       LSet(LoadString(#PEARCH_Locale_ArchBaseCode_NEWUNKNOWN + 0, #LongestArchCodeLength + 1), #LongestArchCodeLength, " ") +
		       " - " +
		       LoadString(#PEARCH_Locale_ArchBaseCode_NEWUNKNOWN + 1))
	EndIf
EndProcedure

; Checks if the current process was started via another process (CMD), or not.
Procedure.b IsProgramRunDirectly()
	; Will act as a DWORD[2]
	Define ProcessListBuffer.q
	ProcedureReturn Bool(GetConsoleProcessList_(@ProcessListBuffer, 2) <= 1)
EndProcedure



; ------------------------------------------------------------------------------
;- SubRoutines

Procedure SUB_ExitProgram()
	If IsProgramRunDirectly()
		PrintN(LoadString(#PEARCH_Locale_Text_PressAnyKeyToContinue))
		Input()
	EndIf
	
	End ExitCode
EndProcedure



; ------------------------------------------------------------------------------
;- App's code

;-> Setup

If Not OpenConsole("PEArch")
	End #PEARCH_ERROR_NoTerminal
EndIf


;-> Parsing launch arguments

Define IParam.i
For IParam = 0 To CountProgramParameters()
	Define CurrentParam$ = ProgramParameter(IParam)
	
	If Len(CurrentParam$) > 0
		If Left(CurrentParam$, 1) <> "/"
			If InputFile$ = #Null$
				InputFile$ = CurrentParam$
			Else
				ConsoleError(LoadString(#PEARCH_Locale_TooManyFileArguments))
				ExitCode = #PEARCH_ERROR_TooManyFileArguments
				PrintUsageText()
				SUB_ExitProgram()
			EndIf
		Else
			CurrentParam$ = UCase(CurrentParam$)
			
			If CurrentParam$ = "/ASHEX" Or CurrentParam$ = "/H"
				OptionAsHex = #True
			ElseIf CurrentParam$ = "/?"
				PrintUsageText(#True)
				SUB_ExitProgram()
			ElseIf CurrentParam$ = "/ASERROR" Or CurrentParam$ = "/E"
				OptionAsError = #True
			ElseIf CurrentParam$ = "/FULLTEXT" Or CurrentParam$ = "/F"
				OptionFullText = #True
			Else
				ConsoleError(ReplaceString(LoadString(#PEARCH_Locale_UnknownArgument), "{0}", CurrentParam$))
				ExitCode = #PEARCH_ERROR_UnknownArgument
				PrintUsageText()
				SUB_ExitProgram()
			EndIf
		EndIf
	EndIf
Next


;-> Post-processing launch arguments

If InputFile$ = #Null$
	ConsoleError(LoadString(#PEARCH_Locale_MissingFileArgument))
	ExitCode = #PEARCH_ERROR_MissingFileArgument
	PrintUsageText()
	SUB_ExitProgram()
EndIf


;-> Retrieving the PE image machine architecture

Define *PeImage
Define PeArchId.u
Define HelperErrorCode.i

*PeImage = ImageNtHeaderHelper::OpenPeImage(InputFile$)
If *PeImage = #Null
	HelperErrorCode = ImageNtHeaderHelper::GetLastInternalError()
	
	Select HelperErrorCode
		Case ImageNtHeaderHelper::#INHH_ERROR_CannotOpenFile
			ConsoleError(LoadString(#PEARCH_Locale_INHH_CannotOpenFile))
			ExitCode = #PEARCH_ERROR_INHH_ERROR_CannotOpenFile
			
		Case ImageNtHeaderHelper::#INHH_ERROR_CannotCreateFileMapping
			ConsoleError(LoadString(#PEARCH_Locale_INHH_CannotCreateFileMapping))
			ExitCode = #PEARCH_ERROR_INHH_ERROR_CannotCreateFileMapping
			
		Case ImageNtHeaderHelper::#INHH_ERROR_CannotMapViewOfFile
			ConsoleError(LoadString(#PEARCH_Locale_INHH_CannotMapViewOfFile))
			ExitCode = #PEARCH_ERROR_INHH_ERROR_CannotMapViewOfFile
			
		Case ImageNtHeaderHelper::#INHH_ERROR_CannotAllocateMemory
			ConsoleError(LoadString(#PEARCH_Locale_INHH_FailedToAllocateMemory))
			ExitCode = #PEARCH_ERROR_INHH_ERROR_FailedToAllocateMemory
			
		Default 
			ConsoleError(LoadString(#PEARCH_Locale_INHH_UnknownErrorOnLoad) + " ("+Str(HelperErrorCode)+")")
			ExitCode = #PEARCH_ERROR_UnknownError
	EndSelect
	
	If OptionAsError
		ExitCode = 0
	EndIf
	
	SUB_ExitProgram()
EndIf


PeArchId = ImageNtHeaderHelper::GetImageMachine(*PeImage)
HelperErrorCode = ImageNtHeaderHelper::GetLastInternalError()

If PeArchId = 0 And HelperErrorCode <> 0
	Select HelperErrorCode
		Case ImageNtHeaderHelper::#INHH_ERROR_CannotRetrieveHeaders
			ConsoleError(LoadString(#PEARCH_Locale_INHH_CannotRetrieveHeaders))
			ExitCode = #PEARCH_ERROR_INHH_ERROR_CannotRetrieveHeaders
			
		Default 
			ConsoleError(LoadString(#PEARCH_Locale_INHH_UnknownErrorOnHeaderRetrieval) + " ("+Str(HelperErrorCode)+")")
			ExitCode = #PEARCH_ERROR_UnknownError
	EndSelect
	
	If OptionAsError
		ExitCode = 0
	EndIf
	
	ImageNtHeaderHelper::FreePeImage(*PeImage)
	
	SUB_ExitProgram()
EndIf

ImageNtHeaderHelper::FreePeImage(*PeImage)


;-> Printing the arch code/text

Define ArchLocaleBaseCode = #PEARCH_Locale_ArchBaseCode_UNKNOWN
Define LookupTableOffset = 0
Define WasArchTextFound = #False

; Searching and printing the code's info
While Not(PeekU(?ArchTextLookups + (LookupTableOffset * 4)) = 0 And PeekU(?ArchTextLookups + (LookupTableOffset * 4) + 2) = 0)
	If PeekU(?ArchTextLookups + (LookupTableOffset * 4)) = PeArchId
		HandlePeArch(LoadString(PeekU(?ArchTextLookups + (LookupTableOffset * 4) + 2) + 0, #LongestArchCodeLength + 1),
		             LoadString(PeekU(?ArchTextLookups + (LookupTableOffset * 4) + 2) + 1),
		             PeArchId)
		WasArchTextFound = #True
		Break
	EndIf
	
	LookupTableOffset = LookupTableOffset + 1
Wend

; In case the architecture is not yet known by PEArch
If Not WasArchTextFound
	If OptionAsHex Or OptionAsError
		HandlePeArch(LoadString(#PEARCH_Locale_ArchBaseCode_NEWUNKNOWN + 0, #LongestArchCodeLength + 1),
		             LoadString(#PEARCH_Locale_ArchBaseCode_NEWUNKNOWN + 1),
		             PeArchId)
	Else
		ExitCode = #PEARCH_ERROR_UnknownAchitecture
	EndIf
EndIf


;-> Exit
SUB_ExitProgram()



; ------------------------------------------------------------------------------
;- Data section
DataSection
	ArchTextLookups:
	Data.u $0000, #PEARCH_Locale_ArchBaseCode_UNKNOWN
	Data.u $0184, #PEARCH_Locale_ArchBaseCode_ALPHA
	Data.u $0284, #PEARCH_Locale_ArchBaseCode_ALPHA64
	Data.u $01d3, #PEARCH_Locale_ArchBaseCode_AM33
	Data.u $8664, #PEARCH_Locale_ArchBaseCode_AMD64
	Data.u $01c0, #PEARCH_Locale_ArchBaseCode_ARM
	Data.u $aa64, #PEARCH_Locale_ArchBaseCode_ARM64
	Data.u $A641, #PEARCH_Locale_ArchBaseCode_ARM64EC
	Data.u $A64E, #PEARCH_Locale_ArchBaseCode_ARM64X
	Data.u $01c4, #PEARCH_Locale_ArchBaseCode_ARMNT
	Data.u $0284, #PEARCH_Locale_ArchBaseCode_AXP64
	Data.u $0ebc, #PEARCH_Locale_ArchBaseCode_EBC
	Data.u $014c, #PEARCH_Locale_ArchBaseCode_I386
	Data.u $0200, #PEARCH_Locale_ArchBaseCode_IA64
	Data.u $6232, #PEARCH_Locale_ArchBaseCode_LOONGARCH32
	Data.u $6264, #PEARCH_Locale_ArchBaseCode_LOONGARCH64
	Data.u $9041, #PEARCH_Locale_ArchBaseCode_M32R
	Data.u $0266, #PEARCH_Locale_ArchBaseCode_MIPS16
	Data.u $0366, #PEARCH_Locale_ArchBaseCode_MIPSFPU
	Data.u $0466, #PEARCH_Locale_ArchBaseCode_MIPSFPU16
	Data.u $01f0, #PEARCH_Locale_ArchBaseCode_POWERPC
	Data.u $01f1, #PEARCH_Locale_ArchBaseCode_POWERPCFP
	Data.u $0160, #PEARCH_Locale_ArchBaseCode_R3000BE
	Data.u $0162, #PEARCH_Locale_ArchBaseCode_R3000
	Data.u $0166, #PEARCH_Locale_ArchBaseCode_R4000
	Data.u $0168, #PEARCH_Locale_ArchBaseCode_R10000
	Data.u $5032, #PEARCH_Locale_ArchBaseCode_RISCV32
	Data.u $5064, #PEARCH_Locale_ArchBaseCode_RISCV64
	Data.u $5128, #PEARCH_Locale_ArchBaseCode_RISCV128
	Data.u $01a2, #PEARCH_Locale_ArchBaseCode_SH3
	Data.u $01a3, #PEARCH_Locale_ArchBaseCode_SH3DSP
	Data.u $01a6, #PEARCH_Locale_ArchBaseCode_SH4
	Data.u $01a8, #PEARCH_Locale_ArchBaseCode_SH5
	Data.u $01c2, #PEARCH_Locale_ArchBaseCode_THUMB
	Data.u $0169, #PEARCH_Locale_ArchBaseCode_WCEMIPSV2
	Data.u $0000, $0000
EndDataSection



; ------------------------------------------------------------------------------
;- Tests

; TODO
