package main

import "core:fmt"
import "core:log"
import "core:os"
import "core:strconv"
import "src:ink"

main :: proc() {
	s, err := ink.story_make(#load("../../tests/ink/testdata/example.json"))
	if err != nil {
		log.fatalf("story make err: %v", err)
	}

	// for s.can_continue {
	// 	fmt.println(ink.story_continue(&s))
	// }

	for {
		for l := ink.story_continue(&s); l != ""; {
			fmt.println(l)
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
