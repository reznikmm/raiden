--  SPDX-FileCopyrightText: 2024 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Ada.Streams.Stream_IO;
with Ada.Text_IO;

with Interfaces;

with VSS.Application;
with VSS.Command_Line;
with VSS.Environments;
with VSS.String_Vectors;
with VSS.Strings.Conversions;

with Raiden;

procedure Tool is

   use Interfaces;
   use type Ada.Streams.Stream_Element_Count;

   Key_Flag : constant VSS.Command_Line.Value_Option :=
     (Short_Name  => "k",
      Long_Name   => "key",
      Value_Name  => "Hex value of the key",
      Description => "Encoding/decoding key ($RAIDEN_KEY is default)");

   Decode_Flag : constant VSS.Command_Line.Binary_Option :=
     (Short_Name  => "d",
      Long_Name   => "decode",
      Description => "Decode file");

   Input_File : constant VSS.Command_Line.Positional_Option :=
     (Description => "Input file",
      Name        => "<input>");

   Output_File : constant VSS.Command_Line.Positional_Option :=
     (Description => "Output file",
      Name        => "<output>");

   Env    : constant VSS.Environments.Process_Environment :=
     VSS.Application.System_Environment;

   Input  : Ada.Streams.Stream_IO.File_Type;
   Output : Ada.Streams.Stream_IO.File_Type;
   Stream : Ada.Streams.Stream_IO.Stream_Access;
   Key    : Raiden.Key;

   function Strip_Underscore
     (Text : VSS.Strings.Virtual_String) return VSS.Strings.Virtual_String;

   procedure Encode;
   procedure Decode;

   ------------
   -- Decode --
   ------------

   procedure Decode is
      Subkeys   : constant Raiden.Subkeys := Raiden.To_Subkeys (Key);

      In_Stream : constant Ada.Streams.Stream_IO.Stream_Access :=
        Ada.Streams.Stream_IO.Stream (Input);

   begin
      while not Ada.Streams.Stream_IO.End_Of_File (Input) loop
         declare

            Block  : Raiden.Block;
            Result : Raiden.Block;
         begin
            Raiden.Block'Read (In_Stream, Block);
            Raiden.Decode_With_Subkeys (Subkeys, Block, Result);
            Raiden.Block'Write (Stream, Result);
         end;
      end loop;
   end Decode;

   procedure Encode is

      --------------------
      -- To_Unsigned_32 --
      --------------------

      function To_Unsigned_32
        (Data : Ada.Streams.Stream_Element_Array) return Unsigned_32 is
          (Unsigned_32 (Data (Data'First))
           + Shift_Left (Unsigned_32 (Data (Data'First + 1)), 8)
           + Shift_Left (Unsigned_32 (Data (Data'First + 2)), 16)
           + Shift_Left (Unsigned_32 (Data (Data'First + 3)), 24));
   begin
      while not Ada.Streams.Stream_IO.End_Of_File (Input) loop
         declare

            Data   : Ada.Streams.Stream_Element_Array (1 .. 8);
            Last   : Ada.Streams.Stream_Element_Count;
            Block  : Raiden.Block;
            Result : Raiden.Block;
         begin
            Ada.Streams.Stream_IO.Read (Input, Data, Last);
            Data (Last + 1 .. Data'Last) := [others => 1];
            Block (1) := To_Unsigned_32 (Data (1 .. 4));
            Block (2) := To_Unsigned_32 (Data (5 .. 8));

            Raiden.Encode (Key, Block, Result);
            Raiden.Block'Write (Stream, Result);
         end;
      end loop;
   end Encode;

   ----------------------
   -- Strip_Underscore --
   ----------------------

   function Strip_Underscore
     (Text : VSS.Strings.Virtual_String) return VSS.Strings.Virtual_String
   is
      List : constant VSS.String_Vectors.Virtual_String_Vector :=
        Text.Split ('_');

      Result : VSS.Strings.Virtual_String;
   begin
      for Item of List loop
         Result.Append (Item);
      end loop;

      return Result;
   end Strip_Underscore;

begin
   VSS.Command_Line.Add_Option (Decode_Flag);
   VSS.Command_Line.Add_Option (Key_Flag);
   VSS.Command_Line.Add_Option (Input_File);
   VSS.Command_Line.Add_Option (Output_File);
   VSS.Command_Line.Add_Help_Option;
   VSS.Command_Line.Process;

   if Key_Flag.Is_Specified or Env.Contains ("RAIDEN_KEY") then
      declare
         package Unsigned_32_IO is new Ada.Text_IO.Modular_IO
           (Interfaces.Unsigned_32);

         Text : constant VSS.Strings.Virtual_String :=
           (if Key_Flag.Is_Specified then Key_Flag.Value
            else Env.Value ("RAIDEN_KEY"));

         Value : constant String :=
           VSS.Strings.Conversions.To_UTF_8_String
             (Strip_Underscore (Text));

         To : Natural;
      begin
         for J in Key'Range loop
            Unsigned_32_IO.Get
              ("16#" & Value ((J - 1) * 8 + 1 .. J * 8) & "#", Key (J), To);
         end loop;
      end;
   else
      VSS.Command_Line.Report_Error ("Provide key value");
   end if;

   if Input_File.Is_Specified then
      Ada.Streams.Stream_IO.Open
        (Input,
         Ada.Streams.Stream_IO.In_File,
         VSS.Strings.Conversions.To_UTF_8_String (Input_File.Value));
   else
      VSS.Command_Line.Report_Error ("Provide input file name");
   end if;

   if Output_File.Is_Specified then
      Ada.Streams.Stream_IO.Create
        (Output,
         Ada.Streams.Stream_IO.Out_File,
         VSS.Strings.Conversions.To_UTF_8_String (Output_File.Value));

      Stream := Ada.Streams.Stream_IO.Stream (Output);
   else
      VSS.Command_Line.Report_Error ("Provide output file name");
   end if;

   if Decode_Flag.Is_Specified then
      Decode;
   else
      Encode;
   end if;
end Tool;
