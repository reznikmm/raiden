--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Interfaces;

package Raiden is
   pragma Pure;

   type Block is array (1 .. 2) of Interfaces.Unsigned_32;
   type Key   is array (1 .. 4) of Interfaces.Unsigned_32;

   procedure Encode
     (Key    : Raiden.Key;
      Input  : Block;
      Output : out Block);

   procedure Decode
     (Key    : Raiden.Key;
      Input  : Block;
      Output : out Block);

   type Subkeys is array (0 .. 15) of Interfaces.Unsigned_32;

   function To_Subkeys (Key : Raiden.Key) return Subkeys;

   procedure Decode_With_Subkeys
     (Subkey : Subkeys;
      Input  : Block;
      Output : out Block);

end Raiden;
