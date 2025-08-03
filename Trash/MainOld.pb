;{- Code Header
; ==- Basic Info -================================
;     Name: PB-CTypes.pbi
;  Version: 0.0.1
;   Author: Herwin Bozet
;
; ==- Compatibility -=============================
;  Compiler version:
;    * PureBasic 6.0 LTS
;    * PureBasic 6.0 LTS - C Backend
; 
; ==- Links & License -===========================
;  License: Unlicense
;  GitHub: https://github.com/aziascreations/PB-CTypes
;  Private Repo: https://git.nibblepoker.lu/aziascreations/PB-CTypes
;}


;- Compiler Directives
EnableExplicit


;- Constants
; SEC_IMAGE_NO_EXECUTE
; 0x11000000
CompilerIf Not Defined(SEC_IMAGE_NO_EXECUTE, #PB_Constant)
	#SEC_IMAGE_NO_EXECUTE = $11000000
CompilerEndIf


If Not OpenConsole("DllWrapperMaker")
  End 1
EndIf

If CountProgramParameters() <> 2
  PrintN("DllWrap <DLL> <Output>")
EndIf

Define DllPath$ = ProgramParameter()
Define OutputPath$ = ProgramParameter()

DllPath$ = "C:\Program Files\7-Zip\7-zip32.dll"
DllPath$ = "C:\Program Files\7-Zip\7-zip.dll"

; Debug DllPath$
; Debug OutputPath$

Procedure GetImageCpuArch(ImagePath$)
  ; Mapping the file into memory
  Define InputFileHandle = ReadFile(#PB_Any, ImagePath$)
  
  If InputFileHandle = 0
    PrintN("Unable to open input file !")
    ProcedureReturn
  EndIf
  
  Define InputFileMappingHandle = CreateFileMapping_(FileID(InputFileHandle), #Null, #PAGE_READONLY | #SEC_IMAGE_NO_EXECUTE, 0, 0, #Null)
  
  If InputFileMappingHandle = #ERROR_ALREADY_EXISTS Or InputFileMappingHandle = 0
    PrintN("Unable to create a file mapping !")
    Goto GetImageCpuArch_CloseInputFileHandle
  EndIf
  
  Define InputFileViewPtr.i = MapViewOfFile_(InputFileMappingHandle, #FILE_MAP_READ, 0, 0, 0)
  If InputFileViewPtr = #Null
    PrintN("Unable to map the input file into memory !")
    Goto GetImageCpuArch_CloseInputFileHandle
  EndIf
  
  ; Retrieving the NT headers
  Define *RetrievedNtHeaders.IMAGE_NT_HEADERS32 = ImageNtHeader_(InputFileViewPtr)
  If *RetrievedNtHeaders = #Null 
    PrintN("Unable to retrieve the NT headers !")
    Goto GetImageCpuArch_UnmapFileView
  EndIf
  
  Debug *RetrievedNtHeaders\FileHeader\ Machine
 
  ;FreeMemory(*RetrievedNtHeaders)
  
  ; Cleaning up
  GetImageCpuArch_UnmapFileView:
  UnmapViewOfFile_(InputFileViewPtr)
  
  GetImageCpuArch_CloseInputFileHandle:
  CloseFile(InputFileHandle)
EndProcedure



GetImageCpuArch(DllPath$)

GetImageCpuArch(DllPath$)

GetImageCpuArch(DllPath$)

GetImageCpuArch(DllPath$)

Input()

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 8
; Folding = -
; EnableXP
; DPIAware
; CommandLine = "C:\Program Files (x86)\PureBasic\Compilers\Engine3D.dll" "./test.pb"
; CompileSourceDirectory
; EnableCompileCount = 20
; EnableBuildCount = 0