package ink_test

import "core:testing"
import "src:ink"

@(test)
has_next_str :: proc(t: ^testing.T) {
	path := []int{0}

	ok := ink.has_next_str(ink.Container{"str"}, path)

	testing.expect_value(t, ok, true)
}

@(test)
has_next_str_after :: proc(t: ^testing.T) {
	path := []int{1, 0}

	ok := ink.has_next_str(
		ink.Container {
			"str",
			ink.Container { 	//
				ink.Container{},
			},
			"str2",
		},
		path,
	)

	testing.expect_value(t, ok, true)
}

@(test)
has_next_str_false :: proc(t: ^testing.T) {
	path := []int{1}

	ok := ink.has_next_str(
		ink.Container {
			"str", //
			ink.Container{},
			ink.Container{},
			ink.Container{},
		},
		path,
	)

	testing.expect_value(t, ok, false)
}
