------------------------------------------------------------------------------
-- Command_Line Package Parser                                              --
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

with ada.strings.unbounded, world;
use  ada.strings.unbounded, world;

package parser_cmd is

------------------------------------------------------------------------------
-- Command_Line package identifiers
------------------------------------------------------------------------------

cmd_argument_t    : identifier;
cmd_argcount_t    : identifier;
cmd_commandname_t : identifier;
cmd_setexit_t     : identifier;
cmd_envcnt_t      : identifier;
cmd_envval_t      : identifier;

------------------------------------------------------------------------------
-- HOUSEKEEPING
------------------------------------------------------------------------------

procedure StartupCommandLine;
procedure ShutdownCommandLine;

------------------------------------------------------------------------------
-- PARSE THE COMMAND LINE PACKAGE
------------------------------------------------------------------------------

-- procedure ParseArgument( result : out unbounded_string; kind : out identifier );
-- procedure ParseArgument_Count( result : out unbounded_string; kind : out identifier );
-- procedure ParseCommand_Name( result : out unbounded_string; kind : out identifier );
-- procedure ParseSetExitStatus;
-- procedure ParseEnvironment_Count( result : out unbounded_string; kind : out identifier );
-- procedure ParseEnvironment_Value( result : out unbounded_string; kind : out identifier );

end parser_cmd;
