package ink_test

import "core:encoding/json"
import "core:testing"
import "src:ink"

@(test)
convert_json_to_str :: proc(t: ^testing.T) {
	res, err := ink.convert_json(cast(json.String)"^Conversion!")
	if !testing.expect_value(t, err, nil) {
		return
	}

	defer ink.destroy_element(res)

	testing.expect_value(t, res.(string), "Conversion!")
}

@(test)
convert_json_newline_to_str :: proc(t: ^testing.T) {
	res, err := ink.convert_json(cast(json.String)"\n")
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer ink.destroy_element(res)

	testing.expect_value(t, res.(string), "\n")
}

@(test)
convert_json_to_cmd :: proc(t: ^testing.T) {
	tests := []struct {
		str:  string,
		want: ink.Cmd,
	} {
		{"ev", .Ev}, //
		{"/ev", .EvEnd},
		{"str", .Str},
		{"/str", .StrEnd},
		{"done", .Done},
	}

	for tt in tests {
		got, err := ink.convert_json(cast(json.String)tt.str)
		if !testing.expect_value(t, err, nil) {
			return
		}
		defer ink.destroy_element(got)

		testing.expectf(
			t,
			got.(ink.Cmd) == tt.want,
			"for %q got %v; want %v",
			tt.str,
			got,
			tt.want,
		)
	}
}

@(test)
convert_unknown_json_to_cmd_err :: proc(t: ^testing.T) {
	_, err := ink.convert_json(cast(json.String)"")

	testing.expect_value(t, err, ink.Unknown_Cmd_Error{""})
}

@(test)
convert_json_to_f64 :: proc(t: ^testing.T) {
	res, err := ink.convert_json(cast(json.Integer)5)
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer ink.destroy_element(res)

	testing.expect_value(t, res.(f64), 5)
}

@(test)
convert_json_to_array :: proc(t: ^testing.T) {
	a := make(json.Array, 2)
	defer delete(a)
	a[0] = 1
	a[1] = 2

	res, err := ink.convert_json(a)
	if !testing.expect_value(t, err, nil) {
		return
	}
	got := res.([]ink.Element)
	defer ink.destroy_element(got)

	testing.expect_value(t, got[0].(f64), 1)
	testing.expect_value(t, got[1].(f64), 2)
}

@(test)
convert_json_to_object :: proc(t: ^testing.T) {
	o := make(json.Object)
	defer delete(o)
	o["hey"] = "lol"
	o["wow"] = 6

	res, err := ink.convert_json(o)
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer ink.destroy_element(res)

	got := res.(map[string]ink.Element)
	testing.expect_value(t, got["wow"].(f64), 6)
	testing.expect_value(t, got["hey"].(string), "lol")
}

@(test)
convert_json_divert_value :: proc(t: ^testing.T) {
	o := make(json.Object)
	defer delete(o)
	o["^->"] = "path.to.smth"

	got, err := ink.convert_json(o)
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer ink.destroy_element(got)

	testing.expect_value(t, got.(ink.DivertValue), ink.DivertValue{path = "path.to.smth"})
}

@(test)
convert_json_divert :: proc(t: ^testing.T) {
	o := make(json.Object)
	defer delete(o)
	o["->"] = "some.path"

	got, err := ink.convert_json(o)
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer ink.destroy_element(got)

	testing.expect_value(t, got.(ink.Divert), ink.Divert{path = "some.path"})
}

@(test)
convert_json_divert_to_var :: proc(t: ^testing.T) {
	o := make(json.Object)
	defer delete(o)
	o["->"] = "varName"
	o["var"] = true

	got, err := ink.convert_json(o)
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer ink.destroy_element(got)

	testing.expect_value(t, got.(ink.Divert), ink.Divert{path = "varName", var = true})
}

@(test)
convert_json_assign_temp :: proc(t: ^testing.T) {
	o := make(json.Object)
	defer delete(o)
	o["temp="] = "varName"

	res, err := ink.convert_json(o)
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer ink.destroy_element(res)

	testing.expect_value(t, res.(ink.VarAssignTemp), ink.VarAssignTemp{name = "varName"})
}

@(test)
convert_json_choice :: proc(t: ^testing.T) {
	o := make(json.Object)
	defer delete(o)
	o["*"] = "path.to.choice"
	o["flg"] = 18

	res, err := ink.convert_json(o)
	if !testing.expect_value(t, err, nil) {
		return
	}
	defer ink.destroy_element(res)

	testing.expect_value(t, res.(ink.Choice), ink.Choice{path = "path.to.choice", flag = 18})
}
