#+feature dynamic-literals
package ink_test

import "core:encoding/json"
import "core:testing"
import "src:ink"

@(test)
convert_container :: proc(t: ^testing.T) {
	arrs := json.Array{json.Array{10}}
	defer json.destroy_value(arrs)

	got := ink.json_convert(arrs)
	defer ink.destroy_element(got)

	want := ink.Container{ink.Container{}}
	testing.expectf(t, len(got.(ink.Container)) == len(want), "got %w; want %w")
	testing.expect_value(t, got.(ink.Container)[0].(ink.Container)[0].(f64), 10)
}

@(test)
convert_string :: proc(t: ^testing.T) {
	got := ink.json_convert("^Hey!")
	defer ink.destroy_element(got)

	testing.expect_value(t, got.(string), "Hey!")
}

// convert_choice_done :: proc(t: ^testing.T) {
// 	s := ink.story_make_from_json(#load("testdata/choice_done.json"))
//
// 	sub1: map[string]ink.Container
// 	sub1["s"] = ink.Container{"choice ", ink.Divert{path = "$r", var = true}, nil}
// 	defer delete(sub1)
//
// 	subs: map[string]ink.Container
// 	subs["c-0"] = ink.Container {
// 		.Ev,
// 		ink.Divert_Assign{path = "0.c-0.$r2"},
// 		.Ev_End,
// 		ink.Temp_Var{name = "$r"},
// 		ink.Divert{path = "0.0.s"},
// 		ink.Container{ink.Container_Info{name = "$r2"}},
// 		.Done,
// 		"\n",
// 		ink.Divert{path = "0.g-0"},
// 		ink.Container_Info{flags = {.Visits, .Count_Start_Only}},
// 	}
// 	subs["g-0"] = ink.Container{.Done, ink.Container_Info{flags = {.Visits, .Count_Start_Only}}}
// 	defer delete(subs)
//
// 	want := ink.Container {
// 		ink.Container {
// 			ink.Container {
// 				.Ev,
// 				ink.Divert_Assign{path = "0.0.$r1"},
// 				ink.Temp_Var{name = "$r"},
// 				.Str,
// 				ink.Divert{path = ".^.s"},
// 				ink.Container{ink.Container_Info{name = "$r1"}},
// 				.Str_End,
// 				.Ev_End,
// 				ink.Choice{path = "0.c-0", flags = {.Has_Start_Content, .Once_Only}},
// 				ink.Container_Info{subs = sub1},
// 			},
// 			ink.Container_Info{subs = subs},
// 		},
// 		.Done,
// 		ink.Container_Info{flags = {.Visits}},
// 	}
//
// 	testing.expect_value(t, s.root, want)
// }
