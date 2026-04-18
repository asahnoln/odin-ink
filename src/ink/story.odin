package ink

Element :: union {
	Container,
	string,
}

Container :: []Element

Story :: struct {
	can_continue: bool,
	// current_index: int,
	// root:          Container,
}

story_make :: proc(json_text: []u8) -> Story {
	return Story{can_continue = true}
}

story_continue :: proc(s: ^Story) -> string {
	return "Once upon a time...\n"
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
