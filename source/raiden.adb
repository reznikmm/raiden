--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

package body Raiden is

   ------------
   -- Decode --
   ------------

   procedure Decode
     (Key    : Raiden.Key;
      Input  : Block;
      Output : out Block) is
   begin
      Decode_With_Subkeys (To_Subkeys (Key), Input, Output);
   end Decode;

   -------------------------
   -- Decode_With_Subkeys --
   -------------------------

   procedure Decode_With_Subkeys
     (Subkey : Subkeys;
      Input  : Block;
      Output : out Block)
   is
      use Interfaces;

      B0 : Unsigned_32 := Input (1);
      B1 : Unsigned_32 := Input (2);
   begin
      for J in reverse Subkey'Range loop
         B1 := B1 -
           (Shift_Left (Subkey (J) + B0, 9)
            xor Subkey (J) - B0
            xor Shift_Right (Subkey (J) + B0, 14));

         B0 := B0 -
           (Shift_Left (Subkey (J) + B1, 9)
            xor Subkey (J) - B1
            xor Shift_Right (Subkey (J) + B1, 14));
      end loop;

      Output := (B0, B1);
   end Decode_With_Subkeys;

   ------------
   -- Encode --
   ------------

   procedure Encode
     (Key    : Raiden.Key;
      Input  : Block;
      Output : out Block)
   is
      use Interfaces;

      K : array (0 .. 3) of Unsigned_32 :=
        (Key (1),  Key (2), Key (3),  Key (4));

      B0 : Unsigned_32 := Input (1);
      B1 : Unsigned_32 := Input (2);
      SK : Unsigned_32;
   begin
      for J in 0 .. 15 loop
         SK := K (0) + K (1)
           + (K (2) + K (3) xor Shift_Left (K (0), Natural (K (2) mod 32)));

         K (J mod 4) := SK;

         B0 := B0 +
           (Shift_Left (SK + B1, 9)
            xor SK - B1
            xor Shift_Right (SK + B1, 14));

         B1 := B1 +
           (Shift_Left (SK + B0, 9)
            xor SK - B0
           xor Shift_Right (SK + B0, 14));
      end loop;

      Output := (B0, B1);
   end Encode;

   ----------------
   -- To_Subkeys --
   ----------------

   function To_Subkeys (Key : Raiden.Key) return Subkeys is
      use Interfaces;

      Subkey : Subkeys;

      K      : array (0 .. 3) of Unsigned_32 :=
        (Key (1),  Key (2), Key (3),  Key (4));
   begin
      for J in Subkey'Range loop
         Subkey (J) :=  K (0) + K (1)
           + (K (2) + K (3) xor Shift_Left (K (0), Natural (K (2) mod 32)));
         K (J mod 4) := Subkey (J);
      end loop;

      return Subkey;
   end To_Subkeys;

end Raiden;
