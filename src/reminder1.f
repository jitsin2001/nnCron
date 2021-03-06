\ REQUIRE CLASS: ~nn/class/class.f

CREATE <RMNDR-FILENAME> C" reminder.tab" ", 0 C, 
: RMNDR-FILENAME <RMNDR-FILENAME> COUNT ;

VARIABLE RMNDR-DEL-LIST
VARIABLE RMNDR-LINE

: ?RMND= <> IF RDROP 1 PARSE 2DROP EXIT THEN ;
: RMNDR-PRE { \ need-delete -- }
    SOURCE NIP
    IF 
      FALSE TO need-delete
      NextWord DROP C@  [CHAR] o = TO need-delete
      get-number Min@     ?RMND=
      get-number Hour@    ?RMND=
      get-number Day@     ?RMND=
      get-number Mon@     ?RMND=

      SOURCE DUP 128 + ALLOCATE IF DROP 2DROP EXIT THEN >R
      S" tm.exe Reminder " R@ ZPLACE R@ +ZPLACE
      0 R@ ASCIIZ> StartApp DROP
      need-delete IF RMNDR-LINE @ RMNDR-DEL-LIST AddNode THEN
      1 PARSE 2DROP
      R> FREE DROP
    THEN
    RMNDR-LINE 1+!
;

0 VALUE RMNDR-FILE
0 VALUE RMNDR-FLAG
0 VALUE RMNDR-NUM

: (RMNDR-TEST) NodeValue RMNDR-NUM = IF TRUE TO RMNDR-FLAG THEN ;
: RMNDR-DEL-PRESENT? ( n -- ?)
    TO RMNDR-NUM
    FALSE TO RMNDR-FLAG
    ['] (RMNDR-TEST) RMNDR-DEL-LIST DoList
    RMNDR-FLAG
;

: RMNDR-UPDATE
    RMNDR-FILENAME MAKE-BAK THROW
    RMNDR-FILENAME MAKE-BAK-PATH R/O OPEN-FILE THROW >R
    RMNDR-FILENAME R/W CREATE-FILE-SHARED THROW TO RMNDR-FILE
    RMNDR-LINE 0!
    BEGIN PAD 512 R@ READ-LINE THROW WHILE
        ?DUP
        IF
            RMNDR-LINE @ RMNDR-DEL-PRESENT? 0=
            IF PAD SWAP RMNDR-FILE WRITE-LINE THROW ELSE DROP THEN
        THEN
        RMNDR-LINE 1+!
    REPEAT
    DROP
    RMNDR-FILE CLOSE-FILE DROP
    R> CLOSE-FILE DROP
;

: TEST-REMINDERS
    RMNDR-FILENAME FILE-EMPTY 0=
    IF
        RMNDR-DEL-LIST 0!
        RMNDR-LINE 0!
        ['] <PRE> BEHAVIOR >R
        ['] RMNDR-PRE TO <PRE>
        RMNDR-FILENAME ['] INCLUDED CATCH
        IF S" Reminder error. Line %CURSTR @%" CRON-LOG 2DROP THEN
        R> TO <PRE>
        RMNDR-DEL-LIST @ IF RMNDR-UPDATE THEN
    THEN
;