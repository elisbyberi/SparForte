------------------------------------------------------------------------------
-- BUSH_OS Package Parser                                                   --
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

with text_io;use text_io;
with gnat.lock_files,
    world,
    scanner,
    string_util,
    parser_aux,
    parser,
    parser_params,
    bush_os;
use gnat.lock_files,
    world,
    scanner,
    string_util,
    parser_aux,
    parser,
    parser_params,
    bush_os;

package body parser_os is

procedure ParseOSSystem is
  -- Syntax: os.system( string );
  expr_val   : unbounded_string;
  expr_type  : identifier;
begin
  expect( os_system_t );
  ParseSingleStringParameter( expr_val, expr_type, string_t );
  if isExecutingCommand then
     begin
        last_status:= aStatusCode( linux_system( to_string( expr_val ) & ascii.nul ) );
     exception when others =>
       err( "exception raised" );
     end;
  end if;
end ParseOSSystem;

procedure ParseOSStatus( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: os.status
begin
  kind := integer_t;
  expect( os_status_t );
  result := to_unbounded_string( aStatusCode'image( last_status ) );
end ParseOSStatus;

procedure StartupSparOS is
begin
  declareProcedure( os_system_t, "os.system", ParseOSSystem'access );
  declareFunction( os_status_t, "os.status", ParseOSStatus'access );
end StartupSparOS;

procedure ShutdownSparOS is
begin
  null;
end ShutdownSparOS;

end parser_os;
