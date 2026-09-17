;{- Code Header
; ==- Basic Info -================================
;     Name: ImageNtHeaderHelper.pbi
;  Version: 0.1.0
;   Author: Herwin Bozet (NibblePoker)
;
; ==- Compatibility -=============================
;  Tested compiler version:
;    * PureBasic 5.73 LTS (x86/x64)
;    * PureBasic 6.21 (x86/x64)
;    * PureBasic 6.21 C Backend (arm64)
; 
; ==- Links & License -===========================
;  License: CC0 1.0 Universal (Public Domain)
;  GitHub: https://github.com/aziascreations/PB-PEArch
;}


; ------------------------------------------------------------------------------
;- Module declaration
DeclareModule ImageNtHeaderHelper
	
	Enumeration INHH_ErrorCodes
		#INHH_ERROR_None = 0
		#INHH_ERROR_CannotOpenFile
		#INHH_ERROR_CannotCreateFileMapping
		#INHH_ERROR_CannotMapViewOfFile
		#INHH_ERROR_CannotAllocateMemory
		#INHH_ERROR_CannotRetrieveHeaders
		#INHH_ERROR_NullPointerGiven
	EndEnumeration
	
	; Only made public to let us have better signature typing.
	Structure PeImageData
		FileId.i
		MappingHandle.i
		*ViewAddress
		*ImageNtHeaders.IMAGE_NT_HEADERS32
	EndStructure
	
	; Opens a PE image and returns a pointer that future function will use to get information out of it.
	; Returns non-zero on success, zero otherwise.
	Declare.i OpenPeImage(PeImagePath$)
	
	; Frees the internal structure allocated for a PE image that was loaded using `OpenPeImage()`.
	; Returns `#True` on success, `#False` otherwise.
	Declare.i FreePeImage(*ImageData.PeImageData)
	
	; Retrieves the `IMAGE_NT_HEADERS32` structure from a loaded PE image using the internal structure returned by `OpenPeImage()`.
	; Must absolutely not be used after calling `FreePeImage()` on the associated internal structure.
	Declare.i GetImageNtHeader32(*ImageData.PeImageData)
	
	; Retrieves the `FileHeader\Machine` field from the `IMAGE_NT_HEADERS32` associated to a loaded PE image using the
	;  internal structure returned by `OpenPeImage()`.
	; Returns the value on success, or `$0000` otherwise.
	Declare.u GetImageMachine(*ImageData.PeImageData)
	
	Declare.i GetLastInternalError()
	Declare.i GetLastWin32Error()
	Declare ClearLastErrors()
	
EndDeclareModule



; ------------------------------------------------------------------------------
;- Module definition
Module ImageNtHeaderHelper
	EnableExplicit
	
	; --------------------
	;-> Constants
	
	; Sanity check for Win32 API constants
	CompilerIf Not Defined(SEC_IMAGE_NO_EXECUTE, #PB_Constant)
		#SEC_IMAGE_NO_EXECUTE = $11000000
	CompilerEndIf
	
	CompilerIf #SEC_IMAGE_NO_EXECUTE <> $11000000
		CompilerError "The value for `#SEC_IMAGE_NO_EXECUTE` isn't exactly `$11000000` !"
	CompilerEndIf
	
	
	; --------------------
	;-> Globals
	
	Global LastWin32ErrorCode.i = #ERROR_SUCCESS
	Global LastInternalErrorCode.i = #INHH_ERROR_None
	
	
	; --------------------
	;-> Public Procedures
	
	Procedure.i OpenPeImage(PeImagePath$)
		Protected ImageFileId.i
		Protected FileMappingHandle.i
		Protected *FileMappingView
		Protected *ReturnedData.PeImageData
		
		ClearLastErrors()
		
		; Opening the file
		ImageFileId = ReadFile(#PB_Any, PeImagePath$)
		
		If ImageFileId = 0
			LastWin32ErrorCode = GetLastError_()
			LastInternalErrorCode = #INHH_ERROR_CannotOpenFile
			
			DebuggerError("Failed to open the '" + PeImagePath$ + "' file ! (" + Str(LastWin32ErrorCode) + ")")
			ProcedureReturn #Null
		EndIf
		
		; Mapping the file into memory
		FileMappingHandle = CreateFileMapping_(FileID(ImageFileId), #Null, #PAGE_READONLY | #SEC_IMAGE_NO_EXECUTE, 0, 0, #Null)
		
		If FileMappingHandle = #ERROR_ALREADY_EXISTS Or FileMappingHandle = 0
			LastWin32ErrorCode = GetLastError_()
			LastInternalErrorCode = #INHH_ERROR_CannotCreateFileMapping
			
			DebuggerError("Failed to create mapping for the '" + PeImagePath$ + "' file ! (" + Str(LastWin32ErrorCode) + ")")
			CloseFile(ImageFileId)
			ProcedureReturn #Null
		EndIf
		
		; Creating the view of the mapped file
		Define *FileMappingView = MapViewOfFile_(FileMappingHandle, #FILE_MAP_READ, 0, 0, 0)
		
		If *FileMappingView = #Null
			LastWin32ErrorCode = GetLastError_()
			LastInternalErrorCode = #INHH_ERROR_CannotMapViewOfFile
			
			DebuggerError("Failed to map view of the '" + PeImagePath$ + "' file in memory ! (" + Str(LastWin32ErrorCode) + ")")
			CloseHandle_(FileMappingHandle)
			CloseFile(ImageFileId)
			ProcedureReturn #Null
		EndIf
		
		; Returning the data
		*ReturnedData = AllocateMemory(SizeOf(PeImageData))
		
		If *ReturnedData = #Null
			LastWin32ErrorCode = GetLastError_()
			LastInternalErrorCode = #INHH_ERROR_CannotAllocateMemory
			
			DebuggerError("Failed to allocate memory for the `PeImageData` structure ! (" + Str(LastWin32ErrorCode) + ")")
			UnmapViewOfFile_(*FileMappingView)
			CloseHandle_(FileMappingHandle)
			CloseFile(ImageFileId)
			ProcedureReturn #Null
		EndIf
		
		With *ReturnedData
			\FileId = ImageFileId
			\MappingHandle = FileMappingHandle
			\ViewAddress = *FileMappingView
		EndWith
		
		ProcedureReturn *ReturnedData
	EndProcedure
	
	
	Procedure.i FreePeImage(*ImageData.PeImageData)
		ClearLastErrors()
		
		If *ImageData = #Null
			LastInternalErrorCode = #INHH_ERROR_NullPointerGiven
			
			DebuggerError("The given pointer is #Null !")
			ProcedureReturn #False
		EndIf
		
		With *ImageData
			UnmapViewOfFile_(\ViewAddress)
			CloseHandle_(\MappingHandle)
			CloseFile(\FileId)
		EndWith
		
		FreeMemory(*ImageData)
		
		ProcedureReturn #True
	EndProcedure
	
	
	Procedure.i GetImageNtHeader32(*ImageData.PeImageData)
		ClearLastErrors()
		
		; Safety check
		If *ImageData = #Null
			LastInternalErrorCode = #INHH_ERROR_NullPointerGiven
			
			DebuggerError("The given pointer is #Null !")
			ProcedureReturn #Null
		EndIf
		
		; Retrieving the NT headers
		If *ImageData\ImageNtHeaders <> #Null
			ProcedureReturn *ImageData\ImageNtHeaders
		EndIf
		
		*ImageData\ImageNtHeaders = ImageNtHeader_(*ImageData\ViewAddress)
		If *ImageData\ImageNtHeaders = #Null
			LastWin32ErrorCode = GetLastError_()
			LastInternalErrorCode = #INHH_ERROR_CannotRetrieveHeaders
			
			DebuggerError("Unable to retrieve the NT headers !")
			ProcedureReturn #Null
		EndIf
		
		ProcedureReturn *ImageData\ImageNtHeaders
	EndProcedure
	
	
	Procedure.u GetImageMachine(*ImageData.PeImageData)
		Protected *ImageNtHeaders.IMAGE_NT_HEADERS32
		
		; Getting the headers through the standard function
		*ImageNtHeaders = GetImageNtHeader32(*ImageData)
		If *ImageNtHeaders = #Null
			ProcedureReturn #Null	
		EndIf
		
		; Getting what we want from that structure
		ProcedureReturn *ImageNtHeaders\FileHeader\Machine
	EndProcedure
	
	
	Procedure.i GetLastInternalError()
		ProcedureReturn LastInternalErrorCode
	EndProcedure
	
	
	Procedure.i GetLastWin32Error()
		ProcedureReturn LastWin32ErrorCode
	EndProcedure
	
	
	Procedure ClearLastErrors()
		LastWin32ErrorCode = #ERROR_SUCCESS
		LastInternalErrorCode = #INHH_ERROR_None
	EndProcedure
EndModule



; ------------------------------------------------------------------------------
;- Tests

CompilerIf #PB_Compiler_IsMainFile
	EnableExplicit
	
	UseModule ImageNtHeaderHelper
	
	Define *PeImage = ImageNtHeaderHelper::OpenPeImage("C:\Windows\SysWOW64\fontview.exe")
	
	If *PeImage = #Null
		Debug "Error !"
		End 1
	EndIf
	
	Debug ImageNtHeaderHelper::GetImageMachine(*PeImage)
	
	ImageNtHeaderHelper::FreePeImage(*PeImage)
	
CompilerEndIf
