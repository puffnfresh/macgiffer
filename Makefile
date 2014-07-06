all: macgiffer

macgiffer: main.m
	${CC} -framework Cocoa -o macgiffer main.m
