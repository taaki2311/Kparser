LEX_L := Kparser.l
YACC_Y := Kparser.y

TARGET := Kparser
LEX_C := lex.yy.c
YACC_C := y.tab.c
YACC_H := y.tab.h
YACC_OUTPUT := y.output
OBJECTS := lex.yy.o y.tab.o

CFLAGS += -ansi -pedantic-errors
CPPFLAGS += -Wall -Wextra -Wformat=2
YACCFLAGS := -d

ifdef $(debug)
CPPFLAGS += -DYACC_DEBUG
YACCFLAGS += --debug --verbose
endif

$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^

$(LEX_C): $(LEX_L)
	$(LEX) $<

$(YACC_C): $(YACC_Y)
	$(YACC) $< $(YACCFLAGS)

.PHONY: clean
clean:
	$(RM) $(TARGET) $(LEX_C) $(YACC_C) $(YACC_H) $(OBJECTS) $(YACC_OUTPUT)