package ink_test

import "core:testing"
import "src:ink"

@(test)
empty :: proc(t: ^testing.T) {
	s := ink.story_make()
	defer ink.story_destroy(&s)

	got := ink.story_continue(&s)
	testing.expect_value(t, got, "")
}

@(test)
hello_world :: proc(t: ^testing.T) {
	s := ink.story_make(
		ink.Container {
			ink.Container {
				"Hello, world!",
				"\n",
				ink.Container {
					.Done,
					ink.Container_Info{flags = {.Visits, .Count_Start_Only}, name = "g-0"},
				},
				nil,
			},
			.Done,
			ink.Container_Info{flags = {.Visits}},
		},
	)
	defer ink.story_destroy(&s)

	got := ink.story_continue(&s)
	testing.expect_value(t, got, "Hello, world!\n")
}

@(test)
choice_brackets :: proc(t: ^testing.T) {
	subs: map[string]ink.Container
	subs["c-0"] = ink.Container {
		"\n",
		"Text",
		"\n",
		ink.Divert{path = "0.g-0"},
		ink.Container_Info{flags = {.Visits, .Count_Start_Only}},
	}
	subs["g-0"] = ink.Container{.Done, ink.Container_Info{flags = {.Visits, .Count_Start_Only}}}
	defer delete(subs)

	s := ink.story_make(
		ink.Container {
			ink.Container {
				.Ev,
				.Str,
				"Option",
				.Str_End,
				.Ev_End,
				ink.Choice{path = "0.c-0", flags = {.Has_ChoiceOnly_Content, .Once_Only}},
				ink.Container_Info{subs = subs},
			},
			.Done,
			ink.Container_Info{flags = {.Visits}},
		},
	)
	defer ink.story_destroy(&s)

	l := ink.story_continue(&s)
	testing.expect_value(t, l, "")

	testing.expect_value(t, len(s.current_choices), 1)
	testing.expect_value(t, s.current_choices[0].text, "Option")

	ink.choose_choice_index(&s, 0)

	got := ink.story_continue(&s)
	want := "Text\n"
	testing.expectf(t, got == want, "got %q; want %q", got, want)
}

// TODO: Error for choice text from stack
