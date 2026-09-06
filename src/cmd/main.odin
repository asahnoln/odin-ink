package main

import "core:fmt"
import "core:log"
import "core:os"
import "core:strconv"
import "src:ink"

main :: proc() {
	s, err := ink.story_make(#load("../../tests/ink/testdata/example.json"))
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
		n, err2 := os.read(os.stdin, buf[:])
		if err2 != nil {
			log.fatalf("read err: %v", err2)
		}

		i, _ := strconv.parse_int(cast(string)buf[:n], 10)

		ink.choose_choice_index(&s, i)
	}
}
