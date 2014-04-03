l1 : doubly_linked_lists.list;
l2 : doubly_linked_lists.list;
c1 : doubly_linked_lists.cursor;
doubly_linked_lists.new_list( l1, string );
doubly_linked_lists.append( l1, "apple" ) @ ( l1, "banana" ) @ ( l1, "cherry" );
doubly_linked_lists.new_list( l2, string );
doubly_linked_lists.append( l2, "donut" ) @ ( l2, "eclair" ) @ (l2, "gelato" );
doubly_linked_lists.new_cursor( c1, string );
doubly_linked_lists.first( l1, c1 );
doubly_linked_lists.next( c1 );
doubly_linked_lists.splice( c1, c1, l2 );  -- should be l1

