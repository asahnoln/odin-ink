package ink_test

import "core:slice"
import "core:testing"
import "src:ink"

@(test)
collect_first_of_two :: proc(t: ^testing.T) {
	path := make([dynamic]int)
	defer delete(path)
	append(&path, 0)

	str := ink.collect(
		ink.Container { 	//
			"First line.",
			"\n",
			"Second line.",
			"\n",
		},
		&path,
	)
	defer delete(str)

	testing.expect_value(t, str, "First line.\n")

	{
		got, want := path[:], []int{2}
		testing.expectf(t, slice.equal(got, want), "got %v; want %v", got, want)
	}
}

@(test)
collect_second_of_two :: proc(t: ^testing.T) {
	path := make([dynamic]int)
	defer delete(path)
	append(&path, 2)

	str := ink.collect(
		ink.Container { 	//
			"First line.",
			"\n",
			"Second line.",
			"\n",
		},
		&path,
	)
	defer delete(str)

	testing.expect_value(t, str, "Second line.\n")

	{
		got, want := path[:], []int{}
		testing.expectf(t, slice.equal(got, want), "got %v; want %v", got, want)
	}
}

@(test)
collect_first_deep :: proc(t: ^testing.T) {
	path := make([dynamic]int)
	defer delete(path)
	append(&path, 0)

	str := ink.collect(
		ink.Container {
			ink.Container { 	//
				"First deep line.",
				"\n",
				"Second deep line.",
				"\n",
			},
		},
		&path,
	)
	defer delete(str)

	testing.expect_value(t, str, "First deep line.\n")

	{
		got, want := path[:], []int{0, 2}
		testing.expectf(t, slice.equal(got, want), "got %v; want %v", got, want)
	}
}

@(test)
collect_second_deep :: proc(t: ^testing.T) {
	path := make([dynamic]int)
	defer delete(path)
	append(&path, 0)
	append(&path, 2)

	str := ink.collect(
		ink.Container {
			ink.Container { 	//
				"First deep line.",
				"\n",
				"Second deep line.",
				"\n",
			},
			"Line new.",
			"\n",
		},
		&path,
	)
	defer delete(str)

	testing.expect_value(t, str, "Second deep line.\n")

	{
		got, want := path[:], []int{1}
		testing.expectf(t, slice.equal(got, want), "got %v; want %v", got, want)
	}
}

@(test)
collect_split :: proc(t: ^testing.T) {
	path := make([dynamic]int)
	defer delete(path)
	append(&path, 0)

	str := ink.collect(
		ink.Container {
			ink.Container { 	//
				"Split ",
			},
			"line.",
			"\n",
		},
		&path,
	)
	defer delete(str)

	testing.expect_value(t, str, "Split line.\n")

	{
		got, want := path[:], []int{}
		testing.expectf(t, slice.equal(got, want), "got %v; want %v", got, want)
	}
}

@(test)
collect_split_with_empty_in_middle :: proc(t: ^testing.T) {
	path := make([dynamic]int)
	defer delete(path)
	append(&path, 0)

	str := ink.collect(
		ink.Container {
			"Split ",
			ink.Container { 	//
			},
			"line.",
			"\n",
		},
		&path,
	)
	defer delete(str)

	testing.expect_value(t, str, "Split line.\n")

	{
		got, want := path[:], []int{}
		testing.expectf(t, slice.equal(got, want), "got %v; want %v", got, want)
	}
}

@(test)
collect_split_starting_from_inside :: proc(t: ^testing.T) {
	path := make([dynamic]int)
	defer delete(path)
	append(&path, 1)
	append(&path, 0)

	str := ink.collect(
		ink.Container {
			"Split ",
			ink.Container { 	//
				"Another ",
			},
			"line.",
			"\n",
		},
		&path,
	)
	defer delete(str)

	testing.expect_value(t, str, "Another line.\n")

	{
		got, want := path[:], []int{}
		testing.expectf(t, slice.equal(got, want), "got %v; want %v", got, want)
	}
}
