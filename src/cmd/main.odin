package main

import "core:fmt"
import "core:log"
import "src:ink"

main :: proc() {
	s, err := ink.story_make(#load("../../tests/ink/testdata/two_lines.json"))
	if err != nil {
		log.fatalf("story make err: %v", err)
	}

	for s.can_continue {
		fmt.println(ink.story_continue(&s))
	}
}
