#+feature dynamic-literals
package ink_test

import "core:encoding/json"
import "core:strings"
import "core:testing"
import "src:ink"

@(test)
convert_container :: proc(t: ^testing.T) {
	arrs := json.Array{json.Array{10}}

	got := ink.json_convert(arrs)
	defer ink.destroy_element(got)
	json.destroy_value(arrs)

	want := ink.Container{ink.Container{}}
	testing.expectf(t, len(got.(ink.Container)) == len(want), "got %w; want %w")
	testing.expect_value(t, got.(ink.Container)[0].(ink.Container)[0].(f64), 10)
}

@(test)
convert_string :: proc(t: ^testing.T) {
	s := strings.clone("^Hey!")
	got := ink.json_convert(s)
	defer ink.destroy_element(got)
	delete(s)

	testing.expect_value(t, got.(string), "Hey!")
}

// TODO: What if empty string is ecnountered???

@(test)
convert_command :: proc(t: ^testing.T) {
	tests := []struct {
		cmd:  string,
		want: ink.Control_Command,
	} {
		{"done", .Done}, //
		{"ev", .Ev},
		{"/ev", .Ev_End},
		{"str", .Str},
		{"/str", .Str_End},
	}

	for tt in tests {
		el := ink.json_convert(tt.cmd)
		defer ink.destroy_element(el)

		got, _ := el.(ink.Control_Command)
		testing.expectf(t, got == tt.want, "for command %q: got %v; want %v", tt.cmd, el, tt.want)
	}
}

@(test)
convert_divert_from_var :: proc(t: ^testing.T) {
	obj := json.Object {
		"->"  = "$r",
		"var" = true,
	}
	got := ink.json_convert(obj)
	defer ink.destroy_element(got)
	delete(obj)

	testing.expect_value(t, got.(ink.Divert), ink.Divert{path = "$r", var = true})
}

@(test)
convert_divert :: proc(t: ^testing.T) {
	obj := json.Object {
		"->" = "0.0.s",
	}
	got := ink.json_convert(obj)
	defer ink.destroy_element(got)
	delete(obj)

	testing.expect_value(t, got.(ink.Divert), ink.Divert{path = "0.0.s"})
}

@(test)
convert_divert_assign :: proc(t: ^testing.T) {
	obj := json.Object {
		"^->" = "0.1.x",
	}
	got := ink.json_convert(obj)
	defer ink.destroy_element(got)
	delete(obj)

	testing.expect_value(t, got.(ink.Divert_Assign), ink.Divert_Assign{path = "0.1.x"})
}

@(test)
convert_temp_var :: proc(t: ^testing.T) {
	obj := json.Object {
		"temp=" = "$r",
	}
	got := ink.json_convert(obj)
	defer ink.destroy_element(got)
	delete(obj)

	testing.expect_value(t, got.(ink.Temp_Var), ink.Temp_Var{name = "$r"})
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
