package ink_test

import "core:encoding/json"
import "core:testing"
import "src:ink"

@(test)
convert_json_text :: proc(t: ^testing.T) {
	got := ink.convert_json("^A line")
	defer ink.destroy_element(got)

	testing.expect_value(t, got.(string), "A line")
}

@(test)
convert_json_newline :: proc(t: ^testing.T) {
	got := ink.convert_json("\n")
	defer ink.destroy_element(got)

	testing.expect_value(t, got.(string), "\n")
}

@(test)
convert_json_empty :: proc(t: ^testing.T) {
	got := ink.convert_json("")
	defer ink.destroy_element(got)

	testing.expect_value(t, got.(string), "")
}

@(test)
convert_json_cmd_done :: proc(t: ^testing.T) {
	got := ink.convert_json("done")
	defer ink.destroy_element(got)

	testing.expect_value(t, got.(ink.Cmd), ink.Cmd.Done)
}
