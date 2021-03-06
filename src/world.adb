------------------------------------------------------------------------------
-- Common declarations across most of SparForte/BUSH including              --
-- command line switches and the symbol table.                              --
--                                                                          --
-- Part of SparForte                                                        --
------------------------------------------------------------------------------
--                                                                          --
--              Copyright (C) 2001-2011 Free Software Foundation            --
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

pragma warnings( off ); -- suppress Gnat-specific package warning
with ada.command_line.environment;
pragma warnings( on );

with system,
    ada.text_io,
    ada.strings.fixed,
    ada.strings.unbounded.text_io,
    ada.characters.handling,
    gnat.source_info,
    bush_os;
    -- scanner_arrays;
use ada.text_io,
    ada.command_line,
    ada.command_line.environment,
    ada.strings.fixed,
    ada.strings.unbounded,
    ada.strings.unbounded.text_io,
    ada.characters.handling,
    bush_os;
    -- scanner_arrays;

pragma Optimize( time );

package body world is

localMemcacheClusterInitialized : boolean := false;
distributedMemcacheClusterInitialized : boolean := false;
-- flag: only initialize the memcache clusters once

--
-- Symbol Table Utilities
--

procedure declareKeyword( id : out identifier; s : string ) is
-- Initialize a keyword / internal identifier in the symbol table
begin
  if identifiers_top = identifier'last then                     -- no room?
     raise symbol_table_overflow;                               -- raise error
  else                                                          -- else add
     id := identifiers_top;                                     -- return id
     identifiers_top := identifiers_top + 1;                    -- push stack
     declare
       kw : declaration renames identifiers( id );
     begin
       if kw.avalue /= null then
          free( kw.avalue );
       end if;
       kw.name := To_Unbounded_String( s );
       kw.kind := identifier'first;
       kw.value := Null_Unbounded_String;
       kw.class := otherClass;
       -- since keywords are only declared at startup,
       -- the defaults should be OK for remaining fields.
     end;
  end if;
end declareKeyword;

procedure declareFunction( id : out identifier; s : string; cb : aBuiltinFunctionCallback := null ) is
-- Initialize a built-in function identifier in the symbol table
begin
  if identifiers_top = identifier'last then                     -- no room?
     raise symbol_table_overflow;                               -- raise error
  else                                                          -- else add
     id := identifiers_top;                                     -- return id
     identifiers_top := identifiers_top + 1;                    -- push stack
     declare
       kw : declaration renames identifiers( id );
     begin
       if kw.avalue /= null then
          free( kw.avalue );
       end if;
       kw.name := To_Unbounded_String( s );
       kw.kind := identifier'first;
       kw.value := Null_Unbounded_String;
       kw.class := funcClass;
       kw.procCB := null;
       kw.funcCB := cb;
       kw.avalue := null;
     end;
  end if;
end declareFunction;

procedure declareProcedure( id : out identifier; s : string; cb : aBuiltinProcedureCallback := null ) is
-- Initialize a built-in procedure identifier in the symbol table
begin
  if identifiers_top = identifier'last then                     -- no room?
     raise symbol_table_overflow;                               -- raise error
  else                                                          -- else add
     id := identifiers_top;                                     -- return id
     identifiers_top := identifiers_top + 1;                    -- push stack
     declare
       kw : declaration renames identifiers( id );
     begin
       if kw.avalue /= null then
          free( kw.avalue );
       end if;
       kw.name := To_Unbounded_String( s );
       kw.kind := identifier'first;
       kw.value := Null_Unbounded_String;
       kw.class := procClass;
       kw.procCB := cb;
       kw.funcCB := null;
       kw.avalue := null;
     end;
  end if;
end declareProcedure;

procedure findIdent( name : unbounded_string; id : out identifier ) is
-- Return the id of a keyword / identifier in the symbol table.  If
-- it is not found, return the end-of-file token as the id
begin
  id := eof_t;                                                  -- assume bad
  for i in reverse 1..identifiers_top-1 loop                    -- from top
      if i /= eof_t then
         if identifiers( i ).name = name and not                -- exists and
            identifiers( i ).deleted then                       -- not deleted?
            id := i;                                            -- return id
            exit;                                               -- we're done
         end if;
      end if;
  end loop;
end findIdent;

procedure init_env_ident( s : string ) is
-- Declare an operating system environment variable. 's' is the
-- variable string returned by get_env ("var=value" format).
  eqpos : natural := 0; -- position of the '=' in s
begin
  if identifiers_top = identifier'last then                     -- no room?
     raise symbol_table_overflow;                               -- raise error
  else                                                          -- otherwise
     for i in 1..s'length loop                                  -- find '='
         if s(i) = '=' then                                     -- found?
            eqpos := i;                                         -- remember
            exit;                                               -- and done
         end if;
     end loop;
     if identifiers( identifiers_top ).avalue /= null then
        free( identifiers( identifiers_top ).avalue );
     end if;
     identifiers( identifiers_top ) := declaration'(            -- define
       name     => To_Unbounded_String( s(s'first..eqpos-1) ),  -- identifier
       kind     => string_t,
       value    => To_Unbounded_String( s(eqpos+1..s'last ) ),
       class    => varClass,
       import   => true,                                        -- must import
       method   => shell,
       mapping  => none,
       export   => false,
       volatile => false,
       limit    => false,
       list     => false,
       resource => false,
       field_of => eof_t,
       inspect  => false,
       deleted  => false,
       wasReferenced => false,
       procCB => null,
       funcCB => null,
       genKind => eof_t,
       firstBound => 1,
       lastBound => 0,
       avalue => null
     );
     identifiers_top := identifiers_top + 1;                    -- push stack
  end if;
end init_env_ident;

procedure declareIdent( id : out identifier; name : unbounded_string;
  kind : identifier; class : anIdentifierClass := varClass ) is
-- Declare an identifier in the symbol table, specifying name, kind.
-- and (optionally) symbol class.  The id is returned.
begin
  if identifiers_top = identifier'last then                     -- no room?
     raise symbol_table_overflow;                               -- raise error
  else                                                          -- otherwise
     id := identifiers_top;                                     -- return id
     identifiers_top := identifiers_top+1;                      -- push stack
     if identifiers( id ).avalue /= null then
        free( identifiers( id ).avalue );
     end if;
     identifiers( id ) := declaration'(                         -- define
       name     => name,                                        -- identifier
       kind     => kind,
       value    => Null_Unbounded_String,
       class    => class,
       import   => false,
       method   => none,
       mapping  => none,
       export   => false,
       volatile => false,
       limit    => false,
       list     => false,
       resource => false,
       field_of => eof_t,
       inspect  => false,
       deleted  => false,
       wasReferenced => false,
       procCB => null,
       funcCB => null,
       genKind => eof_t,
       firstBound => 1,
       lastBound => 0,
       avalue => null
     );
  end if;
end declareIdent;

procedure declareIdent( id : out identifier; name : string;
  kind : identifier; class : anIdentifierClass := varClass ) is
-- Alternate version: use fixed string type for name
begin
  declareIdent( id, to_unbounded_string( name ), kind, class );
end declareIdent;

procedure declareStandardConstant( id : out identifier;
   name : string; kind : identifier; value : string ) is
-- Declare a standard constant in the symbol table.  The id is not
-- returned since we don't change with constants once they are set.
begin
  if identifiers_top = identifier'last then                     -- no room?
     raise symbol_table_overflow;                               -- raise error
  else                                                          -- otherwise
     declare
       sc : declaration renames identifiers( identifiers_top );
     begin
       if sc.avalue /= null then
          free( sc.avalue );
       end if;
       sc.name  := to_unbounded_string( name );                 -- define
       sc.kind  := kind;                                        -- identifier
       sc.value := to_unbounded_string( value );
       sc.class := constClass;
       sc.field_of := eof_t;
       -- since this is only called at startup, the default
       -- values for the other fields should be OK
     end;
     id := identifiers_top;
     identifiers_top := identifiers_top+1;                      -- push stack
  end if;
end declareStandardConstant;

procedure declareStandardConstant( name : string; kind : identifier;
  value : string ) is
-- Alternative version: return the symbol table id
  discard_id : identifier;
begin
   declareStandardConstant( discard_id, name, kind, value );    -- declare it
end declareStandardConstant;

procedure updateFormalParameter( id : identifier; kind : identifier;
proc_id : identifier; parameterNumber : integer ) is
-- Update a formal parameter (ie. proc.param).  The id is not
-- returned since we don't change the formal parameters once they are set.
begin
    if parameterNumber = 0 then -- function result? no name suffix
       identifiers(id).name     := identifiers( id ).name;
    else
       identifiers(id).name     := identifiers( proc_id ).name & "." & identifiers( id ).name;
    end if;
    identifiers(id).value    := to_unbounded_string( parameterNumber'img );
    identifiers(id).class    := constClass;
    identifiers(id).kind     := kind;
    identifiers(id).import   := false;
    identifiers(id).export   := false;
    identifiers(id).volatile := false;
    identifiers(id).limit    := false;
    identifiers(id).list     := false;
    identifiers(id).field_of := proc_id;
    identifiers(id).inspect  := false;
    identifiers(id).deleted  := false;
end updateFormalParameter;

procedure declareActualParameter( id : out identifier;
proc_id : identifier; parameterNumber : integer;
value : unbounded_string ) is
-- parameterNumber : integer );
-- Declare an actual parameter (ie. param for proc.param).
  paramName : unbounded_string;
begin
  id := eof_t;
  for i in reverse reserved_top..identifiers_top-1 loop
      if identifiers( i ).field_of = proc_id then
         if integer'value( to_string( identifiers( i ).value )) = parameterNumber then
            paramName := identifiers( i ).name;
            paramName := delete( paramName, 1, index( paramName, "." ));
            if identifiers_top = identifier'last then           -- no room?
               raise symbol_table_overflow;                     -- raise error
            else                                                -- otherwise
               id := identifiers_top;                           -- return id
               identifiers_top := identifiers_top+1;            -- push stack
               if identifiers( id ).avalue /= null then
                  free( identifiers( id ).avalue );
               end if;
               identifiers( id ) := declaration'(               -- define
                 name     => paramName,                         -- identifier
                 kind     => identifiers( i ).kind,
                 value    => value,
                 class    => constClass,
                 import   => false,
                 method   => none,
                 mapping  => none,
                 export   => false,
                 volatile => false,
                 limit    => false,
                 list     => false,
                 resource => false,
                 field_of => eof_t,
                 inspect  => false,
                 deleted  => false,
                 wasReferenced => false,
                 procCB => null,
                 funcCB => null,
                 genKind => eof_t,
                 firstBound => 1,
                 lastBound => 0,
                 avalue => null
               );
            end if;
         end if;
      end if;
  end loop;
end declareActualParameter;

procedure declareReturnResult( id : out identifier; func_id : identifier ) is
-- Declare space for a return result for a user-defined function.  This is
-- effectively param 0 except that the value isn't zero...it's the return
-- result.
  paramName : unbounded_string;
begin
  paramName := "return result for " & identifiers( func_id ).name;
  if identifiers_top = identifier'last then           -- no room?
     raise symbol_table_overflow;                     -- raise error
  else                                                -- otherwise
     id := identifiers_top;                           -- return id
     identifiers_top := identifiers_top+1;            -- push stack
     if identifiers( id ).avalue /= null then
        free( identifiers( id ).avalue );
     end if;
     identifiers( id ) := declaration'(               -- define
       name     => paramName,                         -- identifier
       kind     => identifiers( func_id ).kind,
       value    => null_unbounded_string,
       class    => constClass,
       import   => false,
       method   => none,
       mapping  => none,
       export   => false,
       volatile => false,
       limit    => false,
       list     => false,
       resource => false,
       field_of => eof_t,
       inspect  => false,
       deleted  => false,
       wasReferenced => false,
       procCB => null,
       funcCB => null,
       genKind => eof_t,
       firstBound => 1,
       lastBound => 0,
       avalue => null
     );
  end if;
end declareReturnResult;

procedure findException( name : unbounded_string; id : out identifier ) is
-- search for a pre-existing exception with the same name
-- while Ada allows two exceptions with the same name
-- to overshadow each other, differentiating each other
-- using dot notation, it's a hacky solution.  SparForte
-- simply doesn't allow it.
begin
  id := eof_t;                                                  -- assume bad
  for i in reverse 1..identifiers_top-1 loop                    -- from top
      if i /= eof_t then
         if identifiers( i ).name = name and                    -- exists and
            identifiers( i ).kind = exception_t and not         -- and exception
            identifiers( i ).deleted then                       -- not deleted?
            id := i;                                            -- return id
            exit;                                               -- we're done
         end if;
      end if;
  end loop;
end findException;

procedure declareException( id : out identifier; name : unbounded_string;
   default_message : unbounded_string; exception_status_code : anExceptionStatusCode ) is
-- Declare an exception.  Check for the existence first with findException.
begin
  if identifiers_top = identifier'last then                     -- no room?
     raise symbol_table_overflow;                               -- raise error
  else                                                          -- otherwise
     id := eof_t;                                               -- assume bad
     id := identifiers_top;                                  -- return id
     identifiers_top := identifiers_top+1;                   -- push stack
     if identifiers( id ).avalue /= null then
        free( identifiers( id ).avalue );
     end if;
     identifiers( id ) := declaration'(                      -- define
       name     => name,                                     -- identifier
       kind     => exception_t,
       value    => character'val( exception_status_code ) & default_message,
       class    => exceptionClass,
       import   => false,
       method   => none,
       mapping  => none,
       export   => false,
       volatile => false,
       limit    => false,
       list     => false,
       resource => false,
       field_of => eof_t,
       inspect  => false,
       deleted  => false,
       wasReferenced => false,
       procCB   => null,
       funcCB   => null,
       genKind  => eof_t,
       firstBound => 1,
       lastBound => 0,
       avalue   => null
     );
  end if;
end declareException;


-- Type Conversions


function to_numeric( s : unbounded_string ) return long_float is
-- Convert an unbounded string to a long float (BUSH's numeric representation)
begin
  if Element( s, 1 ) = '-' then                               -- leading -?
     return long_float'value( to_string( s ) );               -- OK for 'value
  elsif Element( s, 1 ) = ' ' then                            -- leading space?
     return long_float'value( to_string( s ) );               -- OK for 'value
  else                                                        -- otherwise add
     return long_float'value( " " & to_string( s ) );         -- space & 'value
  end if;
end to_numeric;

function to_numeric( id : identifier ) return long_float is
-- Look up an identifier's value and return it as a long float
-- (BUSH's numeric representation).
begin
   return to_numeric( identifiers( id ).value );
end to_numeric;

function to_unbounded_string( f : long_float ) return unbounded_string is
-- Convert a long_float (BUSH's numeric representation) to an
-- unbounded string.  If the value is representable as an integer,
-- it is returned without a decimal part.
  f_trunc : long_float := long_float'truncation( f );
begin

  -- integer value?  Try to return without a decimal part
  -- provided it will fit into a long float's mantissa.

   if f - f_trunc = 0.0 then
      -- There's no guarantee that a long_long_integer will fit into
      -- a long_float's mantissa, so we'll use a decimal type.
      if f <= long_float( integerOutputType'last ) and
         f >= long_float( integerOutputType'first ) then
         return to_unbounded_string( long_long_integer( f )'img );
      end if;
   end if;

  -- Otherwise, return a long float using 'image

   return to_unbounded_string( long_float'image( f ) );
end to_unbounded_string;

function To_Bush_Boolean( AdaBoolean : boolean ) return unbounded_string is
  -- convert an Ada boolean into a BUSH boolean (a string containing
  -- the position, no leading blank).
begin
  return To_Unbounded_String( integer'image( boolean'pos( AdaBoolean ) )(2)&"" );
end To_Bush_Boolean;

-----------------------------------------------------------------------------
-- IS KEYWORD
--
-- TRUE if the identifier is a keyword.
-----------------------------------------------------------------------------

function is_keyword( id : identifier ) return boolean is
-- True if an AdaScript keyword.  Keywords are defined in the
-- first part of the indentifier table.
begin
  return id < reserved_top;
end is_keyword;

-----------------------------------------------------------------------------
-- TO HIGH ASCII
--
-- Set the high bit (bit 8) on a low ASCII (7 bit) character.  Also, same for
-- an identifier to a high ASCII character.
-----------------------------------------------------------------------------

function toHighASCII( ch : character ) return character is
   pragma suppress( RANGE_CHECK );
   -- GCC 3.3.3 (Red Hat Fedora Core 2) falsely reports a out-of-range
   -- exception.  We'll do the range checking manually as a work around...
begin
   if ch > ASCII.DEL then
      put_line( standard_error, Gnat.Source_Info.Source_Location & ": Internal error: cannot set high bit on character" & character'pos( ch )'img );
      raise PROGRAM_ERROR;
   end if;
   return character'val( 128+character'pos( ch ) );
end toHighASCII;

function toHighASCII( id : identifier ) return character is
   pragma suppress( RANGE_CHECK );
   -- GCC 3.3.3 (Red Hat Fedora Core 2) falsely reports a out-of-range
   -- exception.  We'll do the range checking manually as a work around...
begin
   if id > 127 then
      put_line( standard_error, Gnat.Source_Info.Source_Location & ": Internal error: cannot set high bit on identifier number" & id'img );
      raise PROGRAM_ERROR;
   end if;
   return character'val( 128+integer(id) );
end toHighASCII;

-----------------------------------------------------------------------------
-- TO LOW ASCII
--
-- Clear the high bit (bit 8) on a high ASCII (7 bit) character.  Also, same
-- for an identifier to a low ASCII character.
-----------------------------------------------------------------------------

function toLowASCII( ch : character ) return character is
   pragma suppress( RANGE_CHECK );
   -- GCC 3.3.3 (Red Hat Fedora Core 2) falsely reports a out-of-range
   -- exception.  We'll do the range checking manually as a work around...
begin
   if ch <= ASCII.DEL then
      put_line( standard_error, Gnat.Source_Info.Source_Location & ": Internal error: cannot clear high bit on character" & character'pos( ch )'img );
      raise PROGRAM_ERROR;
   end if;
   return character'val( character'pos( ch )-128 );
end toLowASCII;

function toLowASCII( id : identifier ) return character is
   pragma suppress( RANGE_CHECK );
   -- GCC 3.3.3 (Red Hat Fedora Core 2) falsely reports a out-of-range
   -- exception.  We'll do the range checking manually as a work around...
begin
   if id <= 128 then
      put_line( standard_error, Gnat.Source_Info.Source_Location & ": Internal error: cannot clear high bit on identifier number" & id'img );
      raise PROGRAM_ERROR;
   end if;
   return character'val( integer(id)-128 );
end toLowASCII;

function ">"( left, right : aShellWord ) return boolean is
begin
  return left.word > right.word;
end ">";

function ">="( left, right : aSourceFile ) return boolean is
begin
  return left.name >= right.name;
end ">=";

function equal( left, right : aSourceFile ) return boolean is
begin
  return left.pos = right.pos;
end equal;

procedure findField( recordVar : identifier; fieldNumber: natural;
  fieldVar : out identifier ) is
-- Find fieldNumber'th field of a record varable.  This involves looking up the
-- record type, searching for the type's fields, checking the type field's
--  numbers, constructiong the name of the record's field, and finding it in
-- the symbol table.  This is not very fast but it works.
  recordType : identifier;
begin
  recordType := identifiers( recordVar ).kind;
  fieldVar := eof_t;
  for candidateType in reverse reserved_top..identifiers_top-1 loop
      if identifiers( candidateType ).field_of = recordType then
         if integer'value( to_string( identifiers( candidateType ).value )) = fieldNumber then
            declare
               fieldName : unbounded_string;
               field_t   : identifier;
               dotPos    : natural;
            begin
               fieldName := identifiers( candidateType ).name;
               dotPos := length( fieldName );
               while dotPos > 1 loop
                     exit when element( fieldName, dotPos ) = '.';
                     dotPos := dotPos - 1;
               end loop;
               fieldName := delete( fieldName, 1, dotPos );
               fieldName := identifiers( recordVar ).name & "." & fieldName;
               findIdent( fieldName, field_t );
               fieldVar := field_t;
            end;
         end if;
      end if;
  end loop;
end findField;

-- CHECK AND INITIALIZE LOCAL MEMCACHE CLUSTER

procedure checkAndInitializeLocalMemcacheCluster is
begin
  if not localMemcacheClusterInitialized then
     localMemcacheClusterInitialized := true;
     RegisterServer( localMemcacheCluster, to_unbounded_string( "localhost" ), 11211 );
     SetClusterName( localMemcacheCluster, to_unbounded_string( "Local Memcache" ) );
     SetClusterType( localMemcacheCluster, normal );
  end if;
end checkAndInitializeLocalMemcacheCluster;

-- CHECK AND INITIALIZE DISTRIBLED MEMCACHE CLUSTER

procedure checkAndInitializeDistributedMemcacheCluster is
begin
  if not localMemcacheClusterInitialized then
     distributedMemcacheClusterInitialized := true;
     SetClusterName( distributedMemcacheCluster, to_unbounded_string( "Distributed Memcache" ) );
     SetClusterType( distributedMemcacheCluster, normal );
  end if;
end checkAndInitializeDistributedMemcacheCluster;

--  GET IDENTIFIER CLASS NAME
--
-- Return a string description of the class

function getIdentifierClassImage( c : anIdentifierClass ) return string is
begin
  case c is
  when constClass       => return "constant";
  when subClass         => return "subtype";
  when typeClass        => return "type";
  when funcClass        => return "built-in function";
  when userFuncClass    => return "user-defined function";
  when procClass        => return "built-in procedure";
  when userProcClass    => return "user-defined procedure";
  when taskClass        => return "task";
  when mainProgramClass => return "main program";
  when exceptionClass   => return "exception";
  when varClass         => return "variable";
  when otherClass       => return "other class";
  end case;
end getIdentifierClassImage;


--  PUT TEMPLATE HEADER
--
-- Output the template header.  Mark it as sent so it isn't sent
-- twice.  This will likely be replaced in the future.
--
-- A bad status results in HTTP 500.  A bad content type results in text.
-- In both cases, a message is written to standard error.
-----------------------------------------------------------------------------

procedure putTemplateHeader( header : in out templateHeaders ) is
  s : unbounded_string;
begin

  if header.templateHeaderSent then
     return;
  end if;
  header.templateHeaderSent := true;

  -- CGI programs cannot directly return HTTP 404.  Instead, it must use
  -- a Status: header

  s := to_unbounded_string( "Status: " & header.status'img & " " );
  case header.status is
  when 100 => s := s & "Continue";
  when 200 => s := s & "OK";
  when 201 => s := s & "Created";
  when 202 => s := s & "Accepted";
  when 203 => s := s & "Non-Authoritative";
  when 204 => s := s & "No Content";
  when 205 => s := s & "Reset Content";
  when 206 => s := s & "Partial Content";
  when 300 => s := s & "Multiple Choices";
  when 301 => s := s & "Moved Permanently";
  when 302 => s := s & "Found";
  when 303 => s := s & "See Other";
  when 304 => s := s & "Not Modified";
  when 305 => s := s & "Use Proxy";
  when 307 => s := s & "Temporary Redirect";
  when 400 => s := s & "Bad Request";
  when 401 => s := s & "Unauthorized";
  when 403 => s := s & "Forbidden";
  when 404 => s := s & "Not Found";
  when 405 => s := s & "Method Not Allowed";
  when 406 => s := s & "Not Acceptable";
  when 407 => s := s & "Proxy Authentication Required";
  when 408 => s := s & "Request Timeout";
  when 409 => s := s & "Conflict";
  when 410 => s := s & "Gone";
  when 411 => s := s & "Length Required";
  when 412 => s := s & "Precondition Failed";
  when 413 => s := s & "Request Entity Too Large";
  when 414 => s := s & "Request-URI Too Long";
  when 415 => s := s & "Unsupported Media Type";
  when 416 => s := s & "Requested Range Not Satisfiable";
  when 417 => s := s & "Expectation Failed";
  when 500 => s := s & "Internal Server Error";
  when 501 => s := s & "Not Implemented";
  when 502 => s := s & "Bad Gateway";
  when 503 => s := s & "Service Unavailable";
  when 504 => s := s & "Gateway Timeout";
  when 505 => s := s & "HTTP Version Not Supported";
  when others => -- includes 500
     put_line( standard_error, "internal error: unknown http status" );
     s := to_unbounded_string( "HTTP/1.1 500 Internal Server Error" );
  end case;
  s := s & ASCII.CR & ASCII.LF;

--  put( s & ASCII.CR & ASCII.LF );

  s := s & to_unbounded_string( "Content-type: " );
  case header.templateType is
  when htmlTemplate => s := s & "text/html";
  when cssTemplate  => s := s & "text/css";
  when jsTemplate   => s := s & "application/x-javascript";
  when jsonTemplate => s := s & "application/json";
  when textTemplate => s := s & "text/plain";
  when xmlTemplate  => s := s & "text/xml";
  when wmlTemplate  => s := s & "text/vnd.wap.wml";
  when others => -- includes textTemplate
     put_line( standard_error, "internal error: unknown template type" );
     s := to_unbounded_string( "Content-type: text/plain" );
  end case;
  s := s & ASCII.CR & ASCII.LF;
  -- put( s & ASCII.CR & ASCII.LF );

  -- Other fields (to be filled in later)

  if length( header.contentLength ) > 0 then
     s := s & "Content-length: " & header.contentLength & ASCII.CR & ASCII.LF;
  end if;

  if length( header.expires ) > 0 then
     s := s & "Expires: " & header.expires & ASCII.CR & ASCII.LF;
  end if;

  if length( header.location ) > 0 then
     s := s & "Location: " & header.location & ASCII.CR & ASCII.LF;
  end if;

  if length( header.pragmaString ) > 0 then
     s := s & "Pragma: " & header.pragmaString & ASCII.CR & ASCII.LF;
  end if;

  if length( header.cookieString ) > 0 then
     s := s & "Set-Cookie: " & header.pragmaString & ASCII.CR & ASCII.LF;
  end if;

  -- The HTTP header ends with a blank line

  put( s & ASCII.CR & ASCII.LF );

end putTemplateHeader;

end world;
