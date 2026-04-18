package ink

import "core:encoding/json"
import "core:strings"

Element :: union {
	Container,
	string,
}

Container :: []Element

Story :: struct {
	can_continue: bool,
	// current_index: int,
	root:         Container,
}

// TODO: Continue refactor
story_make :: proc(
	json_text: []u8,
	allocator := context.allocator,
) -> (
	s: Story,
	err: json.Unmarshal_Error,
) {
	v := json.parse(json_text, allocator = allocator) or_return
	defer json.destroy_value(v)

	s.can_continue = true
	s.root = make(Container, 1)

	b := strings.builder_make(allocator)
	defer strings.builder_destroy(&b)
	strings.write_string(
		&b,
		v.(json.Object)["root"].(json.Array)[0].(json.Array)[0].(json.String)[1:],
	)
	strings.write_string(&b, v.(json.Object)["root"].(json.Array)[0].(json.Array)[1].(json.String))
	s.root[0] = strings.to_string(b)

	return s, nil
}

story_continue :: proc(s: ^Story) -> string {
	return s.root[0].(string)
}


// story_continue :: proc(s: ^Story) -> (r: string) {
// 	for e, i in s.root[s.current_index:] {
// 		#partial switch v in e {
// 		case string:
// 			s.current_index = i + 1
// 			return v
// 		}
// 	}
//
// 	return ""
// 	// return parse_container(s.root)
// }

// parse_container :: proc(c: Container) -> string {
// 	for e in c {
// 		switch t in e {
// 		case Container:
// 			return parse_container(t)
// 		case string:
// 			return t
// 		}
// 	}
//
// 	return ""
// }
