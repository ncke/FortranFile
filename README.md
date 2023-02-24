# FortranFile
Read data from files using a Fortran format specification.

Fortran is great, isn't it? But do you have lots of data sitting in Fortran-formatted files that you would like to access using Swift for your own nefarious purposes? Yes, I thought so. All of the boilerplate you need is here.

## How to access a Fortran formatted file.

### Step 1. Create a format.
```Swift
let format = try FortranFile.format(string: "1x,4i1,i5,12i3,f15.11,2f18.11,f14.11,f20.11")
```

### Step 2. Use the format to read a line of input.
```Swift
let result = try FortranFile.read(input: input, using: format)
```
The result is an array of `any FortranValue` corresponding to the values read from the input.

## Supported format specifiers.

### Real numbers.
- `Dw.d`
- `Ew.d`
- `Fw.d`
- `Gw.d`

### Integers.
- `Iw`

### Logicals.
- `Lw`

### Text.
- `Aw`

### Horizontal skip.
- `nX`

### Blank editing.
- `B`
- `BN`
- `BZ`

### Scale factor.
- `nP`
