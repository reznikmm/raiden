--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Raiden;
with Raiden.Generic_Byte_Array;

procedure Tests is
   use type Raiden.Block;

   procedure Test_Block;
   procedure Test_String;

   Key  : constant Raiden.Key :=
     (16#12345678#,
      16#98765432#,
      16#1e1e1e1e#,
      16#95959595#);

   ----------------
   -- Test_Block --
   ----------------

   procedure Test_Block is

      Data : constant Raiden.Block := (16#09876543#, 16#23456789#);
      Result : Raiden.Block;
      Back   : Raiden.Block;
   begin
      Raiden.Encode (Key, Data, Result);

      pragma Assert (Result = (16#4b8fe3d5#, 16#edd2ffc4#));

      Raiden.Decode (Key, Result, Back);
      pragma Assert (Back = Data);
   end Test_Block;

   -----------------
   -- Test_String --
   -----------------

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

begin
   Test_Block;
   Test_String;
end Tests;
