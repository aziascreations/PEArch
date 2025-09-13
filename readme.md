# PEArch
A small tool that tells you which [CPU architecture](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#machine-types)
a given [Windows PE](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format) is made for.

A total of 35 architectures are supported by this tool.


## Usage
```
PEArch.exe [/?] [/E|/AsError] [/H|/AsHex] [/F|/FullText] <File>

Options:
  /?             Prints this help text, and some additional details.
  /E, /AsError   Gives out the result as an error code.
  /H, /AsHex     Prints the architecture as a hex number.
  /F, /FullText  Prints a longer description of the architecture.
```

<details class="border bkgd-dark r-m mt-s">
  <summary class="p-xs">Click here to show/hide the architecture and return codes</summary>
  <div class="bt ox-auto">
    <table class="table-stylish table-p-xs table-v-center table-no-wrap w-full rb-m">
      <thead>
        <tr>
          <th class="t-left">
            <span class="t-monospace">STDOUT</span>
          </th>
          <th class="t-left">
            <span class="t-monospace">STDOUT</span> with <span class="t-monospace">/AsHex</span>
          </th>
          <th class="t-left">
            <span class="t-monospace">STDERR</span> with <span class="t-monospace">/AsError</span>
          </th>
          <th class="t-left">Description <i>(Source: <a href="https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#machine-types">MSDN</a>) </i>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>UNKNOWN</td>
          <td>
            <span class="code">0x0</span>
          </td>
          <td>
            <span class="code">0</span>
          </td>
          <td>The content of this field is assumed to be applicable to any machine type</td>
        </tr>
        <tr>
          <td>ALPHA</td>
          <td>
            <span class="code">0x184</span>
          </td>
          <td>
            <span class="code">388</span>
          </td>
          <td>Alpha AXP, 32-bit address space</td>
        </tr>
        <tr>
          <td>ALPHA64</td>
          <td>
            <span class="code">0x284</span>
          </td>
          <td>
            <span class="code">644</span>
          </td>
          <td>Alpha 64, 64-bit address space</td>
        </tr>
        <tr>
          <td>AM33</td>
          <td>
            <span class="code">0x1d3</span>
          </td>
          <td>
            <span class="code">467</span>
          </td>
          <td>Matsushita AM33</td>
        </tr>
        <tr>
          <td>AMD64</td>
          <td>
            <span class="code">0x8664</span>
          </td>
          <td>
            <span class="code">34404</span>
          </td>
          <td>x64</td>
        </tr>
        <tr>
          <td>ARM</td>
          <td>
            <span class="code">0x1c0</span>
          </td>
          <td>
            <span class="code">448</span>
          </td>
          <td>ARM little endian</td>
        </tr>
        <tr>
          <td>ARM64</td>
          <td>
            <span class="code">0xaa64</span>
          </td>
          <td>
            <span class="code">43620</span>
          </td>
          <td>ARM64 little endian</td>
        </tr>
        <tr>
          <td>ARM64EC</td>
          <td>
            <span class="code">0xA641</span>
          </td>
          <td>
            <span class="code">42561</span>
          </td>
          <td>ABI that enables interoperability between native ARM64 and emulated x64 code.</td>
        </tr>
        <tr>
          <td>ARM64X</td>
          <td>
            <span class="code">0xA64E</span>
          </td>
          <td>
            <span class="code">42574</span>
          </td>
          <td>Binary format that allows both native ARM64 and ARM64EC code to coexist in the same file.</td>
        </tr>
        <tr>
          <td>ARMNT</td>
          <td>
            <span class="code">0x1c4</span>
          </td>
          <td>
            <span class="code">452</span>
          </td>
          <td>ARM Thumb-2 little endian</td>
        </tr>
        <tr>
          <td>AXP64</td>
          <td>
            <span class="code">0x284</span>
          </td>
          <td>
            <span class="code">644</span>
          </td>
          <td>AXP 64 (Same as Alpha 64)</td>
        </tr>
        <tr>
          <td>EBC</td>
          <td>
            <span class="code">0xebc</span>
          </td>
          <td>
            <span class="code">3772</span>
          </td>
          <td>EFI byte code</td>
        </tr>
        <tr>
          <td>I386</td>
          <td>
            <span class="code">0x14c</span>
          </td>
          <td>
            <span class="code">332</span>
          </td>
          <td>Intel 386 or later processors and compatible processors</td>
        </tr>
        <tr>
          <td>IA64</td>
          <td>
            <span class="code">0x200</span>
          </td>
          <td>
            <span class="code">512</span>
          </td>
          <td>Intel Itanium processor family</td>
        </tr>
        <tr>
          <td>LOONGARCH32</td>
          <td>
            <span class="code">0x6232</span>
          </td>
          <td>
            <span class="code">25138</span>
          </td>
          <td>LoongArch 32-bit processor family</td>
        </tr>
        <tr>
          <td>LOONGARCH64</td>
          <td>
            <span class="code">0x6264</span>
          </td>
          <td>
            <span class="code">25188</span>
          </td>
          <td>LoongArch 64-bit processor family</td>
        </tr>
        <tr>
          <td>M32R</td>
          <td>
            <span class="code">0x9041</span>
          </td>
          <td>
            <span class="code">36929</span>
          </td>
          <td>Mitsubishi M32R little endian</td>
        </tr>
        <tr>
          <td>MIPS16</td>
          <td>
            <span class="code">0x266</span>
          </td>
          <td>
            <span class="code">614</span>
          </td>
          <td>MIPS16</td>
        </tr>
        <tr>
          <td>MIPSFPU</td>
          <td>
            <span class="code">0x366</span>
          </td>
          <td>
            <span class="code">870</span>
          </td>
          <td>MIPS with FPU</td>
        </tr>
        <tr>
          <td>MIPSFPU16</td>
          <td>
            <span class="code">0x466</span>
          </td>
          <td>
            <span class="code">1126</span>
          </td>
          <td>MIPS16 with FPU</td>
        </tr>
        <tr>
          <td>POWERPC</td>
          <td>
            <span class="code">0x1f0</span>
          </td>
          <td>
            <span class="code">496</span>
          </td>
          <td>Power PC little endian</td>
        </tr>
        <tr>
          <td>POWERPCFP</td>
          <td>
            <span class="code">0x1f1</span>
          </td>
          <td>
            <span class="code">497</span>
          </td>
          <td>Power PC with floating point support</td>
        </tr>
        <tr>
          <td>R3000BE</td>
          <td>
            <span class="code">0x160</span>
          </td>
          <td>
            <span class="code">352</span>
          </td>
          <td>MIPS I compatible 32-bit big endian</td>
        </tr>
        <tr>
          <td>R3000</td>
          <td>
            <span class="code">0x162</span>
          </td>
          <td>
            <span class="code">354</span>
          </td>
          <td>MIPS I compatible 32-bit little endian</td>
        </tr>
        <tr>
          <td>R4000</td>
          <td>
            <span class="code">0x166</span>
          </td>
          <td>
            <span class="code">358</span>
          </td>
          <td>MIPS III compatible 64-bit little endian</td>
        </tr>
        <tr>
          <td>R10000</td>
          <td>
            <span class="code">0x168</span>
          </td>
          <td>
            <span class="code">360</span>
          </td>
          <td>MIPS IV compatible 64-bit little endian</td>
        </tr>
        <tr>
          <td>RISCV32</td>
          <td>
            <span class="code">0x5032</span>
          </td>
          <td>
            <span class="code">20530</span>
          </td>
          <td>RISC-V 32-bit address space</td>
        </tr>
        <tr>
          <td>RISCV64</td>
          <td>
            <span class="code">0x5064</span>
          </td>
          <td>
            <span class="code">20580</span>
          </td>
          <td>RISC-V 64-bit address space</td>
        </tr>
        <tr>
          <td>RISCV128</td>
          <td>
            <span class="code">0x5128</span>
          </td>
          <td>
            <span class="code">20776</span>
          </td>
          <td>RISC-V 128-bit address space</td>
        </tr>
        <tr>
          <td>SH3</td>
          <td>
            <span class="code">0x1a2</span>
          </td>
          <td>
            <span class="code">418</span>
          </td>
          <td>Hitachi SH3</td>
        </tr>
        <tr>
          <td>SH3DSP</td>
          <td>
            <span class="code">0x1a3</span>
          </td>
          <td>
            <span class="code">419</span>
          </td>
          <td>Hitachi SH3 DSP</td>
        </tr>
        <tr>
          <td>SH4</td>
          <td>
            <span class="code">0x1a6</span>
          </td>
          <td>
            <span class="code">422</span>
          </td>
          <td>Hitachi SH4</td>
        </tr>
        <tr>
          <td>SH5</td>
          <td>
            <span class="code">0x1a8</span>
          </td>
          <td>
            <span class="code">424</span>
          </td>
          <td>Hitachi SH5</td>
        </tr>
        <tr>
          <td>THUMB</td>
          <td>
            <span class="code">0x1c2</span>
          </td>
          <td>
            <span class="code">450</span>
          </td>
          <td>Thumb</td>
        </tr>
        <tr>
          <td>WCEMIPSV2</td>
          <td>
            <span class="code">0x169</span>
          </td>
          <td>
            <span class="code">361</span>
          </td>
          <td>MIPS little-endian WCE v2v2</td>
        </tr>
      </tbody>
    </table>
  </div>
</details>


## Output examples
**Without options:**
```
Command: pearch "C:\Windows\explorer.exe"
> STDOUT: AMD64
> STDERR:
> ERRORLEVEL: 0
```
```
Command: pearch "C:\Windows\non-existant-file.exe"
> STDOUT:
> STDERR: Cannot open file !
> ERRORLEVEL: 12
```

**With `/AsHex` and `/AsError:**
```
Command: pearch /AsHex "C:\Windows\explorer.exe"
> STDOUT: 8664
> STDERR:
> ERRORLEVEL: 0
```
```
Command: pearch /AsError "C:\Windows\explorer.exe"
> STDOUT:
> STDERR:
> ERRORLEVEL: 34404
```
```
Command: pearch /AsError /AsHex "C:\Windows\explorer.exe"
> STDOUT: 8664
> STDERR:
> ERRORLEVEL: 34404
```
```
Command: pearch /AsError /AsHex "C:\Windows\non-existant-file.exe"
> STDOUT:
> STDERR: Cannot open file !
> ERRORLEVEL: 0
```


## Cloning
**TODO: Add instructions related to the submodule**


## License
All the code in this repo is released in the [Public Domain](LICENSE).
