CFLAGS := -xobjective-c $(CFLAGS)
LDFLAGS := -framework Foundation $(LDFLAGS)

.PHONY: all
all: aquaskk-reload-config

.PHONY: clean
clean:
	$(RM) aquaskk-reload-config *.o

.PHONY: install
install: aquaskk-reload-config
	install -Dm755 $< $(PREFIX)/bin/$<

%.o: %.m
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

aquaskk-reload-config: aquaskk-reload-config.o
