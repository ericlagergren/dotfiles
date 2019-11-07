CC=g++
CFLAGS=-std=c++17 -O2 -Wall -Werror -Wextra -pedantic \
	   $(shell pkg-config --cflags libgit2)
LDFLAGS=$(shell pkg-config --libs libgit2)
TARGET=prompt
DEST=$(HOME)/.local/bin

.PHONY: all install clean

all: $(TARGET)

OBJECT=$(TARGET).o

$(OBJECT): $(TARGET).cpp
	$(CC) $(CFLAGS) -c -o $@ $<
$(TARGET): $(OBJECT)
	$(CC) $^ -o $@ $(LDFLAGS)

install: $(TARGET)
	mkdir -p $(DEST)
	cp $< $(DEST)/prompt

clean:
	$(RM) *~ *.o $(TARGET)
