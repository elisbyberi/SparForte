------------------------------------------------------------------------------
-- Parser Parameter Handling Support Package                                --
--                                                                          --
-- Part of SparForte                                                        --
------------------------------------------------------------------------------
--                                                                          --
--            Copyright (C) 2001-2011 Free Software Foundation              --
--                                                                          --
-- This is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 2,  or (at your option) any later ver- --
-- sion.  This is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
-- for  more details.  You should have  received  a copy of the GNU General --
-- Public License  distributed with this;  see file COPYING.  If not, write --
-- to  the Free Software Foundation,  59 Temple Place - Suite 330,  Boston, --
-- MA 02111-1307, USA.                                                      --
--                                                                          --
-- This is maintained at http://www.pegasoft.ca                             --
--                                                                          --
------------------------------------------------------------------------------

with ada.text_io;
use ada.text_io;
with gen_list,
    ada.strings.unbounded,
    world,
    scanner,
    parser_aux,
    parser;
use ada.strings,
    ada.strings.unbounded,
    world,
    scanner,
    parser_aux,
    parser;

package body parser_params is

-----------------------------------------------------------------------------

discard_result : boolean;

------------------------------------------------------------------------------
-- Parameter references
------------------------------------------------------------------------------

procedure AssignParameter( ref : in reference; value : unbounded_string ) is
  -- assign a value to the variable or array indicated by ref
  -- assign value to an out or in out parameter
begin
   if ref.index = 0 then
      identifiers( ref.id ).value := value;
   else
      -- assignElement( ref.a_id, ref.index, value ); -- OLDARRAY
      identifiers( ref.id ).avalue( ref.index ) := value; --NEWARRAY
   end if;
exception when storage_error =>
   err( "internal error: storage error raised in AssignParameter" );
end AssignParameter;
pragma inline( AssignParameter );

procedure GetParameterValue( ref : in reference; value : out unbounded_string ) is
-- return the value of the variable or array indicated by ref
begin
   if ref.index = 0 then
      value := identifiers( ref.id ).value;
   else
      --value := arrayElement( ref.a_id, ref.index );
      value := identifiers( ref.id ).avalue( ref.index ); -- NEWARRAY
   end if;
end GetParameterValue;
pragma inline( GetParameterValue );

--  PARSE NEXT GEN ITEM PARAMETER
--
-- Expect an "in" parameter.  Don't check the type.  This is used when
-- there is more than one possible parameter type and you don't know which
-- one it is.

procedure ParseNextGenItemParameter( expr_val : out unbounded_string; expr_type : out identifier; expected_type : identifier := uni_string_t ) is
  u : identifier;
begin
  expect( symbol_t, "," );
  ParseExpression( expr_val, expr_type );
  genTypesOk( expr_type, expected_type );
  if isExecutingCommand then
     u := getUniType( expected_type );
     if u = uni_string_t or u = uni_numeric_t or u = universal_t then
        expr_val := castToType( expr_val, expected_type );
     end if;
  end if;
end ParseNextGenItemParameter;

--  PARSE LAST GEN ITEM PARAMETER
--
-- Expect an "in" parameter.  Don't check the type.  This is used when
-- there is more than one possible parameter type and you don't know which
-- one it is.

procedure ParseLastGenItemParameter( expr_val : out unbounded_string; expr_type : out identifier; expected_type : identifier := uni_string_t ) is
  u : identifier;
begin
  expect( symbol_t, "," );
  ParseExpression( expr_val, expr_type );
  expect( symbol_t, ")" );
  genTypesOk( expr_type, expected_type );
  if isExecutingCommand then
     u := getUniType( expected_type );
     if u = uni_string_t or u = uni_numeric_t or u = universal_t then
        expr_val := castToType( expr_val, expected_type );
     end if;
  end if;
end ParseLastGenItemParameter;

--  PARSE GEN ITEM PARAMETER
--
-- Expect an "in" parameter.  Don't check the type.  This is used when
-- there is more than one possible parameter type and you don't know which
-- one it is.

procedure ParseGenItemParameter( expr_val : out unbounded_string; expr_type : out identifier; expected_type : identifier := uni_string_t ) is
  u : identifier;
begin
  ParseExpression( expr_val, expr_type );
  genTypesOk( expr_type, expected_type );
  if isExecutingCommand then
     u := getUniType( expected_type );
     if u = uni_string_t or u = uni_numeric_t or u = universal_t then
        expr_val := castToType( expr_val, expected_type );
     end if;
  end if;
end ParseGenItemParameter;

--  PARSE SINGLE STRING PARAMETER
--
-- Expect a parameter with a single string expression.  If there is no expected
-- type, assume it's a universal string type.

procedure ParseSingleStringParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier := uni_string_t  ) is
begin
  expect( symbol_t, "(" );
  ParseExpression( expr_val, expr_type );
  discard_result := baseTypesOk( expr_type, expected_type );
  if isExecutingCommand then
     expr_val := castToType( expr_val, expected_type );
  end if;
  expect( symbol_t, ")" );
end ParseSingleStringParameter;


--  PARSE FIRST IN OUT PARAMETER
--
-- Expect a first parameter that is a numeric expression.  If there is no expected
-- type, assume it's a universal string type.

procedure ParseFirstInOutParameter( param_id : out identifier; expected_type : identifier  ) is
begin
  expect( symbol_t, "(" );
  ParseIdentifier( param_id ); -- in out
  discard_result := baseTypesOk( identifiers( param_id ).kind, expected_type );
end ParseFirstInOutParameter;


--  PARSE NEXT IN OUT PARAMETER
--
-- Expect a next parameter that is a numeric expression.  If there is no expected
-- type, assume it's a universal string type.

procedure ParseNextInOutParameter( param_id : out identifier; expected_type : identifier  ) is
begin
  expect( symbol_t, "," );
  ParseIdentifier( param_id ); -- in out
  discard_result := baseTypesOk( identifiers( param_id ).kind, expected_type );
end ParseNextInOutParameter;


--  PARSE LAST IN OUT PARAMETER
--
-- Expect a last parameter that is an in out identifier.  If there is no expected
-- type, assume it's a universal string type.

procedure ParseLastInOutParameter( param_id : out identifier; expected_type : identifier ) is
begin
  expect( symbol_t, "," );
  ParseIdentifier( param_id ); -- in out
  --ParseExpression( expr_val, expr_type );
  --if isExecutingCommand then
  --   expr_val := castToType( expr_val, expected_type );
  --end if;
  discard_result := baseTypesOk( identifiers( param_id ).kind, expected_type );
  expect( symbol_t, ")" );
end ParseLastInOutParameter;


--  PARSE SINGLE IN OUT PARAMETER
--
-- Expect a first parameter that is a numeric expression.  If there is no expected
-- type, assume it's a universal string type.

procedure ParseSingleInOutParameter( param_id : out identifier; expected_type : identifier  ) is
begin
  expect( symbol_t, "(" );
  ParseIdentifier( param_id ); -- in out
  --ParseExpression( expr_val, expr_type );
  --if isExecutingCommand then
  --   expr_val := castToType( expr_val, expected_type );
  --end if;
  discard_result := baseTypesOk( identifiers( param_id ).kind, expected_type );
  expect( symbol_t, ")" );
end ParseSingleInOutParameter;

--  PARSE LAST IN OUT RECORD PARAMETER
--
-- Expect a last parameter that is an in out identifier.  It is expected to be
-- some kind of record, but we don't know the type beforehand.

procedure ParseLastInOutRecordParameter( param_id : out identifier ) is
begin
  expect( symbol_t, "," );
  ParseIdentifier( param_id ); -- in out
  expect( symbol_t, ")" );
end ParseLastInOutRecordParameter;

--  PARSE NEXT IN OUT RECORD PARAMETER
--
-- Expect a next parameter that is an in out identifier.  It is expected to be
-- some kind of record, but we don't know the type beforehand.

procedure ParseNextInOutRecordParameter( param_id : out identifier ) is
begin
  expect( symbol_t, "," );
  ParseIdentifier( param_id ); -- in out
end ParseNextInOutRecordParameter;


--  PARSE FIRST STRING PARAMETER
--
-- Expect a first parameter that is string expression.  If there is no expected
-- type, assume it's a universal string type.

procedure ParseFirstStringParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier := uni_string_t ) is
begin
  expect( symbol_t, "(" );
  ParseExpression( expr_val, expr_type );
  discard_result := baseTypesOk( expr_type, expected_type );
  if isExecutingCommand then
     expr_val := castToType( expr_val, expected_type );
  end if;
end ParseFirstStringParameter;


--  PARSE NEXT STRING PARAMETER
--
-- Expect another parameter that is string expression.  If there is no expected
-- type, assume it's a universal string type.

procedure ParseNextStringParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier := uni_string_t ) is
begin
  expect( symbol_t, "," );
  ParseExpression( expr_val, expr_type );
  discard_result := baseTypesOk( expr_type, expected_type );
  if isExecutingCommand then
     expr_val := castToType( expr_val, expected_type );
  end if;
end ParseNextStringParameter;


--  PARSE LAST STRING PARAMETER
--
-- Expect another parameter that is string expression.  If there is no expected
-- type, assume it's a universal string type.

procedure ParseLastStringParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier := uni_string_t ) is
begin
  expect( symbol_t, "," );
  ParseExpression( expr_val, expr_type );
  discard_result := baseTypesOk( expr_type, expected_type );
  if isExecutingCommand then
     expr_val := castToType( expr_val, expected_type );
  end if;
  expect( symbol_t, ")" );
end ParseLastStringParameter;


--  PARSE SINGLE ENUM PARAMETER

procedure ParseSingleEnumParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier ) is
begin
  expect( symbol_t, "(" );
  ParseExpression( expr_val, expr_type );
  -- no cast to type
  discard_result := baseTypesOk( expr_type, expected_type );
  expect( symbol_t, ")" );
end ParseSingleEnumParameter;


--  PARSE FIRST ENUM PARAMETER

procedure ParseFirstEnumParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier ) is
begin
  expect( symbol_t, "(" );
  ParseExpression( expr_val, expr_type );
  -- no cast to type
  discard_result := baseTypesOk( expr_type, expected_type );
end ParseFirstEnumParameter;


--  PARSE NEXT ENUM PARAMETER
--
-- Expect another parameter that is an enum expression.

procedure ParseNextEnumParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier ) is
begin
  expect( symbol_t, "," );
  ParseExpression( expr_val, expr_type );
  -- no cast to type
  discard_result := baseTypesOk( expr_type, expected_type );
end ParseNextEnumParameter;


--  PARSE LAST ENUM PARAMETER
--
-- Expect another parameter that is an enum expression.

procedure ParseLastEnumParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier ) is
begin
  expect( symbol_t, "," );
  ParseExpression( expr_val, expr_type );
  -- no cast to type
  discard_result := baseTypesOk( expr_type, expected_type );
  expect( symbol_t, ")" );
end ParseLastEnumParameter;


--  PARSE SINGLE NUMERIC PARAMETER
--
-- typeTypesOk not yet implemented here

procedure ParseSingleNumericParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier := uni_numeric_t ) is
begin
  expect( symbol_t, "(" );
  ParseExpression( expr_val, expr_type );
  discard_result := baseTypesOk( expr_type, expected_type );
  if isExecutingCommand then
     expr_val := castToType( expr_val, expected_type );
  end if;
  expect( symbol_t, ")" );
end ParseSingleNumericParameter;

--  PARSE FIRST NUMERIC PARAMETER
--

procedure ParseFirstNumericParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier := uni_numeric_t ) is
begin
  expect( symbol_t, "(" );
  ParseExpression( expr_val, expr_type );
  discard_result := baseTypesOk( expr_type, expected_type );
  if isExecutingCommand then
     expr_val := castToType( expr_val, expected_type );
  end if;
end ParseFirstNumericParameter;


--  PARSE NEXT NUMERIC PARAMETER
--

procedure ParseNextNumericParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier := uni_numeric_t ) is
begin
  expect( symbol_t, "," );
  ParseExpression( expr_val, expr_type );
  discard_result := baseTypesOk( expr_type, expected_type );
  if isExecutingCommand then
     expr_val := castToType( expr_val, expected_type );
  end if;
end ParseNextNumericParameter;


--  PARSE LAST NUMERIC PARAMETER
--

procedure ParseLastNumericParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier := uni_numeric_t ) is
begin
  expect( symbol_t, "," );
  ParseExpression( expr_val, expr_type );
  discard_result := baseTypesOk( expr_type, expected_type );
  if isExecutingCommand then
     expr_val := castToType( expr_val, expected_type );
  end if;
  expect( symbol_t, ")" );
end ParseLastNumericParameter;


--  PARSE NUMERIC PARAMETER
--
-- Special case: don't read ( / , / )

procedure ParseNumericParameter( expr_val : out unbounded_string;
  expr_type : out identifier; expected_type : identifier := uni_numeric_t ) is
begin
  ParseExpression( expr_val, expr_type );
  discard_result := baseTypesOk( expr_type, expected_type );
  if isExecutingCommand then
     expr_val := castToType( expr_val, expected_type );
  end if;
end ParseNumericParameter;


------------------------------------------------------------------------------
-- Out Parameters
------------------------------------------------------------------------------


--  PARSE OUT PARAMETER
--
-- Parse an "out" parameter for a procedure call.  Return a reference
-- to it.  If the variable being referenced doesn't exist, declare it
-- (if the pragmas allow it).

procedure ParseOutParameter( ref : out reference; defaultType : identifier ) is
  -- syntax: identifier [ (index) ]
  expr_kind  : identifier;
  expr_value : unbounded_string;
  -- array_id2  : arrayID;
  arrayIndex : long_integer;
  isNew      : boolean := false;
begin
  -- If the identifier is undeclared (new_t) and we're in an an interactive
  -- mode with no restrictions and no errors, declare the identifier as
  -- an identifier of the default type.  Otherwise, just accept an existing
  -- identifer as normal.
  if identifiers( token ).kind = new_t and not onlyAda95 and not restriction_no_auto_declarations and not error_found and (inputMode = interactive or inputMode = breakout) then
     ParseNewIdentifier( ref.id );
     if index( identifiers( ref.id ).name, "." ) /= 0 then
        err( "Identifier not declared.  Cannot auto-declare a record field" );
     else
        identifiers( ref.id ).kind := defaultType;
        identifiers( ref.id ).class := varClass;
        put_trace( "Assuming " & to_string( identifiers( ref.id ).name ) &
            " is a new " & to_string( identifiers( defaultType ).name ) &
            " variable" );
     end if;
     isNew := true;
  else
     ParseIdentifier( ref.id );
  end if;

  -- Some sensible defaults for fields we will fill in

  ref.index := 0;
  ref.kind := eof_t;

  -- If this is an array reference, read the index value.  Check that
  -- the index value is within the index bounds for the array.

  if identifiers( ref.id ).list then        -- array variable?
     ref.kind := identifiers( identifiers( ref.id ).kind ).kind;
     expect( symbol_t, "(" );
     ParseExpression( expr_value, expr_kind );
     if getUniType( expr_kind ) = uni_string_t or   -- index must be scalar
        identifiers( getBaseType( expr_kind ) ).list then
        err( "array index must be a scalar type" );
     end if;                                   -- variables are not
     if isExecutingCommand then                -- declared in syntax chk
         begin
            arrayIndex := long_integer(to_numeric(expr_value));-- convert to number
         exception when others =>
            err( "exception raised" );
            arrayIndex := 0;
         end;
         -- array_id2 := arrayID( to_numeric(      -- array_id2=reference
         --   identifiers( ref.id ).value ) );     -- to the array table
         -- if indexTypeOK( array_id2, expr_kind ) then -- check and access array
         --    if inBounds( array_id2, arrayIndex ) then
         --        ref.a_id  := array_id2;
         --        ref.index := arrayIndex;
         --    end if;
         -- end if;
         if baseTypesOK( identifiers( ref.id ).genKind, expr_kind ) then -- TODO: probably needs a better error message
            if arrayIndex not in identifiers( ref.id ).avalue'range then
               err( "array index " & to_string( trim( expr_value, ada.strings.both ) ) & " not in" & identifiers( ref.id ).avalue'first'img & " .." & identifiers( ref.id ).avalue'last'img );
            else
              ref.index := arrayIndex;
            end if;
         end if;
      end if;
      expect( symbol_t, ")" );
      -- If this is a record type, and it is new, create the record's fields
      -- Only do this if we created a new record variable on behalf of the
      -- user: an existing record already has its fields declared.

  elsif identifiers( getBaseType( identifiers( ref.id ).kind ) ).kind = root_record_t then
  --      getBaseType( ref.kind ) = root_record_t then        -- record variable?
  -- To do this, search for the i-th field in the formal record declaration
  -- (the identifier value for the field has the field number).  The field name
  -- contains the full dot qualified name.  Get the base field name by removing
  -- everything except the name after the final dot.  Then prefix the name of
  -- the record being declared (so that "rec_type.f" becomes "my_rec.f").

     -- ref.kind := identifiers( identifiers( ref.id ).kind ).kind;
     ref.kind := identifiers( ref.id ).kind;
     if isNew then
        for i in 1..integer'value( to_string( identifiers( ref.kind ).value ) ) loop
            for j in 1..identifiers_top-1 loop
                if identifiers( j ).field_of = ref.kind then
                   if integer'value( to_string( identifiers( j ).value )) = i then
                      declare
                         fieldName   : unbounded_string;
                         dont_care_t : identifier;
                         dotPos      : natural;
                      begin
                         fieldName := identifiers( j ).name;
                         dotPos := length( fieldName );
                         while dotPos > 1 loop
                            exit when element( fieldName, dotPos ) = '.';
                            dotPos := dotPos - 1;
                         end loop;
                         fieldName := delete( fieldName, 1, dotPos );
                         fieldName := identifiers( ref.id ).name & "." & fieldName;
                         declareIdent( dont_care_t, fieldName, identifiers( j ).kind, varClass );
                      end;
                   end if;
                end if;
            end loop;
        end loop;
     end if;
  else
    -- If it's a regular identifier, if it's new, assign the type.  Otherwise
    -- if it already exists it must match the default type.
    if identifiers( ref.id ).kind = new_t then
       ref.kind := new_t; -- identifiers( ref.id ).kind;
    elsif baseTypesOK( identifiers( ref.id ).kind, defaultType ) then
       ref.kind := identifiers( ref.id ).kind;
    end if;
  end if;
end ParseOutParameter;

procedure ParseSingleOutParameter( ref : out reference; defaultType : identifier ) is
begin
  expect( symbol_t, "(" );
  ParseOutParameter( ref, defaultType );
  expect( symbol_t, ")" );
end ParseSingleOutParameter;

procedure ParseFirstOutParameter( ref : out reference; defaultType : identifier ) is
begin
  expect( symbol_t, "(" );
  ParseOutParameter( ref, defaultType );
end ParseFirstOutParameter;

procedure ParseNextOutParameter( ref : out reference; defaultType : identifier ) is
begin
  expect( symbol_t, "," );
  ParseOutParameter( ref, defaultType );
end ParseNextOutParameter;

procedure ParseLastOutParameter( ref : out reference; defaultType : identifier ) is
begin
  expect( symbol_t, "," );
  ParseOutParameter( ref, defaultType );
  expect( symbol_t, ")" );
end ParseLastOutParameter;


--  PARSE IN OUT PARAMETER
--
-- Parse an "in out" parameter for a procedure call.  Return a reference
-- to it.  The variable being referenced must already exist.

procedure ParseInOutParameter( ref : out reference ) is
  -- syntax: identifier [ (index) ]
  expr_kind : identifier;
  expr_value : unbounded_string;
  -- array_id2 : arrayID;
  arrayIndex: long_integer;
begin
  ParseIdentifier( ref.id );
  ref.index := 0;
  if identifiers( token ).list then        -- array variable?
     expect( symbol_t, "(" );
     ParseExpression( expr_value, expr_kind );
     expect( symbol_t, ")");
  end if;
  ref.index := 0;
  if identifiers( ref.id ).list then        -- array variable?
     ref.kind := identifiers( identifiers( ref.id ).kind ).kind;
     expect( symbol_t, "(" );
     ParseExpression( expr_value, expr_kind );
     if getUniType( expr_kind ) = uni_string_t or   -- index must be scalar
        identifiers( getBaseType( expr_kind ) ).list then
        err( "array index must be a scalar type" );
     end if;                                   -- variables are not
     if isExecutingCommand then                -- declared in syntax chk
         begin
            arrayIndex := long_integer(to_numeric(expr_value));-- convert to number
         exception when others =>
            err( "exception raised" );
            arrayIndex := 0;
         end;
         -- array_id2 := arrayID( to_numeric(      -- array_id2=reference
         --   identifiers( ref.id ).value ) );     -- to the array table
         -- if indexTypeOK( array_id2, expr_kind ) then -- check and access array
         --    if inBounds( array_id2, arrayIndex ) then
         --        ref.a_id  := array_id2;
         --        ref.index := arrayIndex;
         --    end if;
         -- end if;
         if baseTypesOK( identifiers( ref.id ).genKind, expr_kind ) then -- TODO: probably needs a better error message
            if arrayIndex not in identifiers( ref.id ).avalue'range then
               err( "array index " & to_string( trim( expr_value, ada.strings.both ) ) & " not in" & identifiers( ref.id ).avalue'first'img & " .." & identifiers( ref.id ).avalue'last'img );
            else
              ref.index := arrayIndex;
            end if;
         end if;
      end if;
      expect( symbol_t, ")");
  elsif identifiers( getBaseType( identifiers( ref.id ).kind ) ).kind = root_record_t then
  -- To do this, search for the i-th field in the formal record declaration
  -- (the identifier value for the field has the field number).  The field name
  -- contains the full dot qualified name.  Get the base field name by removing
  -- everything except the name after the final dot.  Then prefix the name of
  -- the record being declared (so that "rec_type.f" becomes "my_rec.f").

     -- ref.kind := identifiers( identifiers( ref.id ).kind ).kind;
     ref.kind := identifiers( ref.id ).kind;
     for i in 1..integer'value( to_string( identifiers( ref.kind ).value ) ) loop
        for j in 1..identifiers_top-1 loop
             if identifiers( j ).field_of = ref.kind then
                if integer'value( to_string( identifiers( j ).value )) = i then
                   declare
                      fieldName   : unbounded_string;
                      dont_care_t : identifier;
                      dotPos      : natural;
                   begin
                      fieldName := identifiers( j ).name;
                      dotPos := length( fieldName );
                      while dotPos > 1 loop
                         exit when element( fieldName, dotPos ) = '.';
                         dotPos := dotPos - 1;
                      end loop;
                      fieldName := delete( fieldName, 1, dotPos );
                      fieldName := identifiers( ref.id ).name & "." & fieldName;
                      declareIdent( dont_care_t, fieldName, identifiers( j ).kind, varClass );
                   end;
                end if;
             end if;
         end loop;
     end loop;
  else
     ref.kind := identifiers( ref.id ).kind;
  end if;
end ParseInOutParameter;

end parser_params;
