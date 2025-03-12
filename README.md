# FortranFile
Read data from files using a Fortran format specification.

Fortran is great, isn't it? But do you have lots of data sitting in Fortran-formatted files that you would like to access using Swift for your own nefarious purposes? Yes, I thought so. All of the boilerplate you need is here.

# How to read from a Fortran formatted file.

### Step 1. Create a format.
```Swift
let format = try FortranFile.format(from: "1x,4i1,i5,12i3,f15.11,2f18.11,f14.11,f20.11")
```

### Step 2. Use the format to read a single line of input.
```Swift
let result = try FortranFile.read(input: input, using: format)
```
The result is an array of `any FortranFile.Value` corresponding to the values read from the input.

### Step 3. Create a reader to efficiently read multiple lines of input.

Create a `Reader` instance to read multiple lines:
```Swift
let reader = FortranFile.makeReader(using: format)

for line in lines {
  let result = try reader.read(input: line)
}
```
# Types of `FortranFile.Value`.

Each value read from the input is represented by a type conforming to the `FortranFile.Value` protocol. The underlying Swift value can be accessed using the `value` property. The type of the `value` property varies to match the type of Fortran value read from the input in accordance with the format string.
- `FortanDouble`: wraps a Swift `Double` representing a real number.
- `FortranInteger`: wraps a Swift `Int` representing an integer.
- `FortranLogical`: wraps a Swift `Bool` representing a logical value.
- `FortranString`: wraps a Swift `String` representing text.
- `FortranArray`: wraps an array of `any FortranFile.Value` representing repeated values.

> Note: Arrays of repeated values can be automatically flattened by a reading configuration option.

# Reading configuration.

A reading configuration can be provided to a `Reader` instance to allow reading behaviour to be customised.

```Swift
public struct ReadingConfiguration: Sendable {
  public static let common = ReadingConfiguration()
  public var defaultZeroiseBlanks = false
  public var shouldAllowCommaTermination = false
  public var shouldFlattenArrays = false
}
```

# Supported format specifiers.

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
