package ink_test

import "core:testing"
import "src:ink"

@(test)
choice :: proc(t: ^testing.T) {
	subs := make(map[string]ink.Container)
	subs["c-0"] = ink.Container{"Choice ", "branch", "\n"}
	defer delete(subs)

	s := ink.story_make(
		ink.Container {
			ink.Container {
				.Ev,
				.Str,
				"choice text",
				.Str_End,
				.Ev_End,
				ink.Choice{path = ".^.c-0", flags = {.Has_Start_Content, .Once_Only}},
				ink.Container_Info{subs = subs},
			},
		},
	)
	defer ink.story_destroy(&s)

	{
		l := ink.story_continue(&s)
		testing.expect_value(t, l, "")
	}

	testing.expect_value(t, s.can_continue, false)

	testing.expect_value(t, len(s.current_choices), 1)
	testing.expect_value(t, s.current_choices[0].text, "choice text")

	ink.choose_choice_index(&s, 0)

	testing.expect_value(t, len(s.current_choices), 0)
	testing.expect_value(t, s.can_continue, true)

	{
		l := ink.story_continue(&s)
		defer delete(l)
		testing.expect_value(t, l, "Choice branch\n")
	}

	ink.story_continue(&s)
	testing.expect_value(t, s.can_continue, false)
}

@(test)
choose_choice_index_out_of_bounds_err :: proc(t: ^testing.T) {
	subs := make(map[string]ink.Container)
	subs["c-0"] = ink.Container{"Choice ", "branch", "\n"}
	defer delete(subs)

	s := ink.story_make(
		ink.Container {
			ink.Container {
				.Ev,
				.Str,
				"choice text",
				.Str_End,
				.Ev_End,
				ink.Choice{path = ".^.c-0", flags = {.Has_Start_Content, .Once_Only}},
				ink.Container_Info{subs = subs},
			},
		},
	)
	defer ink.story_destroy(&s)

	ink.story_continue(&s)

	{
		err := ink.choose_choice_index(&s, 100)
		testing.expect_value(t, err, ink.Choose_Out_Of_Bounds_Error{chosen = 100, len = 1})
	}
	{
		err := ink.choose_choice_index(&s, -200)
		testing.expect_value(t, err, ink.Choose_Out_Of_Bounds_Error{chosen = -200, len = 1})
	}
}
