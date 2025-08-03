# PB-PEArch
A small tool that tells you which [CPU architecture](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#machine-types)
a given [Windows PE](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format) is made for.

## Usage
```
PEArch.exe [/?] [/E|/AsError] [/H|/AsHex] [/F|/FullText] <File>

Options:
  /?             Prints this help text, and some additional details.
  /E, /AsError   Gives out the result as an error code.
  /H, /AsHex     Prints the architecture as a hex number.
  /F, /FullText  Prints a longer description of the architecture.
```

## Cloning
**TODO: Add instructions related to the submodule**

## License
All the code in this repo is released in the [Public Domain](LICENSE).
