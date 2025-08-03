;{- Code Header
; ==- Basic Info -================================
;     Name: ImageNtHeaderHelper.pbi
;  Version: 0.0.2
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


;- Module declaration
DeclareModule ImageNtHeaderHelper
	
	Enumeration INHH_ErrorCodes
		#INHH_ERROR_None = 0
		#INHH_ERROR_IdAlreadyUsed
		#INHH_ERROR_IdNotfound
		#INHH_ERROR_CannotOpenFile
		#INHH_ERROR_CannotCreateFileMapping
		#INHH_ERROR_CannotMapViewOfFile
		#INHH_ERROR_CannotRetrieveHeaders
		#INHH_ERROR_InvalidId
	EndEnumeration
	
	; Loads the given file into memory, maps a view of it into memory and attempts to retrieve the IMAGE_NT_HEADERS32 structure.
	Declare.i GetImageNtHeader32(ImageNtHeaderId.i, FilePath$)
	
	;
	Declare.i FreeImageNtHeader32(ImageNtHeaderId.i)
	
	;
	Declare.i GetLastError()
	Declare ClearLastError()
EndDeclareModule


;- Module definition
Module ImageNtHeaderHelper
	EnableExplicit
	
	CompilerIf Not Defined(SEC_IMAGE_NO_EXECUTE, #PB_Constant)
		#SEC_IMAGE_NO_EXECUTE = $11000000
	CompilerEndIf
	
	Structure OpenImageNtHeader
		FileId.i
		*ViewAddress
		*RetrievedNtHeaders
	EndStructure
	
	Global LastErrorCode.i = 0
	
	Global NewMap OpenImageNtHeaders.OpenImageNtHeader()
	
	
	Procedure.i GetImageNtHeader32(ImageNtHeaderId.i, FilePath$)
		; Handling the ID and the map
		Define ImageNtHeaderId$
		
		If ImageNtHeaderId = #PB_Any
			DebuggerError("Unable to us #PB_Any as 'ImageNtHeaderId' !")
			LastErrorCode = #INHH_ERROR_InvalidId
			Goto INHH_GetImageNtHeader32_BadEnding
		Else
			ImageNtHeaderId$ = Str(ImageNtHeaderId)
			If FindMapElement(OpenImageNtHeaders(), ImageNtHeaderId$) <>  #Null
				Debug "The value used for 'ImageNtHeaderId' was already in use ! (" + ImageNtHeaderId$ + ")"
				LastErrorCode = #INHH_ERROR_IdAlreadyUsed
				ProcedureReturn #Null
			EndIf
		EndIf
		
		AddMapElement(OpenImageNtHeaders(), ImageNtHeaderId$)
		
		; Opening the file
		Define InputFileHandle = ReadFile(#PB_Any, FilePath$)
		
		If InputFileHandle = 0
			Debug "Unable to open input file !"
			LastErrorCode = #INHH_ERROR_CannotOpenFile
			Goto INHH_GetImageNtHeader32_BadEnding
		EndIf
		
		OpenImageNtHeaders()\FileId = InputFileHandle
		
		; Mapping the file into memory
		Define InputFileMappingHandle = CreateFileMapping_(FileID(InputFileHandle), #Null, #PAGE_READONLY | #SEC_IMAGE_NO_EXECUTE, 0, 0, #Null)
		
		If InputFileMappingHandle = #ERROR_ALREADY_EXISTS Or InputFileMappingHandle = 0
			Debug "Unable to create a file mapping !"
			LastErrorCode = #INHH_ERROR_CannotCreateFileMapping
			Goto INHH_GetImageNtHeader32_CloseInputFileHandle
		EndIf
		
		Define InputFileViewPtr.i = MapViewOfFile_(InputFileMappingHandle, #FILE_MAP_READ, 0, 0, 0)
		If InputFileViewPtr = #Null
			Debug "Unable to map the input file into memory !"
			LastErrorCode = #INHH_ERROR_CannotMapViewOfFile
			Goto INHH_GetImageNtHeader32_CloseInputFileHandle
		EndIf
		
		OpenImageNtHeaders()\ViewAddress = InputFileViewPtr
		
		; Retrieving the NT headers
		Define *RetrievedNtHeaders.IMAGE_NT_HEADERS32 = ImageNtHeader_(InputFileViewPtr)
		If *RetrievedNtHeaders = #Null 
			Debug "Unable to retrieve the NT headers !"
			LastErrorCode = #INHH_ERROR_CannotRetrieveHeaders
			Goto INHH_GetImageNtHeader32_UnmapFileView
		EndIf
		
		OpenImageNtHeaders()\RetrievedNtHeaders = *RetrievedNtHeaders
		
		ProcedureReturn *RetrievedNtHeaders
		
		; Error cases
		INHH_GetImageNtHeader32_UnmapFileView:
		UnmapViewOfFile_(InputFileViewPtr)
		
		INHH_GetImageNtHeader32_CloseInputFileHandle:
		CloseFile(InputFileHandle)
		
		INHH_GetImageNtHeader32_BadEnding:
		DeleteMapElement(OpenImageNtHeaders(), ImageNtHeaderId$)
		ProcedureReturn #Null
	EndProcedure
	
	
	Procedure.i FreeImageNtHeader32(ImageNtHeaderId.i)
		Define ImageNtHeaderId$ = Str(ImageNtHeaderId)
		
		Define *HeaderInternalData.OpenImageNtHeader = FindMapElement(OpenImageNtHeaders(), ImageNtHeaderId$)
		If *HeaderInternalData = #Null
			ProcedureReturn #INHH_ERROR_IdNotfound
		EndIf
		
		UnmapViewOfFile_(*HeaderInternalData\ViewAddress)
		CloseFile(*HeaderInternalData\FileId)
		
		ProcedureReturn #Null
	EndProcedure
	
	
	Procedure.i GetLastError()
		ProcedureReturn LastErrorCode
	EndProcedure
	
	
	Procedure ClearLastError()
		LastErrorCode = 0
	EndProcedure
EndModule
