--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

generic
   type Byte is (<>);
   type Byte_Index is range <>;
   type Byte_Array is array (Byte_Index range <>) of Byte;

package Raiden.Generic_Byte_Array is

   procedure Encode_In_Place
     (Key  : Raiden.Key;
      Data : in out Byte_Array)
        with Pre => Data'Length rem 8 = 0;

   procedure Decode_In_Place
     (Key  : Raiden.Key;
      Data : in out Byte_Array)
        with Pre => Data'Length rem 8 = 0;

end Raiden.Generic_Byte_Array;
