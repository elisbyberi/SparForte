l1 : doubly_linked_lists.list;
c1 : doubly_linked_lists.cursor;
i  : integer := 1;
doubly_linked_lists.new_list( l1, integer );
doubly_linked_lists.append( l1, 1234 );
doubly_linked_lists.append( l1, 2345 );
doubly_linked_lists.new_cursor( c1, integer );
doubly_linked_lists.last( l1, c1 );
doubly_linked_lists.replace_element( i, c1, 3456 ); -- should be list

