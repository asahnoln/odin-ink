#+feature dynamic-literals
package ink_test

import "core:encoding/json"
import "core:strings"
import "core:testing"
import "src:ink"

@(test)
convert_container :: proc(t: ^testing.T) {
	arrs := json.Array{json.Array{10, nil}, nil}

	got := ink.json_convert(arrs)
	defer ink.destroy_element(got)
	json.destroy_value(arrs)

	testing.expect_value(t, len(got.(ink.Container)), 2)
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

@(test)
convert_newline :: proc(t: ^testing.T) {
	s := strings.clone("\n")
	got := ink.json_convert(s)
	defer ink.destroy_element(got)
	delete(s)

	testing.expect_value(t, got.(string), "\n")
}

// TODO: What if empty string is encountered???

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

@(test)
convert_info :: proc(t: ^testing.T) {
	obj := json.Object {
		"#n" = "name",
		"#f" = 5,
	}
	arr := json.Array{20, obj}

	c := ink.json_convert(arr)
	defer ink.destroy_element(c)
	delete(obj)
	delete(arr)

	got := c.(ink.Container)[1].(ink.Container_Info)
	testing.expect_value(t, got.name, "name")
	testing.expect_value(t, got.flags, ink.Container_Flag_Set{.Visits, .Count_Start_Only})
}

@(test)
convert_info_with_subs :: proc(t: ^testing.T) {
	obj := json.Object {
		"g-0" = json.Array{5, nil},
		"c-0" = json.Array{6, nil},
	}
	arr := json.Array{obj}

	c := ink.json_convert(arr)
	defer ink.destroy_element(c)
	delete(obj["g-0"].(json.Array))
	delete(obj["c-0"].(json.Array))
	delete(obj)
	delete(arr)

	got := c.(ink.Container)[0].(ink.Container_Info)
	testing.expect_value(t, got.subs["g-0"][0].(f64), 5)
	testing.expect_value(t, got.subs["c-0"][0].(f64), 6)
}

@(test)
convert_choice :: proc(t: ^testing.T) {
	obj := json.Object {
		"*"   = "0.c-0",
		"flg" = 18.0,
	}
	got := ink.json_convert(obj)
	defer ink.destroy_element(got)
	delete(obj)

	testing.expect_value(t, got.(ink.Choice).path, "0.c-0")
	testing.expect_value(
		t,
		got.(ink.Choice).flags,
		ink.Choice_Flag_Set{.Has_Start_Content, .Once_Only},
	)
}

@(test)
convert_bool :: proc(t: ^testing.T) {
	got := ink.json_convert(true)
	defer ink.destroy_element(got)

	testing.expect_value(t, got.(bool), true)
}

@(test)
convert_float :: proc(t: ^testing.T) {
	got := ink.json_convert(15.25)
	defer ink.destroy_element(got)

	testing.expect_value(t, got.(f64), 15.25)
}

// @(test)
// story_from_json_choice_done :: proc(t: ^testing.T) {
// 	s, err := ink.story_make_from_json(#load("testdata/choice_done.json"))
// 	defer ink.story_destroy(&s)
//
// 	if !testing.expect_value(t, err, nil) {
// 		return
// 	}
//
// 	l := ink.story_continue(&s)
// 	testing.expect_value(t, l, "")
//
// 	testing.expect_value(t, len(s.current_choices), 1)
//
// 	ink.choose_choice_index(&s, 0)
//
// 	got := ink.story_continue(&s)
// 	defer delete(got)
// 	want := "choice"
// 	testing.expectf(t, got == want, "got %q; want %q", got, want)
// }
