--  SPDX-FileCopyrightText: 2028 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Ada.Unchecked_Conversion;

package body Raiden.Generic_Byte_Array is

   subtype Byte_x8 is Byte_Array (1 .. 8);

   function To_Block is new Ada.Unchecked_Conversion (Byte_x8, Raiden.Block);

   function From_Block is new Ada.Unchecked_Conversion (Raiden.Block, Byte_x8);

   ---------------------
   -- Decode_In_Place --
   ---------------------

   procedure Decode_In_Place
     (Key  : Raiden.Key;
      Data : in out Byte_Array)
   is
      Subkey : constant Raiden.Subkeys := Raiden.To_Subkeys (Key);
      From   : Byte_Index := Data'First;
      Block  : Raiden.Block;
      Result : Raiden.Block;
   begin
      for J in 1 .. Data'Length / 8 loop
         Block := To_Block (Data (From .. From + 7));
         Decode_With_Subkeys (Subkey, Block, Result);
         Data (From .. From + 7) := From_Block (Result);
         From := From + Byte_x8'Length;
      end loop;
   end Decode_In_Place;

   ---------------------
   -- Encode_In_Place --
   ---------------------

   procedure Encode_In_Place
     (Key  : Raiden.Key;
      Data : in out Byte_Array)
   is
      From   : Byte_Index := Data'First;
      Block  : Raiden.Block;
      Result : Raiden.Block;
   begin
      for J in 1 .. Data'Length / 8 loop
         Block := To_Block (Data (From .. From + 7));
         Encode (Key, Block, Result);
         Data (From .. From + 7) := From_Block (Result);
         From := From + Byte_x8'Length;
      end loop;
   end Encode_In_Place;

end Raiden.Generic_Byte_Array;
