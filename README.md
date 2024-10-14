# Raiden

[![Build status](https://github.com/reznikmm/raiden/actions/workflows/alire.yml/badge.svg)](https://github.com/reznikmm/raiden/actions/workflows/alire.yml)
[![Alire](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/raiden.json)](https://alire.ada.dev/crates/raiden.html)
[![REUSE status](https://api.reuse.software/badge/github.com/reznikmm/raiden)](https://api.reuse.software/info/github.com/reznikmm/raiden)

> Raiden Cipher Library in Ada

This repository contains an implementation of the
[Raiden cipher](https://raiden-cipher.sourceforge.net/), a lightweight
symmetric encryption algorithm, written in Ada. The library is designed
to be simple, efficient, and easy to integrate into Ada applications
that require encryption capabilities.

## Features

- No external dependencies.
- Supports encrypting and decrypting messages.
- A generic package to instantiate with a custom byte-array type

## Installation

Use Alire to install and compile the library:

```bash
alr with raiden --use https://github.com/reznikmm/raiden
```

## Usage

The `Raiden` package provides `Block` (as two `Unsigned_32` numbers) and
`Key` (as 4 `Unsigned_32` numbers) types. You can pass objects of these
type to `Encode` and `Decode` procedures. If you need to decode several
blocks then you can speed it up by unroll `Key` into `Subkeys` type and
save some CPU type by reusing subkeys.

```ada
with Raiden;

procedure Test_Block is

   Key  : constant Raiden.Key :=
     (16#12345678#,
      16#98765432#,
      16#1e1e1e1e#,
      16#95959595#);

   Data   : constant Raiden.Block := (16#09876543#, 16#23456789#);
   Result : Raiden.Block;
   Back   : Raiden.Block;
begin
   Raiden.Encode (Key, Data, Result);
   Raiden.Decode (Key, Result, Back);
end Test_Block;
```

You also can encode/decode byte arrays by instantiating
`Raiden.Generic_Byte_Array` package. In this case, make sure to pass data
in an array with a length that is a multiple of 8 bytes, as Raiden
processes data in blocks of this size.

```ada
with Raiden.Generic_Byte_Array;

procedure Test_String is
   package Raiden_Strings is new Raiden.Generic_Byte_Array
     (Byte       => Character,
      Byte_Index => Positive,
      Byte_Array => String);

   Data   : constant String := "Hello, Raiden!!!";
   --  Data should be padded    1234567_12345678

   Result : String := Data;
begin
   Raiden_Strings.Encode_In_Place (Key, Result);
   Raiden_Strings.Decode_In_Place (Key, Result);
   pragma Assert (Result = Data);
end Test_String;
```

## Contributing

Contributions are welcome! If you'd like to contribute to the library,
please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the Apache-2.0 License with LLVM Exceptions.
See the LICENSES folder for details.
