package main

import "core:fmt"
import "core:log"
import "core:os"
import "core:strconv"
import "src:ink"

main :: proc() {
	context.logger = log.create_console_logger()

	s, err := ink.story_make(#load("../../tests/ink/testdata/example2.json"))
	defer ink.story_destroy(&s)
	if err != nil {
		log.fatalf("story make err: %v", err)
	}

	for {
		for s.can_continue {
			fmt.print(ink.story_continue(&s))
		}

		if len(s.current_choices) == 0 {
			fmt.println("END")
			break
		}

		for c, i in s.current_choices {
			fmt.printfln("%d: %s", i, c.text)
		}

		buf: [2048]u8
		n, err := os.read(os.stdin, buf[:])
		if err != nil {
			log.fatalf("read err: %v", err)
		}

		i, _ := strconv.parse_int(cast(string)buf[:n], 10)

		err2 := ink.choose_choice_index(&s, i)
		if err != nil {
			log.fatalf("choose choice err: %v", err2)
		}
	}
}
