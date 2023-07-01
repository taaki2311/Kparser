CPPFLAGS += -Og -ggdb

TARGET = Kparser
LEX_C = lex.yy.c
YACC_C = y.tab.c
OBJECTS = lex.yy.o y.tab.o

$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^

$(LEX_C): Kparser.l
	$(LEX) $<

$(YACC_C): Kparser.y
	$(YACC) $< -d --debug --verbose

.PHONY: clean
clean:
	$(RM) $(TARGET) $(LEX_C) $(YACC_C) y.tab.h $(OBJECTS)