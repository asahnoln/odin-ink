package ink_test

import "core:log"
import "core:testing"
import "src:ink"

@(test)
example :: proc(t: ^testing.T) {
	json_text := #load("testdata/example.json")
	story, err := ink.story_make(json_text)
	defer delete(story.root)
	if !testing.expect_value(t, err, nil) {
		return
	}

	testing.expect_value(t, story.can_continue, true)

	l := ink.story_continue(&story)
	testing.expect_value(t, l, "Once upon a time...\n")

	testing.expect_value(t, story.can_continue, false)
	// testing.expect_value(t, len(s.current_choices), 2)
	// testing.expect_value(t, s.current_choices[0].text, "There were two choices.")
	//
	// ink.choose_choice_index(0)
	//
	// testing.expect_value(t, story.can_continue, true)
	//
	// l = ink.story_continue(&s)
	// testing.expect_value(t, s, "There were two choices.")
	//
	// testing.expect_value(t, story.can_continue, true)
	//
	// l = ink.story_continue(&s)
	// testing.expect_value(t, s, "They lived happily ever after.")
	//
	// testing.expect_value(t, story.can_continue, false)
	// testing.expect_value(t, len(s.current_choices), 0)
}

// story_make :: proc(t: ^testing.T) {
// 	json_text := #load("testdata/example.json")
// 	story, err := ink.story_make(json_text)
// 	if !testing.expect_value(t, err, nil) {
// 		return
// 	}
//
// 	testing.expect_value(t, story.data.ink_version, 21)
// }

// story_continue :: proc(t: ^testing.T) {
// 	story := ink.Story {
// 		root = {
// 			"First line of text.\n",
// 			"Second line of text.\n",
// 			"Second line of text.\n",
// 			// ink.Container { 	//
// 			// "Second line of text.\n",
// 			// },
// 		},
// 	}
//
// 	s := ink.story_continue(&story)
// 	testing.expect_value(t, s, "First line of text.\n")
//
// 	s = ink.story_continue(&story)
// 	testing.expect_value(t, s, "Second line of text.\n")
//
// 	s = ink.story_continue(&story)
// 	testing.expect_value(t, s, "Second line of text.\n")
// }

// choices :: proc(t: ^testing.T) {
// 	testing.expectf(t, 1 == 2, "work on choices")
// }
