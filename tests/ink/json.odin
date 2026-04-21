package ink_test

import "core:encoding/json"
import "core:testing"
import "src:ink"

@(test)
convert_json_to_str :: proc(t: ^testing.T) {
	res := ink.convert_json(cast(json.String)"^Conversion!")
	defer ink.destroy_element(res)

	testing.expect_value(t, res.(string), "Conversion!")
}

@(test)
convert_json_to_cmd :: proc(t: ^testing.T) {
	// TODO: Table tests
	res := ink.convert_json(cast(json.String)"ev")
	defer ink.destroy_element(res)

	testing.expect_value(t, res.(ink.Cmd), ink.Cmd.Ev)
}

@(test)
convert_json_to_f64 :: proc(t: ^testing.T) {
	res := ink.convert_json(cast(json.Integer)5)
	defer ink.destroy_element(res)

	testing.expect_value(t, res.(f64), 5)
}

@(test)
convert_json_to_array :: proc(t: ^testing.T) {
	a := make(json.Array, 2)
	defer delete(a)
	a[0] = 1
	a[1] = 2

	res := ink.convert_json(a)
	got := res.([]ink.Element)
	defer ink.destroy_element(got)

	testing.expect_value(t, got[0].(f64), 1)
	testing.expect_value(t, got[1].(f64), 2)
}

@(test)
convert_json_to_object :: proc(t: ^testing.T) {
	o := make(json.Object)
	defer delete(o)
	o["hey"] = 1

	res := ink.convert_json(o)
	got := res.(map[string]ink.Element)
	defer ink.destroy_element(res)

	testing.expect_value(t, got["hey"].(f64), 1)
}
