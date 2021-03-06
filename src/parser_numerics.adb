------------------------------------------------------------------------------
-- Numerics Parckage Parser                                                 --
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
with ada.numerics.long_elementary_functions,
    ada.numerics.float_random,
    ada.numerics.long_complex_types,
    ada.numerics.long_complex_elementary_functions,
    ada.strings.unbounded,
    interfaces,
    world,
    scanner,
    parser_aux,
    parser_params,
    parser,
    md5;
use ada.numerics.long_elementary_functions,
    ada.numerics.long_complex_types,
    ada.numerics.long_complex_elementary_functions,
    ada.strings,
    ada.strings.unbounded,
    interfaces,
    world,
    scanner,
    parser_aux,
    parser_params,
    parser,
    md5;

package body parser_numerics is

type hash_integer is mod 2**32;

serialNumber : long_float := 0.0;

-----------------------------------------------------------------------------

--discard_result : boolean;

-----------------------------------------------------------------------------

procedure ParseNumericsRandom( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: random
  -- Source: Ada.Numerics.Float_Random.Random
begin
  kind := float_t;
  result := null_unbounded_string;
  expect( random_t );
  if isExecutingCommand then
     result := to_unbounded_string( long_float( Ada.Numerics.Float_Random.Random(
       random_generator ) ) );
  end if;
end ParseNumericsRandom;

procedure ParseNumericsShiftLeft( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.shift_left( x, b )
  -- Source: Interfaces
  expr_val  : unbounded_string;
  expr_type : identifier;
  amt_val   : unbounded_string;
  amt_type  : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( shift_left_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseLastNumericParameter( amt_val, amt_type, natural_t );
  begin
     if isExecutingCommand then
        result := to_unbounded_string( long_float( shift_left(
           unsigned_64( to_numeric( expr_val ) ),
           natural( to_numeric( amt_val ) )
        ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsShiftLeft;

procedure ParseNumericsShiftRight( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.shift_right( x, b )
  -- Source: Interfaces
  expr_val  : unbounded_string;
  expr_type : identifier;
  amt_val   : unbounded_string;
  amt_type  : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( shift_right_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseLastNumericParameter( amt_val, amt_type, natural_t );
  begin
     if isExecutingCommand then
        result := to_unbounded_string( long_float( shift_right(
           unsigned_64( to_numeric( expr_val ) ),
           natural( to_numeric( amt_val ) )
        ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsShiftRight;

procedure ParseNumericsRotateLeft( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.rotate_left( x, b )
  -- Source: Interfaces
  expr_val  : unbounded_string;
  expr_type : identifier;
  amt_val   : unbounded_string;
  amt_type  : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( rotate_left_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseLastNumericParameter( amt_val, amt_type, natural_t );
  begin
     if isExecutingCommand then
        result := to_unbounded_string( long_float( rotate_left(
           unsigned_64( to_numeric( expr_val ) ),
           natural( to_numeric( amt_val ) )
        ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsRotateLeft;

procedure ParseNumericsRotateRight( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.rotate_right( x, b )
  -- Source: Interfaces
  expr_val  : unbounded_string;
  expr_type : identifier;
  amt_val   : unbounded_string;
  amt_type  : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( rotate_right_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseLastNumericParameter( amt_val, amt_type, natural_t );
  begin
     if isExecutingCommand then
        result := to_unbounded_string( long_float( rotate_right(
           unsigned_64( to_numeric( expr_val ) ),
           natural( to_numeric( amt_val ) )
        ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsRotateRight;

procedure ParseNumericsASR( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.shift_right_arithmetic( x, b )
  -- Source: Interfaces
  expr_val  : unbounded_string;
  expr_type : identifier;
  amt_val   : unbounded_string;
  amt_type  : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( shift_right_arith_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseLastNumericParameter( amt_val, amt_type, natural_t );
  begin
     if isExecutingCommand then
        result := to_unbounded_string( long_float( shift_right_arithmetic(
           unsigned_64( to_numeric( expr_val ) ),
           natural( to_numeric( amt_val ) )
        ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsASR;

procedure ParseNumericsSqrt( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.sqrt( expr );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Sqrt
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( sqrt_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
       result := to_unbounded_string( sqrt( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsSqrt;

procedure ParseNumericsLog( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.log( expr [,base] )
  -- Source: Ada.Numerics.Long_Elementary_Functions.Log
  expr_val  : unbounded_string;
  expr_type : identifier;
  base_val  : unbounded_string;
  base_type : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( log_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  if token = symbol_t and identifiers( token ).value = "," then
     ParseLastNumericParameter( base_val, base_type );
  else
     expect( symbol_t, ")" );
  end if;
  begin
     if isExecutingCommand then
        if base_type = eof_t then
           result := to_unbounded_string( log( to_numeric( expr_val ) ) );
        else
           result := to_unbounded_string( log( to_numeric( expr_val ),
             to_numeric( base_val ) ) );
        end if;
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsLog;

procedure ParseNumericsExp( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.exp( expr );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Exp
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( exp_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
        result := to_unbounded_string( exp( to_numeric( expr_val ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsExp;

procedure ParseNumericsSin( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.sin( expr, [,cycle] );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Sin
  expr_val : unbounded_string;
  expr_type : identifier;
  cycle_val  : unbounded_string;
  cycle_type : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( sin_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  if token = symbol_t and identifiers( token ).value = "," then
     ParseLastNumericParameter( cycle_val, cycle_type );
  else
     expect( symbol_t, ")" );
  end if;
  begin
     if isExecutingCommand then
        if cycle_type = eof_t then
           result := to_unbounded_string( sin( to_numeric( expr_val ) ) );
        else
           result := to_unbounded_string( sin( to_numeric( expr_val ),
             to_numeric( cycle_val ) ) );
        end if;
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsSin;

procedure ParseNumericsCos( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.cos( expr, [,cycle] );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Cos
  expr_val : unbounded_string;
  expr_type : identifier;
  cycle_val  : unbounded_string;
  cycle_type : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( cos_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  if token = symbol_t and identifiers( token ).value = "," then
     ParseLastNumericParameter( cycle_val, cycle_type );
  else
     expect( symbol_t, ")" );
  end if;
  begin
    if isExecutingCommand then
       if cycle_type = eof_t then
          result := to_unbounded_string( cos( to_numeric( expr_val ) ) );
       else
          result := to_unbounded_string( cos( to_numeric( expr_val ),
            to_numeric( cycle_val ) ) );
       end if;
    end if;
  exception when others =>
     err( "exception raised" );
     raise;
  end;
end ParseNumericsCos;

procedure ParseNumericsTan( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.tan( expr, [,cycle] );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Tan
  expr_val : unbounded_string;
  expr_type : identifier;
  cycle_val  : unbounded_string;
  cycle_type : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( tan_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  if token = symbol_t and identifiers( token ).value = "," then
     ParseLastNumericParameter( cycle_val, cycle_type );
  else
     expect( symbol_t, ")" );
  end if;
  begin
    if isExecutingCommand then
       if cycle_type = eof_t then
          result := to_unbounded_string( tan( to_numeric( expr_val ) ) );
       else
          result := to_unbounded_string( tan( to_numeric( expr_val ),
            to_numeric( cycle_val ) ) );
       end if;
    end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsTan;

procedure ParseNumericsCot( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.cot( expr, [,cycle] );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Cot
  expr_val : unbounded_string;
  expr_type : identifier;
  cycle_val  : unbounded_string;
  cycle_type : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( cot_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  if token = symbol_t and identifiers( token ).value = "," then
     ParseLastNumericParameter( cycle_val, cycle_type );
  else
     expect( symbol_t, ")" );
  end if;
  begin
    if isExecutingCommand then
       if cycle_type = eof_t then
          result := to_unbounded_string( cot( to_numeric( expr_val ) ) );
       else
          result := to_unbounded_string( cot( to_numeric( expr_val ),
            to_numeric( cycle_val ) ) );
       end if;
    end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsCot;

procedure ParseNumericsArcSin( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.ArcSin( expr, [,cycle] );
  -- Source: Ada.Numerics.Long_Elementary_Functions.ArcSin
  expr_val : unbounded_string;
  expr_type : identifier;
  cycle_val  : unbounded_string;
  cycle_type : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( arcsin_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  if token = symbol_t and identifiers( token ).value = "," then
     ParseLastNumericParameter( cycle_val, cycle_type );
  else
     expect( symbol_t, ")" );
  end if;
  begin
    if isExecutingCommand then
       if cycle_type = eof_t then
          result := to_unbounded_string( arcsin( to_numeric( expr_val ) ) );
       else
          result := to_unbounded_string( arcsin( to_numeric( expr_val ),
            to_numeric( cycle_val ) ) );
       end if;
    end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsArcSin;

procedure ParseNumericsArcCos( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.ArcCos( expr, [,cycle] );
  -- Source: Ada.Numerics.Long_Elementary_Functions.ArcCos
  expr_val : unbounded_string;
  expr_type : identifier;
  cycle_val  : unbounded_string;
  cycle_type : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( arccos_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  if token = symbol_t and identifiers( token ).value = "," then
     ParseLastNumericParameter( cycle_val, cycle_type );
  else
     expect( symbol_t, ")" );
  end if;
  begin
    if isExecutingCommand then
       if cycle_type = eof_t then
          result := to_unbounded_string( arccos( to_numeric( expr_val ) ) );
       else
          result := to_unbounded_string( arccos( to_numeric( expr_val ),
            to_numeric( cycle_val ) ) );
       end if;
    end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsArcCos;

procedure ParseNumericsArcTan( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.ArcTan( expr, expr2, [,cycle] );
  -- Source: Ada.Numerics.Long_Elementary_Functions.ArcTan
  -- note: second parameter is not optional in mine but is in Ada
  expr_val : unbounded_string;
  expr_type : identifier;
  expr2_val : unbounded_string;
  expr2_type : identifier;
  cycle_val  : unbounded_string;
  cycle_type : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( arctan_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseNextNumericParameter( expr2_val, expr2_type );
  if token = symbol_t and identifiers( token ).value = "," then
     ParseLastNumericParameter( cycle_val, cycle_type );
  else
     expect( symbol_t, ")" );
  end if;
  begin
    if isExecutingCommand then
       if cycle_type = eof_t then
          result := to_unbounded_string( arctan( to_numeric( expr_val ),
            to_numeric( expr2_val )) );
       else
          result := to_unbounded_string( arctan( to_numeric( expr_val ),
            to_numeric( expr2_val ), to_numeric( cycle_val ) ) );
       end if;
    end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsArcTan;

procedure ParseNumericsArcCot( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.ArcCot( expr, expr2, [,cycle] );
  -- Source: Ada.Numerics.Long_Elementary_Functions.ArcCot
  -- note: second parameter is not optional in mine but is in Ada
  expr_val : unbounded_string;
  expr_type : identifier;
  expr2_val : unbounded_string;
  expr2_type : identifier;
  cycle_val  : unbounded_string;
  cycle_type : identifier := eof_t;
begin
  kind := uni_numeric_t;
  expect( arccot_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseNextNumericParameter( expr2_val, expr2_type );
  if token = symbol_t and identifiers( token ).value = "," then
     ParseLastNumericParameter( cycle_val, cycle_type );
  else
     expect( symbol_t, ")" );
  end if;
  begin
    if isExecutingCommand then
       if cycle_type = eof_t then
          result := to_unbounded_string( arccot( to_numeric( expr_val ),
            to_numeric( expr2_val )) );
       else
          result := to_unbounded_string( arccot( to_numeric( expr_val ),
            to_numeric( expr2_val ), to_numeric( cycle_val ) ) );
       end if;
    end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsArcCot;

procedure ParseNumericsSinH( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.Sinh( expr );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Sinh
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( sinh_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
       result := to_unbounded_string( sinh( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsSinH;

procedure ParseNumericsCosH( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.Cosh( expr );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Cosh
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( cosh_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
       result := to_unbounded_string( cosh( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsCosH;

procedure ParseNumericsTanH( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.Tanh( expr );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Tanh
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( tanh_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
       result := to_unbounded_string( tanh( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsTanH;

procedure ParseNumericsCoth( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.Coth( expr );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Coth
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( coth_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
       result := to_unbounded_string( coth( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsCotH;

procedure ParseNumericsArcSinH( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.arcsinh( expr );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Arcsinh
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( arcsinh_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
       result := to_unbounded_string( arcsinh( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsArcSinH;

procedure ParseNumericsArcCosH( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.arccosh( expr );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Arccosh
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( arccosh_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
       result := to_unbounded_string( arccosh( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsArcCosH;

procedure ParseNumericsArcTanH( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.arctanh( expr );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Arctanh
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( arctanh_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
       result := to_unbounded_string( arctanh( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsArcTanH;

procedure ParseNumericsArcCotH( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.arccoth( expr );
  -- Source: Ada.Numerics.Long_Elementary_Functions.Arccosh
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( arccoth_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
       result := to_unbounded_string( arccoth( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsArcCotH;

procedure ParseNumericsFloor( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.floor( expr );
  -- Source: Ada 'floor attribute
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( floor_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
       result := to_unbounded_string( long_float'floor( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsFloor;

procedure ParseNumericsCeiling( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.ceiling( expr );
  -- Source: Ada 'ceiling attribute
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( ceiling_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
       result := to_unbounded_string( long_float'ceiling( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsCeiling;

procedure ParseNumericsRounding( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.rounding( expr );
  -- Source: Ada 'rounding attribute
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( rounding_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
      result := to_unbounded_string( long_float'rounding( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsRounding;

procedure ParseNumericsUnbiasedRounding( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.unbiased_rounding( expr );
  -- Source: Ada 'unbiased_rounding attribute
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( unbiased_rounding_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
      result := to_unbounded_string( long_float'unbiased_rounding( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsUnbiasedRounding;

procedure ParseNumericsTruncation( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.truncation( expr );
  -- Source: Ada 'truncation attribute
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( truncation_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
      result := to_unbounded_string( long_float'truncation( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsTruncation;

procedure ParseNumericsRemainder( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.remainder( expr, expr2 );
  -- Source: Ada 'remainder attribute
  expr_val : unbounded_string;
  expr_type : identifier;
  expr2_val : unbounded_string;
  expr2_type : identifier;
begin
  kind := uni_numeric_t;
  expect( remainder_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseLastNumericParameter( expr2_val, expr2_type );
  begin
     if isExecutingCommand then
       result := to_unbounded_string( long_float'remainder( to_numeric( expr_val ),
         to_numeric( expr2_val ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsRemainder;

procedure ParseNumericsExponent( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.exponent( expr );
  -- Source: Ada 'exponent attribute
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( exponent_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
      result := to_unbounded_string( long_float( long_float'exponent( to_numeric( expr_val ) ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsExponent;

procedure ParseNumericsFraction( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.fraction( expr );
  -- Source: Ada 'fraction attribute
  expr_val : unbounded_string;
  expr_type : identifier;
begin
  kind := uni_numeric_t;
  expect( fraction_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
      result := to_unbounded_string( long_float'fraction( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsFraction;

procedure ParseNumericsLeadingPart( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.leading_part( expr, expr2 );
  -- Source: Ada 'leading_part attribute
  expr_val : unbounded_string;
  expr_type : identifier;
  expr2_val : unbounded_string;
  expr2_type : identifier;
begin
  kind := uni_numeric_t;
  expect( leading_part_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseLastNumericParameter( expr2_val, expr2_type );
  begin
     if isExecutingCommand then
       result := to_unbounded_string( long_float'leading_part( to_numeric( expr_val ),
         integer( to_numeric( expr2_val ) ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsLeadingPart;

procedure ParseNumericsCopySign( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.copy_sign( expr, expr2 );
  -- Source: Ada 'copy_sign attribute
  expr_val : unbounded_string;
  expr_type : identifier;
  expr2_val : unbounded_string;
  expr2_type : identifier;
begin
  kind := uni_numeric_t;
  expect( copy_sign_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseLastNumericParameter( expr2_val, expr2_type );
  begin
     if isExecutingCommand then
       result := to_unbounded_string( long_float'copy_sign( to_numeric( expr_val ),
         to_numeric( expr2_val ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsCopySign;

procedure ParseNumericsSturges( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.sturges( low, high, total );
  -- Source: BUSH builtin, Sturge's method
  lo_val : unbounded_string;
  lo_type : identifier;
  hi_val : unbounded_string;
  hi_type : identifier;
  total_val : unbounded_string;
  total_type : identifier;
  lo, hi, total : long_float;
begin
  kind := uni_numeric_t;
  expect( sturges_t );
  ParseFirstNumericParameter( lo_val, lo_type );
  ParseNextNumericParameter( hi_val, hi_type );
  ParseLastNumericParameter( total_val, total_type );
  expect( symbol_t, "(" );
  ParseExpression( lo_val, lo_type );
  if uniTypesOk( lo_type, uni_numeric_t ) then
     expect( symbol_t, "," );
     ParseExpression( hi_val, hi_type );
     if uniTypesOk( hi_type, uni_numeric_t ) then
        expect( symbol_t, "," );
        ParseExpression( total_val, total_type );
        if uniTypesOk( total_type, uni_numeric_t ) then
           expect( symbol_t, ")" );
        end if;
     end if;
  end if;
  begin
     if isExecutingCommand then
        lo := to_numeric( lo_val );
        hi := to_numeric( hi_val );
        total := to_numeric( total_val );
        result := to_unbounded_string( long_float'rounding( (hi-lo) / (1.0+log( total ) ) ) ); -- this is wrong
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsSturges;

procedure ParseNumericsMax( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.max( expr, expr2 );
  -- Source: Ada 'max attribute
  expr_val : unbounded_string;
  expr_type : identifier;
  expr2_val : unbounded_string;
  expr2_type : identifier;
begin
  kind := uni_numeric_t;
  expect( max_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseLastNumericParameter( expr2_val, expr2_type );
  begin
     if isExecutingCommand then
       result := to_unbounded_string( long_float'max( to_numeric( expr_val ),
         to_numeric( expr2_val ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsMax;

procedure ParseNumericsMin( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.max( expr, expr2 );
  -- Source: Ada 'max attribute
  expr_val : unbounded_string;
  expr_type : identifier;
  expr2_val : unbounded_string;
  expr2_type : identifier;
begin
  kind := uni_numeric_t;
  expect( min_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseLastNumericParameter( expr2_val, expr2_type );
  begin
     if isExecutingCommand then
       result := to_unbounded_string( long_float'min( to_numeric( expr_val ),
         to_numeric( expr2_val ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsMin;

procedure ParseNumericsMachine( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.machine( expr, expr2 );
  -- Source: Ada 'machine attribute
  expr_val   : unbounded_string;
  expr_type  : identifier;
begin
  kind := uni_numeric_t;
  expect( machine_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
    if isExecutingCommand then
      result := to_unbounded_string( long_float'machine( to_numeric( expr_val ) ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsMachine;

procedure ParseNumericsScaling( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.scaling( expr, expr2 );
  -- Source: Ada 'scaling attribute
  expr_val   : unbounded_string;
  expr_type  : identifier;
  expr2_val  : unbounded_string;
  expr2_type : identifier;
begin
  kind := uni_numeric_t;
  expect( scaling_t );
  ParseFirstNumericParameter( expr_val, expr_type );
  ParseLastNumericParameter( expr2_val, expr2_type, integer_t );
  begin
     if isExecutingCommand then
       result := to_unbounded_string( long_float'scaling( to_numeric( expr_val ),
         integer( to_numeric( expr2_val ) ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsScaling;

procedure ParseNumericsValue( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.value( expr, expr2 );
  -- Source: Ada 'value attribute
  expr_val   : unbounded_string;
  expr_type  : identifier;
begin
  kind := uni_numeric_t;
  expect( value_t );
  ParseSingleStringParameter( expr_val, expr_type, string_t );
  begin
     if isExecutingCommand then
       --result := trim( to_unbounded_string( to_numeric( expr_val ) ), left );
       result := to_unbounded_string( to_numeric( expr_val ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsValue;

procedure ParseNumericsPos( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.pos( character );
  -- Source: Ada 'pos attribute
  expr_val   : unbounded_string;
  expr_type  : identifier;
begin
  kind := positive_t;
  expect( pos_t );
  ParseSingleStringParameter( expr_val, expr_type, character_t );
  begin
     if isExecutingCommand then
       --result := trim( to_unbounded_string( character'pos( Element( expr_val, 1 ) )'img ), left );
       result := to_unbounded_string( character'pos( Element( expr_val, 1 ) )'img );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsPos;

procedure ParseNumericsAbs( result : out unbounded_string ) is
  -- Syntax: numerics.abs( n );
  -- Source: Ada abs function
  expr_val   : unbounded_string;
  expr_type  : identifier;
begin
  expect( abs_t );
  ParseSingleNumericParameter( expr_val, expr_type );
  begin
     if isExecutingCommand then
       --result := trim( to_unbounded_string( abs( to_numeric( expr_val ) ) ), left );
       result := to_unbounded_string( abs( to_numeric( expr_val ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsAbs;

procedure ParseNumericsMd5( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.md5( s );
  -- Source: MD5.Disgest_To_Text
  expr_val   : unbounded_string;
  expr_type  : identifier;
  C          : Context;
  FP         : Fingerprint;
begin
  kind := string_t;
  expect( numerics_md5_t );
  ParseSingleStringParameter( expr_val, expr_type, string_t );
  begin
     if isExecutingCommand then
       Init( C );
       Update( C, to_string( expr_val ) );
       Final( C, FP );
       result := to_unbounded_string( Digest_To_Text( FP ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsMd5;

procedure ParseNumericsSerial( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: serial
  -- Source: N/A
begin
  kind := natural_t;
  result := null_unbounded_string;
  expect( serial_t );
  if isExecutingCommand then
     --result := trim( to_unbounded_string( serialNumber ), left );
     result := to_unbounded_string( serialNumber );
     if serialNumber = maxInteger then
        serialNumber := 0.0;
     else
        serialNumber := serialNumber + 1.0;
     end if;
  end if;
end ParseNumericsSerial;

procedure ParseNumericsRnd( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.rnd( n );
  -- Source: N/A
  expr_val   : unbounded_string;
  expr_type  : identifier;
begin
  kind := positive_t;
  expect( rnd_t );
  ParseSingleNumericParameter( expr_val, expr_type, positive_t );
  begin
     if isExecutingCommand then
       result := to_unbounded_string(  1.0 +
          long_float'truncation( to_numeric( expr_val ) *
             long_float( Ada.Numerics.Float_Random.Random( random_generator ) ) ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsRnd;

procedure ParseNumericsOdd( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.odd( n );
  -- Source: N/A
  expr_val   : unbounded_string;
  expr_type  : identifier;
begin
  kind := boolean_t;
  expect( odd_t );
  ParseSingleNumericParameter( expr_val, expr_type, integer_t );
  begin
     if isExecutingCommand then
       result := to_bush_boolean( integer( to_numeric( expr_val ) ) mod 2 = 1 );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsOdd;

procedure ParseNumericsEven( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.even( n );
  -- Source: N/A
  expr_val   : unbounded_string;
  expr_type  : identifier;
begin
  kind := boolean_t;
  expect( even_t );
  ParseSingleNumericParameter( expr_val, expr_type, integer_t );
  begin
     if isExecutingCommand then
       result := to_bush_boolean( integer( to_numeric( expr_val ) ) mod 2 = 0 );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsEven;

procedure ParseNumericsRe( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: r := numerics.re( n );
  -- Source: N/A
  record_id : identifier;
  c : complex;
  real_t      : identifier;
  img_t       : identifier;
begin
  kind := long_float_t;
  expect( numerics_re_t );
  expect( symbol_t, "(" );
  ParseIdentifier( record_id );
  if baseTypesOk( identifiers( record_id ).kind, complex_t ) then
     expect( symbol_t, ")" );
  end if;
  begin
     if isExecutingCommand then
       findField( record_id, 1, real_t );
       findField( record_id, 2, img_t );
       c.re := to_numeric( identifiers( real_t ).value );
       c.im := to_numeric( identifiers( img_t ).value );
       result := to_unbounded_string( Re( c ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsRe;

procedure ParseNumericsIm( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: r := numerics.im( n );
  -- Source: N/A
  record_id : identifier;
  c : complex;
  real_t      : identifier;
  img_t       : identifier;
begin
  kind := long_float_t;
  expect( numerics_im_t );
  expect( symbol_t, "(" );
  ParseIdentifier( record_id );
  if baseTypesOk( identifiers( record_id ).kind, complex_t ) then
     expect( symbol_t, ")" );
  end if;
  begin
     if isExecutingCommand then
       findField( record_id, 1, real_t );
       findField( record_id, 2, img_t );
       c.re := to_numeric( identifiers( real_t ).value );
       c.im := to_numeric( identifiers( img_t ).value );
       result := to_unbounded_string( Im( c ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsIm;

procedure ParseNumericsSetRe is
  -- Syntax: numerics.set_re( n );
  -- Source: N/A
  expr_val : unbounded_string;
  expr_type : identifier;
  record_id : identifier;
  c : complex;
  real_t      : identifier;
  img_t       : identifier;
begin
  expect( numerics_set_re_t );
  expect( symbol_t, "(" );
  ParseIdentifier( record_id );
  if baseTypesOk( identifiers( record_id ).kind, complex_t ) then
     expect( symbol_t, "," );
     ParseExpression( expr_val, expr_type );
     if baseTypesOk( expr_type, long_float_t ) then
        expect( symbol_t, ")" );
     end if;
  end if;
  begin
     if isExecutingCommand then
       findField( record_id, 1, real_t );
       findField( record_id, 2, img_t );
       c.re := to_numeric( identifiers( real_t ).value );
       c.im := to_numeric( identifiers( img_t ).value );
       Set_Re( c, to_numeric( expr_val ) );
       identifiers( real_t ).value := to_unbounded_string( c.re );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsSetRe;

procedure ParseNumericsSetIm is
  -- Syntax: numerics.set_im( n );
  -- Source: N/A
  expr_val    : unbounded_string;
  expr_type   : identifier;
  record_id   : identifier;
  real_t      : identifier;
  img_t       : identifier;
  c : complex;
begin
  expect( numerics_set_im_t );
  expect( symbol_t, "(" );
  ParseIdentifier( record_id );
  if baseTypesOk( identifiers( record_id ).kind, complex_t ) then
     expect( symbol_t, "," );
     ParseExpression( expr_val, expr_type );
     if baseTypesOk( expr_type, long_float_t ) then
        expect( symbol_t, ")" );
     end if;
  end if;
  begin
     if isExecutingCommand then
       findField( record_id, 1, real_t );
       findField( record_id, 2, img_t );
       c.re := to_numeric( identifiers( real_t ).value );
       c.im := to_numeric( identifiers( img_t ).value );
       Set_Im( c, to_numeric( expr_val ) );
       identifiers( img_t ).value := to_unbounded_string( c.Im );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsSetIm;

-- Can't return a new complex expression
--
--procedure ParseNumericsSetComposeFromCartisian( result : out unbounded_string ) is
  -- Syntax: r := numerics.compose_from_cartisian( r [, i] );
  -- Source: N/A
  --expr_val   : unbounded_string;
  --expr_type  : identifier;
--begin
  --expect( _t );
  --expect( symbol_t, "(" );
  --ParseExpression( expr_val, expr_type );
  --if baseTypesOk( expr_type, complex_t ) then
     --expect( symbol_t, ")" );
  --end if;
  --begin
     --if isExecutingCommand then
       --result := to_numeric( expr_val );
     --end if;
  --exception when others =>
     --err( "exception raised" );
  --end;
--end ParseNumericsComposeFromCartisian;

procedure ParseNumericsModulus( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: r := numerics.modulus( n );
  -- Source: N/A
  record_id   : identifier;
  c : complex;
  real_t      : identifier;
  img_t       : identifier;
begin
  kind := long_float_t;
  expect( numerics_modulus_t );
  expect( symbol_t, "(" );
  ParseIdentifier( record_id );
  if baseTypesOk( identifiers( record_id ).kind, complex_t ) then
     expect( symbol_t, ")" );
  end if;
  begin
     if isExecutingCommand then
       findField( record_id, 1, real_t );
       findField( record_id, 2, img_t );
       c.re := to_numeric( identifiers( real_t ).value );
       c.im := to_numeric( identifiers( img_t ).value );
       result := to_unbounded_string( Modulus( c ) );
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsModulus;

-- abs is a renaming of modulus

procedure ParseNumericsArgument( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: r := numerics.argument( n [,c] );
  -- Source: N/A
  record_id   : identifier;
  cycle_val   : unbounded_string;
  cycle_type  : identifier;
  has_cycle   : boolean := false;
  c : complex;
  real_t      : identifier;
  img_t       : identifier;
begin
  kind := long_float_t;
  expect( numerics_argument_t );
  expect( symbol_t, "(" );
  ParseIdentifier( record_id );
  if baseTypesOk( identifiers( record_id ).kind, complex_t ) then
     if token = symbol_t and identifiers( token ).value = "," then
        expect( symbol_t, "," );
        ParseExpression( cycle_val, cycle_type );
        has_cycle := true;
     end if;
     expect( symbol_t, ")" );
  end if;
  begin
     if isExecutingCommand then
       findField( record_id, 1, real_t );
       findField( record_id, 2, img_t );
       c.re := to_numeric( identifiers( real_t ).value );
       c.im := to_numeric( identifiers( img_t ).value );
       if has_cycle then
          result := to_unbounded_string( Argument( c, to_numeric( cycle_val ) ) );
       else
          result := to_unbounded_string( Argument( c ) );
       end if;
     end if;
  exception when others =>
     err( "exception raised" );
  end;
end ParseNumericsArgument;

-- Can't return record expressions
--procedure ParseNumericsComposeFromPolar( result : out unbounded_string ) is
  -- Syntax: r := numerics.compose_from_polar( n ,a );
  -- Source: N/A
  --expr_val   : unbounded_string;
  --expr_type  : identifier;
--begin
  --expect( _t );
  --expect( symbol_t, "(" );
  --ParseExpression( expr_val, expr_type );
  --if baseTypesOk( expr_type, complex_t ) then
     --expect( symbol_t, ")" );
  --end if;
  --begin
     --if isExecutingCommand then
--       result := to_numeric( expr_val );
 --    end if;
  --exception when others =>
   --  err( "exception raised" );
  --end;
--end ParseNumericsComposeFromPolar;

-- Can't return a record expression
--procedure ParseNumericsConjugate( result : out unbounded_string ) is
  -- Syntax: r := numerics.conjugate( n );
  -- Source: N/A
  --expr_val   : unbounded_string;
  --expr_type  : identifier;
--begin
  --expect( _t );
  --expect( symbol_t, "(" );
  --ParseExpression( expr_val, expr_type );
  --if baseTypesOk( expr_type, complex_t ) then
     --expect( symbol_t, ")" );
  --end if;
  --begin
     --if isExecutingCommand then
       --result := to_numeric( expr_val );
     --end if;
  --exception when others =>
     --err( "exception raised" );
  --end;
--end ParseNumericsConjugate;

procedure ParseNumericsHashOf( result : out unbounded_string; kind : out identifier) is
  -- Syntax: numerics.hash_of( s, l )
  expr1_val   : unbounded_string;
  expr1_type  : identifier;
  expr2_val   : unbounded_string;
  expr2_type  : identifier;
begin
  kind := natural_t;
  expect( hash_of_t );
  ParseFirstNumericParameter( expr1_val, expr1_type, string_t );
  ParseLastNumericParameter( expr2_val, expr2_type, natural_t );
  declare
    limit : hash_integer;
    hash : hash_integer := 5381;
  begin
    limit := hash_integer( to_numeric( expr2_val ) );
    if isExecutingCommand then
       for i in 1..length(expr1_val) loop
           hash := (hash*37 + hash) + character'pos(element(expr1_val,i));
       end loop;
       hash := (hash mod limit) + 1;
       result := to_unbounded_string( long_float( hash ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsHashOf;

procedure ParseNumericsSdbmHashOf( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.sdbm_hash_of( s, l )
  expr1_val   : unbounded_string;
  expr1_type  : identifier;
  expr2_val   : unbounded_string;
  expr2_type  : identifier;
begin
  kind := natural_t;
  expect( sdbm_hash_of_t );
  ParseFirstNumericParameter( expr1_val, expr1_type, string_t );
  ParseLastNumericParameter( expr2_val, expr2_type, natural_t );
  declare
    limit : hash_integer;
    hash : hash_integer := 0;
  begin
    limit := hash_integer( to_numeric( expr2_val ) );
    if isExecutingCommand then
       for i in 1..length(expr1_val) loop
           hash := character'pos(element(expr1_val,i)) + (hash*64) + (hash*65536
) - hash;
       end loop;
       hash := (hash mod limit) + 1;
       result := to_unbounded_string( long_float( hash ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsSdbmHashOf;

procedure ParseNumericsFnvHashOf( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.fnv_hash_of( s, l )
  expr1_val   : unbounded_string;
  expr1_type  : identifier;
  expr2_val   : unbounded_string;
  expr2_type  : identifier;
begin
  kind := natural_t;
  expect( fnv_hash_of_t );
  ParseFirstNumericParameter( expr1_val, expr1_type, string_t );
  ParseLastNumericParameter( expr2_val, expr2_type, natural_t );
  declare
    hash   : hash_integer := 16#811c9dc5#;
    k      : hash_integer;
    limit  : hash_integer;
  begin
    limit := hash_integer( to_numeric( expr2_val ) );
    if isExecutingCommand then
       for data in 1..length(expr1_val)-3 loop
           k := character'pos( element(expr1_val, data) ) +
                character'pos( element(expr1_val, data+1) ) * 256 +     -- 8
                character'pos( element(expr1_val, data+2) ) * 65536 +   -- 16
                character'pos( element(expr1_val, data+3) ) * 16777216; -- 24
            hash := hash xor k;
            hash := hash * 16#01000193#;
       end loop;
       hash := (hash mod limit) + 1;
       result := to_unbounded_string( long_float( hash ) );
    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsFnvHashOf;

procedure ParseNumericsMurmurHashOf( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: numerics.murmur_hash_of( s, l )
  expr1_val   : unbounded_string;
  expr1_type  : identifier;
  expr2_val   : unbounded_string;
  expr2_type  : identifier;
begin
  kind := natural_t;
  expect( murmur_hash_of_t );
  ParseFirstNumericParameter( expr1_val, expr1_type, string_t );
  ParseLastNumericParameter( expr2_val, expr2_type, natural_t );
  declare
    seed : constant hash_integer := 16#811c9dc5#;
    m : constant hash_integer := 16#5bd1e995#;
    r : constant hash_integer := 24;
    hash : hash_integer;
    data : integer := 1;
    k    : hash_integer;
    limit : hash_integer;
    s    : string := to_string( expr1_val );
    len  : integer := s'length;
  begin
    limit := hash_integer( to_numeric( expr2_val ) );
    if isExecutingCommand then
       -- this seed could be more elegnat - random seed here xor len
       hash := hash_integer( s'length ) xor seed;
       while len >= 4 loop
          k := character'pos( s(data) ) +
               character'pos( s(data+1) ) * 256 +      -- 8
               character'pos( s(data+2) ) * 65536 +    -- 16
               character'pos( s(data+3) ) * 16777216;  -- 24
          k := k * m;
          k := k xor (k / (2**integer(r)));
          k := k * m;
          hash := hash * m;
          hash := hash xor k;

          data := data + 4;
          len := len - 4;
       end loop;

       -- Handle the last few bytes of the input array

       case len is
       when 3 => hash := hash xor ( character'pos( s(data+2) ) * 65536 );
                 hash := hash xor ( character'pos( s(data+1) ) * 256 );
                 hash := hash xor ( character'pos( s(data) ) );
                 hash := hash * m;
       when 2 => hash := hash xor ( character'pos( s(data+1) ) * 256 );
                 hash := hash xor ( character'pos( s(data) ) );
                 hash := hash * m;
       when 1 => hash := hash xor ( character'pos( s(data) ) );
                 hash := hash * m;
       when others => null;
       end case;

       -- Do a few final mixes of the hash to ensure the last few
       -- bytes are well-incorporated.

       hash := hash xor ( hash / 8192 ); -- 13
       hash := hash * m;
       hash := hash xor ( hash / 32768 ); -- 15

       hash := (hash mod limit) + 1;

       result := to_unbounded_string( long_float( hash ) );

    end if;
  exception when others =>
    err( "exception raised" );
  end;
end ParseNumericsMurmurHashOf;

procedure StartupNumerics is
begin

  -- Numerics Package identifiers

  declareFunction( random_t, "numerics.random", ParseNumericsRandom'access );
  declareFunction( shift_left_t, "numerics.shift_left", ParseNumericsShiftLeft'access );
  declareFunction( shift_right_t, "numerics.shift_right", ParseNumericsShiftRight'access );
  declareFunction( rotate_left_t, "numerics.rotate_left", ParseNumericsRotateLeft'access );
  declareFunction( rotate_right_t, "numerics.rotate_right", ParseNumericsRotateRight'access );
  declareFunction( shift_right_arith_t, "numerics.shift_right_arithmetic", ParseNumericsASR'access );
  declareFunction( sqrt_t, "numerics.sqrt", ParseNumericsSqrt'access );
  declareFunction( log_t, "numerics.log", ParseNumericsLog'access );
  declareFunction( exp_t, "numerics.exp", ParseNumericsExp'access );
  declareFunction( sin_t, "numerics.sin", ParseNumericsSin'access );
  declareFunction( cos_t, "numerics.cos", ParseNumericsCos'access );
  declareFunction( tan_t, "numerics.tan", ParseNumericsTan'access );
  declareFunction( cot_t, "numerics.cot", ParseNumericsCot'access );
  declareFunction( arcsin_t, "numerics.arcsin", ParseNumericsArcSin'access );
  declareFunction( arccos_t, "numerics.arccos", ParseNumericsArcCos'access );
  declareFunction( arctan_t, "numerics.arctan", ParseNumericsArcTan'access );
  declareFunction( arccot_t, "numerics.arccot", ParseNumericsArcCot'access );
  declareFunction( sinh_t, "numerics.sinh", ParseNumericsSinH'access );
  declareFunction( cosh_t, "numerics.cosh", ParseNumericsCosH'access );
  declareFunction( tanh_t, "numerics.tanh", ParseNumericsTanH'access );
  declareFunction( coth_t, "numerics.coth", ParseNumericsCotH'access );
  declareFunction( arcsinh_t, "numerics.arcsinh", ParseNumericsArcSinH'access );
  declareFunction( arccosh_t, "numerics.arccosh", ParseNumericsArcCosH'access );
  declareFunction( arctanh_t, "numerics.arctanh", ParseNumericsArcTanH'access );
  declareFunction( arccoth_t, "numerics.arccoth", ParseNumericsArcCotH'access );
  declareFunction( floor_t, "numerics.floor", ParseNumericsFloor'access );
  declareFunction( ceiling_t, "numerics.ceiling", ParseNumericsCeiling'access );
  declareFunction( rounding_t, "numerics.rounding", ParseNumericsRounding'access );
  declareFunction( unbiased_rounding_t, "numerics.unbiased_rounding", ParseNumericsUnbiasedRounding'access );
  declareFunction( truncation_t, "numerics.truncation", ParseNumericsTruncation'access );
  declareFunction( remainder_t, "numerics.remainder", ParseNumericsRemainder'access );
  declareFunction( exponent_t, "numerics.exponent", ParseNumericsExponent'access );
  declareFunction( fraction_t, "numerics.fraction", ParseNumericsFraction'access );
  declareFunction( leading_part_t, "numerics.leading_part", ParseNumericsLeadingPart'access );
  declareFunction( copy_sign_t, "numerics.copy_sign", ParseNumericsCopySign'access );
  declareFunction( sturges_t, "numerics.sturges", ParseNumericsSturges'access );
  declareFunction( max_t, "numerics.max", ParseNumericsMax'access );
  declareFunction( min_t, "numerics.min", ParseNumericsMin'access );
  declareFunction( machine_t, "numerics.machine", ParseNumericsMachine'access );
  declareFunction( scaling_t, "numerics.scaling", ParseNumericsScaling'access );
  declareFunction( value_t, "numerics.value", ParseNumericsValue'access );
  declareFunction( pos_t, "numerics.pos", ParseNumericsPos'access );
  declareFunction( numerics_md5_t, "numerics.md5", ParseNumericsMd5'access );
  declareFunction( serial_t, "numerics.serial", ParseNumericsSerial'access );
  declareFunction( rnd_t, "numerics.rnd", ParseNumericsRnd'access );
  declareFunction( odd_t, "numerics.odd", ParseNumericsOdd'access );
  declareFunction( even_t, "numerics.even", ParseNumericsEven'access );
  declareFunction( numerics_re_t, "numerics.re", ParseNumericsRe'access );
  declareFunction( numerics_im_t, "numerics.im", ParseNumericsIm'access );
  declareProcedure( numerics_set_re_t, "numerics.set_re", ParseNumericsSetRe'access );
  declareProcedure( numerics_set_im_t, "numerics.set_im", ParseNumericsSetIm'access );
  declareFunction( numerics_argument_t, "numerics.argument", ParseNumericsArgument'access );
  declareFunction( numerics_modulus_t, "numerics.modulus", ParseNumericsModulus'access );
  declareFunction( hash_of_t, "numerics.hash_of", ParseNumericsHashOf'access );
  declareFunction( sdbm_hash_of_t, "numerics.sdbm_hash_of", ParseNumericsSdbmHashOf'access );
  declareFunction( fnv_hash_of_t, "numerics.fnv_hash_of", ParseNumericsFnvHashOf'access );
  declareFunction( murmur_hash_of_t, "numerics.murmur_hash_of", ParseNumericsMurmurHashOf'access );

  -- Numerics package constants
  -- There's are derived from the GNU standard C library math constants

  declareStandardConstant( numerics_e_t, "numerics.e", long_float_t,
      "2.7182818284590452354" );
  declareStandardConstant( numerics_log2_e_t, "numerics.log2_e", long_float_t,
      "1.4426950408889634074" );
  declareStandardConstant( numerics_log10_e_t, "numerics.log10_e", long_float_t,
      "0.43429448190325182765" );
  declareStandardConstant( numerics_ln10_t, "numerics.ln2", long_float_t,
      "0.69314718055994530942" );
  declareStandardConstant( numerics_ln2_t, "numerics.ln10", long_float_t,
      "2.30258509299404568402" );
  declareStandardConstant( numerics_pi_t, "numerics.pi", long_float_t,
      "3.14159265358979323846" );
  declareStandardConstant( numerics_pi_by_2_t, "numerics.pi_by_2", long_float_t,
      "1.57079632679489661923" );
  declareStandardConstant( numerics_pi_by_4_t, "numerics.pi_by_4", long_float_t,
      "0.78539816339744830962" );
  declareStandardConstant( numerics_pi_under_1_t, "numerics.pi_under_1", long_float_t,
      "0.31830988618379067154" );
  declareStandardConstant( numerics_pi_under_2_t, "numerics.pi_under_2", long_float_t,
      "0.63661977236758134308" );
  declareStandardConstant( numerics_sqrt_pi_under_2_t, "numerics.sqrt_pi_under_2",
      long_float_t, "1.12837916709551257390" );
  declareStandardConstant( numerics_sqrt_2_t, "numerics.sqrt_2", long_float_t,
      "1.4142135623730950488" );
  declareStandardConstant( numerics_sqrt_2_under_1_t, "numerics.sqrt_2_under_1", long_float_t,
      "0.70710678118654752440" );

end StartupNumerics;

procedure ShutdownNumerics is
begin
  null;
end ShutdownNumerics;

end parser_numerics;
