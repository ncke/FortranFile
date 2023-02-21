# FortranFile
Read data from files using a Fortran format specification.

Fortran is great, isn't it? But do you have lots of data sitting in Fortran-formatted files that you would like to access using Swift for your own nefarious purposes? Yes, I thought so. All of the boilerplate you need is here.

## How to access a Fortran formatted file.

### Step 1. Create a format.

### Step 2. Use the format to read a line of input.

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
