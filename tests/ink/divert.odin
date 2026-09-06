package ink_test

import "core:testing"
import "src:ink"

@(test)
divert :: proc(t: ^testing.T) {
	s := ink.story_make(
	ink.Container {
		ink.Divert{path = "3.2"},
		"Skip this",
		"\n",
		ink.Container {
			"Skip that",
			"\n",
			ink.Container {
				"Now...", //
				"\n",
			},
			"Collect ",
		},
		"this!",
		"\n",
	},
	)
	defer ink.story_destroy(&s)

	{
		l := ink.story_continue(&s)
		defer delete(l)
		testing.expect_value(t, l, "Now...\n")
	}

	{
		l := ink.story_continue(&s)
		defer delete(l)
		testing.expect_value(t, l, "Collect this!\n")
	}

	delete(ink.story_continue(&s))
	testing.expect_value(t, s.can_continue, false)
}

@(test)
divert_to_named_in_info :: proc(t: ^testing.T) {
	subs := make(map[string]ink.Container)
	subs["subContainer"] = ink.Container {
		"Sub",
		"text",
		ink.Container{"\n", "Super"},
		" subtext",
		"\n",
	}
	defer delete(subs)

	s := ink.story_make(
	ink.Container {
		ink.Divert{path = "2.subContainer"},
		"Don't read this",
		ink.Container {
			ink.Container_Info {
				subs = subs, //
			},
		},
	},
	)
	defer ink.story_destroy(&s)

	{
		l := ink.story_continue(&s)
		defer delete(l)
		testing.expect_value(t, l, "Subtext\n")
	}
	{
		l := ink.story_continue(&s)
		defer delete(l)
		testing.expect_value(t, l, "Super subtext\n")
	}

	delete(ink.story_continue(&s))
	testing.expect_value(t, s.can_continue, false)
}

@(test)
divert_relative_path :: proc(t: ^testing.T) {
	subs := make(map[string]ink.Container)
	subs["subName"] = ink.Container{"Sub", "container!", "\n"}
	defer delete(subs)

	s := ink.story_make(
	ink.Container {
		ink.Container {
			ink.Divert{path = ".^.^.subName"}, //
		},
		ink.Container_Info{subs = subs},
	},
	)
	defer ink.story_destroy(&s)

	{
		l := ink.story_continue(&s)
		defer delete(l)
		testing.expect_value(t, l, "Subcontainer!\n")
	}

	delete(ink.story_continue(&s))
	testing.expect_value(t, s.can_continue, false)
}

@(test)
divert_to_named_container_in_its_info :: proc(t: ^testing.T) {
	s := ink.story_make(
	ink.Container {
		ink.Divert{path = "1.named"}, //
		ink.Container {
			"Should skip this",
			"\n",
			ink.Container {
				"Get ", 	//
				ink.Container_Info{name = "named"},
			},
			"this!",
			"\n",
		},
	},
	)
	defer ink.story_destroy(&s)

	{
		l := ink.story_continue(&s)
		defer delete(l)
		testing.expect_value(t, l, "Subcontainer!\n")
	}

	delete(ink.story_continue(&s))
	testing.expect_value(t, s.can_continue, false)
}
