------------------------------------------------------------------------------
-- Dynamic Hash Tables Package Parser                                       --
--                                                                          --
-- Part of SparForte                                                        --
------------------------------------------------------------------------------
--                                                                          --
--            Copyright (C) 2001-2013 Free Software Foundation              --
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
-- This is maintained at http://www.sparforte.com                           --
--                                                                          --
------------------------------------------------------------------------------

with text_io;use text_io;
with
    Gnat.Dynamic_HTables,
    user_io,
    world,
    scanner,
    scanner_res,
    string_util,
    parser,
    parser_aux,
    parser_params,
    bush_os;
use
    world,
    user_io,
    scanner,
    scanner_res,
    string_util,
    parser,
    parser_aux,
    parser_params,
    bush_os;

package body parser_dht is

------------------------------------------------------------------------------
-- Utility subprograms
------------------------------------------------------------------------------

procedure CheckTableIsInitialized( tableId : identifier ) is
begin
  if identifiers( tableId ).genKind = eof_t then
     err( "new_table has not been called to initialize the table" );
  end if;
end CheckTableIsInitialized;

procedure ParseSingleTableParameter( tableId : out identifier ) is
begin
  ParseSingleInOutParameter( tableId, dht_table_t );
  CheckTableIsInitialized( tableId );
end ParseSingleTableParameter;

procedure ParseFirstTableParameter( tableId : out identifier ) is
begin
  ParseFirstInOutParameter( tableId, dht_table_t );
  CheckTableIsInitialized( tableId );
end ParseFirstTableParameter;

procedure ParseNextTableParameter( tableId : out identifier ) is
begin
  ParseNextInOutParameter( tableId, dht_table_t );
  CheckTableIsInitialized( tableId );
end ParseNextTableParameter;

procedure ParseLastTableParameter( tableId : out identifier ) is
begin
  ParseLastInOutParameter( tableId, dht_table_t );
  CheckTableIsInitialized( tableId );
end ParseLastTableParameter;

------------------------------------------------------------------------------
-- Parser subprograms
------------------------------------------------------------------------------


procedure ParseDHTNewTable is
  -- Syntax: dynamic_hash_tables.new_table( t, ty );
  -- Ada:    N/A
  resId : resHandleId;
  ref   : reference;
  genKindId : identifier;
begin
  expect( dht_new_table_t );
  ParseFirstOutParameter( ref, dht_table_t );
  baseTypesOK( ref.kind, dht_table_t );
  expect( symbol_t, "," );
  ParseIdentifier( genKindId );
  if class_ok( genKindId, typeClass, subClass ) then
     if identifiers( genKindId ).list then
        err( "element type should be a scalar type" );
     elsif identifiers( getBaseType( genKindId ) ).kind = root_record_t then
        err( "element type should be a scalar type" );
     end if;
  end if;
  identifiers( ref.id ).genKind := genKindId;
  expect( symbol_t, ")" );
  if isExecutingCommand then
     identifiers( ref.id ).resource := true;
     declareResource( resId, dynamic_string_hash_table, blocks_top );
     AssignParameter( ref, to_unbounded_string( resId ) );
  end if;
end ParseDHTNewTable;

procedure ParseDHTReset is
  -- Syntax: dynamic_hash_tables.reset( t );
  -- Ada:    dynamic_hash_tables.reset( t );
  tableId  : identifier;
  theTable : resPtr;
begin
  expect( dht_reset_t );
  ParseSingleTableParameter( tableId );
  if isExecutingCommand then
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       Dynamic_String_Hash_Tables.Reset( theTable.dsht );
     exception when storage_error =>
       err( "storage error raised" );
     end;
  end if;
end ParseDHTReset;

procedure ParseDHTSet is
  -- Syntax: dynamic_hash_tables.set( t, s, e );
  -- Ada:    dynamic_hash_tables.set( t, s, e );
  tableId  : identifier;
  theTable : resPtr;
  keyExpr  : unbounded_string;
  keyType  : identifier;
  itemExpr : unbounded_string;
  itemType : identifier;
begin
  expect( dht_set_t );
  ParseFirstTableParameter( tableId );
  ParseNextStringParameter( keyExpr, keyType, uni_string_t ); -- TODO double gen
  ParseLastGenItemParameter( itemExpr, itemType, identifiers( tableId ).genKind );
  if isExecutingCommand then
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       Dynamic_String_Hash_Tables.Set(
          theTable.dsht,
          keyExpr,
          itemExpr );
     exception when storage_error =>
       err( "storage error raised" );
     end;
  end if;
end ParseDHTSet;

procedure ParseDHTGet( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: e := doubly_linked_list.get( t, s );
  -- Ada:    e := doubly_linked_list.get( t, s );
  tableId  : identifier;
  theTable : resPtr;
  keyExpr  : unbounded_string;
  keyType  : identifier;
begin
  expect( dht_get_t );
  ParseFirstTableParameter( tableId );
  kind := identifiers( tableId ).genKind;
  ParseLastStringParameter( keyExpr, keyType, uni_string_t );
  if isExecutingCommand then
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       result := Dynamic_String_Hash_Tables.Get( theTable.dsht, keyExpr );
     end;
  end if;
end ParseDHTGet;

procedure ParseDHTHasElement( result : out unbounded_string; kind : out identifier ) is
  -- Syntax: e := doubly_linked_list.has_element( t, s );
  -- Ada:    N/A
  tableId  : identifier;
  theTable : resPtr;
  keyExpr  : unbounded_string;
  keyType  : identifier;
begin
  kind := boolean_t;
  expect( dht_has_element_t );
  ParseFirstTableParameter( tableId );
  ParseLastStringParameter( keyExpr, keyType, uni_string_t );
  if isExecutingCommand then
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       result := to_bush_boolean( Dynamic_String_Hash_Tables.Get( theTable.dsht, keyExpr ) /= null_unbounded_string );
     end;
  end if;
end ParseDHTHasElement;

procedure ParseDHTRemove is
  -- Syntax: dynamic_hash_tables.remove( t, s );
  -- Ada:    dynamic_hash_tables.remove( t, s );
  tableId  : identifier;
  theTable : resPtr;
  keyExpr  : unbounded_string;
  keyType  : identifier;
begin
  expect( dht_remove_t );
  ParseFirstTableParameter( tableId );
  ParseLastStringParameter( keyExpr, keyType, uni_string_t );
  if isExecutingCommand then
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       Dynamic_String_Hash_Tables.Remove( theTable.dsht, keyExpr );
     exception when storage_error =>
       err( "storage error raised" );
     end;
  end if;
end ParseDHTRemove;

procedure ParseDHTGetFirst is
  -- Syntax: dynamic_hash_tables.get_first( t, e, eof );
  -- Ada:    e := dynamic_hash_tables.get_first( t );
  tableId  : identifier;
  theTable : resPtr;
  itemRef  : reference;
  eofRef   : reference;
begin
  expect( dht_get_first_t );
  if onlyAda95 then
     err( optional_bold( "pragma ada_95" ) & " doesn't allow get_first" );
  end if;
  ParseFirstTableParameter( tableId );
  ParseNextOutParameter( itemRef, identifiers( tableId ).genKind );
  baseTypesOK( itemRef.kind, identifiers( tableId ).genKind );
  ParseLastOutParameter( eofRef, boolean_t );
  baseTypesOK( eofRef.kind, boolean_t );
  if isExecutingCommand then
     declare
       s : unbounded_string;
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       s := Dynamic_String_Hash_Tables.Get_First( theTable.dsht );
       AssignParameter( itemRef, s );
       AssignParameter( eofRef, to_bush_boolean( s = null_unbounded_string ) );
     end;
  end if;
end ParseDHTGetFirst;

procedure ParseDHTGetNext is
  -- Syntax: dynamic_hash_tables.get_next( t, e, eof );
  -- Ada:    e := dynamic_hash_tables.get_next( t );
  tableId  : identifier;
  theTable : resPtr;
  itemRef  : reference;
  eofRef   : reference;
begin
  expect( dht_get_next_t );
  if onlyAda95 then
     err( optional_bold( "pragma ada_95" ) & " doesn't allow get_next" );
  end if;
  ParseFirstTableParameter( tableId );
  ParseNextOutParameter( itemRef, identifiers( tableId ).genKind );
  baseTypesOK( itemRef.kind, identifiers( tableId ).genKind );
  ParseLastOutParameter( eofRef, boolean_t );
  baseTypesOK( eofRef.kind, boolean_t );
  if isExecutingCommand then
     declare
       s : unbounded_string;
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       s := Dynamic_String_Hash_Tables.Get_Next( theTable.dsht );
       AssignParameter( itemRef, s );
       AssignParameter( eofRef, to_bush_boolean( s = null_unbounded_string ) );
     end;
  end if;
end ParseDHTGetNext;

procedure ParseDHTAdd is
  -- Syntax: dynamic_hash_tables.add( t, s, e );
  -- Ada:    N/A
  tableId  : identifier;
  theTable : resPtr;
  keyExpr  : unbounded_string;
  keyType  : identifier;
  itemExpr : unbounded_string;
  itemType : identifier;
  oldItem  : unbounded_string;
begin
  expect( dht_add_t );
  if onlyAda95 then
     err( optional_bold( "pragma ada_95" ) & " doesn't allow add" );
  end if;
  ParseFirstTableParameter( tableId );
  ParseNextStringParameter( keyExpr, keyType, uni_string_t );
  ParseLastGenItemParameter( itemExpr, itemType, identifiers( tableId ).genKind );
  if isExecutingCommand then
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       oldItem := Dynamic_String_Hash_Tables.Get( theTable.dsht, keyExpr );
       if oldItem = null_unbounded_string then
          Dynamic_String_Hash_Tables.Set( theTable.dsht, keyExpr, itemExpr );
       end if;
     exception when storage_error =>
       err( "storage error raised" );
     end;
  end if;
end ParseDHTAdd;

procedure ParseDHTReplace is
  -- Syntax: dynamic_hash_tables.replace( t, s, e );
  -- Ada:    N/A
  tableId  : identifier;
  theTable : resPtr;
  keyExpr  : unbounded_string;
  keyType  : identifier;
  itemExpr : unbounded_string;
  itemType : identifier;
  oldItem  : unbounded_string;
begin
  expect( dht_replace_t );
  if onlyAda95 then
     err( optional_bold( "pragma ada_95" ) & " doesn't allow replace" );
  end if;
  ParseFirstTableParameter( tableId );
  ParseNextStringParameter( keyExpr, keyType, uni_string_t );
  ParseLastGenItemParameter( itemExpr, itemType, identifiers( tableId ).genKind );
  if isExecutingCommand then
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       oldItem := Dynamic_String_Hash_Tables.Get( theTable.dsht, keyExpr );
       if oldItem /= null_unbounded_string then
          Dynamic_String_Hash_Tables.Set( theTable.dsht, keyExpr, itemExpr );
       end if;
     exception when storage_error =>
       err( "storage error raised" );
     end;
  end if;
end ParseDHTReplace;

procedure ParseDHTAppend is
  -- Syntax: dynamic_hash_tables.append( t, s, e );
  -- Ada:    N/A
  tableId  : identifier;
  theTable : resPtr;
  keyExpr  : unbounded_string;
  keyType  : identifier;
  itemExpr : unbounded_string;
  itemType : identifier;
  oldItem  : unbounded_string;
begin
  expect( dht_append_t );
  if onlyAda95 then
     err( optional_bold( "pragma ada_95" ) & " doesn't allow append" );
  end if;
  ParseFirstTableParameter( tableId );
  if getUniType( identifiers( tableId ).genKind ) /= uni_string_t then
     err( "append requires a string item type" );
  end if;
  ParseNextStringParameter( keyExpr, keyType, uni_string_t );
  ParseLastGenItemParameter( itemExpr, itemType, identifiers( tableId ).genKind );
  if isExecutingCommand then
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       oldItem := Dynamic_String_Hash_Tables.Get( theTable.dsht, keyExpr );
       if oldItem /= null_unbounded_string then
          Dynamic_String_Hash_Tables.Set( theTable.dsht, keyExpr, oldItem & itemExpr );
       end if;
     exception when storage_error =>
       err( "storage error raised" );
     end;
  end if;
end ParseDHTAppend;

procedure ParseDHTPrepend is
  -- Syntax: dynamic_hash_tables.prepend( t, s, e );
  -- Ada:    N/A
  tableId  : identifier;
  theTable : resPtr;
  keyExpr  : unbounded_string;
  keyType  : identifier;
  itemExpr : unbounded_string;
  itemType : identifier;
  oldItem  : unbounded_string;
begin
  expect( dht_prepend_t );
  if onlyAda95 then
     err( optional_bold( "pragma ada_95" ) & " doesn't allow prepend" );
  end if;
  ParseFirstTableParameter( tableId );
  if getUniType( identifiers( tableId ).genKind ) /= uni_string_t then
     err( "prepend requires a string item type" );
  end if;
  ParseNextStringParameter( keyExpr, keyType, uni_string_t );
  ParseLastGenItemParameter( itemExpr, itemType, identifiers( tableId ).genKind );
  if isExecutingCommand then
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       oldItem := Dynamic_String_Hash_Tables.Get( theTable.dsht, keyExpr );
       if oldItem /= null_unbounded_string then
          Dynamic_String_Hash_Tables.Set( theTable.dsht, keyExpr, itemExpr & oldItem );
       end if;
     exception when storage_error =>
       err( "storage error raised" );
     end;
  end if;
end ParseDHTPrepend;

procedure ParseDHTIncrement is
  -- Syntax: dynamic_hash_tables.increment( t, s [,n] );
  -- Ada:    N/A
  tableId  : identifier;
  theTable : resPtr;
  keyExpr  : unbounded_string;
  keyType  : identifier;
  amtExpr  : unbounded_string;
  amtType  : identifier;
  hasAmt   : boolean := false;
  oldItem  : unbounded_string;
  oldItemValue : long_float;
begin
  expect( dht_increment_t );
  if onlyAda95 then
     err( optional_bold( "pragma ada_95" ) & " doesn't allow increment" );
  end if;
  ParseFirstTableParameter( tableId );
  if getUniType( identifiers( tableId ).genKind ) /= uni_numeric_t then
     err( "increment requires a numeric item type" );
  end if;
  ParseNextStringParameter( keyExpr, keyType, uni_string_t );
  if token = symbol_t and identifiers( token ).value = "," then
     hasAmt := true;
     ParseLastNumericParameter( amtExpr, amtType, natural_t );
  elsif token = symbol_t and identifiers( token ).value = ")" then
     expect( symbol_t, ")" );
  else
     err( ", or ) expected" );
  end if;
  if isExecutingCommand then
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       oldItem := Dynamic_String_Hash_Tables.Get( theTable.dsht, keyExpr );
       if oldItem /= null_unbounded_string then
          oldItemValue := to_numeric( oldItem );
          if hasAmt then
             Dynamic_String_Hash_Tables.Set( theTable.dsht, keyExpr, to_unbounded_string( oldItemValue + long_float( natural( to_numeric( amtExpr ) ) ) ) );
          else
             Dynamic_String_Hash_Tables.Set( theTable.dsht, keyExpr, to_unbounded_string( oldItemValue + 1.0 ) );
          end if;
       end if;
     exception when storage_error =>
       err( "storage error raised" );
     when constraint_error =>
       err( "constraint error raised" );
     end;
  end if;
end ParseDHTIncrement;

procedure ParseDHTDecrement is
  -- Syntax: dynamic_hash_tables.decrement( t, s [,n] );
  -- Ada:    N/A
  tableId  : identifier;
  theTable : resPtr;
  keyExpr  : unbounded_string;
  keyType  : identifier;
  amtExpr  : unbounded_string;
  amtType  : identifier;
  hasAmt   : boolean := false;
  oldItem  : unbounded_string;
  oldItemValue : long_float;
begin
  expect( dht_decrement_t );
  if onlyAda95 then
     err( optional_bold( "pragma ada_95" ) & " doesn't allow decrement" );
  end if;
  ParseFirstTableParameter( tableId );
  if getUniType( identifiers( tableId ).genKind ) /= uni_numeric_t then
     err( "decrement requires a numeric item type" );
  end if;
  ParseNextStringParameter( keyExpr, keyType, uni_string_t );
  if token = symbol_t and identifiers( token ).value = "," then
     hasAmt := true;
     ParseLastNumericParameter( amtExpr, amtType, natural_t );
  elsif token = symbol_t and identifiers( token ).value = ")" then
     expect( symbol_t, ")" );
  else
     err( ", or ) expected" );
  end if;
  if isExecutingCommand then
     begin
       findResource( to_resource_id( identifiers( tableId ).value ), theTable );
       oldItem := Dynamic_String_Hash_Tables.Get( theTable.dsht, keyExpr );
       if oldItem /= null_unbounded_string then
          oldItemValue := to_numeric( oldItem );
          if hasAmt then
             Dynamic_String_Hash_Tables.Set( theTable.dsht, keyExpr, to_unbounded_string( oldItemValue - long_float( natural( to_numeric( amtExpr ) ) ) ) );
          else
             Dynamic_String_Hash_Tables.Set( theTable.dsht, keyExpr, to_unbounded_string( oldItemValue - 1.0 ) );
          end if;
       end if;
     exception when storage_error =>
       err( "storage error raised" );
     when constraint_error =>
       err( "constraint error raised" );
     end;
  end if;
end ParseDHTDecrement;


-----------------------------------------------------------------------------

procedure StartupDHT is
begin
  declareIdent( dht_table_t,   "dynamic_hash_tables.table", positive_t, typeClass );

  declareProcedure( dht_new_table_t, "dynamic_hash_tables.new_table", ParseDHTNewTable'access );
  declareProcedure( dht_set_t, "dynamic_hash_tables.set", ParseDHTSet'access );
  declareProcedure( dht_reset_t, "dynamic_hash_tables.reset", ParseDHTReset'access );
  declareFunction(  dht_get_t, "dynamic_hash_tables.get", ParseDHTGet'access );
  declareFunction(  dht_has_element_t, "dynamic_hash_tables.has_element", ParseDHTHasElement'access );
  declareProcedure( dht_remove_t, "dynamic_hash_tables.remove", ParseDHTRemove'access );
  declareProcedure(  dht_get_first_t, "dynamic_hash_tables.get_first", ParseDHTGetFirst'access );
  declareProcedure(  dht_get_next_t, "dynamic_hash_tables.get_next", ParseDHTGetNext'access );

  declareProcedure( dht_add_t, "dynamic_hash_tables.add", ParseDHTAdd'access );
  declareProcedure( dht_replace_t, "dynamic_hash_tables.replace", ParseDHTReplace'access );
  declareProcedure( dht_append_t, "dynamic_hash_tables.append", ParseDHTAppend'access );
  declareProcedure( dht_prepend_t, "dynamic_hash_tables.prepend", ParseDHTPrepend'access );
  declareProcedure( dht_increment_t, "dynamic_hash_tables.increment", ParseDHTIncrement'access );
  declareProcedure( dht_decrement_t, "dynamic_hash_tables.decrement", ParseDHTDecrement'access );

  --declareProcedure( dht_assemble_t, "dynamic_hash_tables.", 'access );
  --declareProcedure( dht_disassemble_t, "dynamic_hash_tables.", 'access );

  -- TODO: Add memcached functions
  -- TODO: enumerated items
  -- TODO: increment / decrement - amount, initial value

end StartupDHT;

procedure ShutdownDHT is
begin
  null;
end ShutdownDHT;

end parser_dht;

