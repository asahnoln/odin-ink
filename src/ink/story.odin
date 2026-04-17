package ink

import "core:strings"
Element :: union {
	Container,
	string,
}

Container :: []Element

Story :: struct {
	root: Container,
}

story_continue :: proc(s: ^Story) -> string {
	b, _ := strings.builder_make()
	defer strings.builder_destroy(&b)

	parse_container(s.root, &b)

	return strings.to_string(b)
}

parse_container :: proc(c: Container, b: ^strings.Builder) {
	for e in c {
		switch t in e {
		case Container:
			parse_container(t, b)
		case string:
			strings.write_string(b, t)
		}
	}
}
