package ink_test

import "core:testing"
import "src:ink"

@(test)
make_story_from_json :: proc(t: ^testing.T) {
	s, err := ink.story_make(#load("testdata/one_line_of_text.json"))
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer ink.story_destroy(&s)

	testing.expect_value(
		t,
		s.root.([]ink.Element)[0].([]ink.Element)[0].(string),
		"One line of text.",
	)
}
