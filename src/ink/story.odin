package ink

import "core:encoding/json"
import "core:strings"

Story :: struct {
	can_continue:   bool,
	root:           Container,
	idx_path:       [dynamic]int,
	// TODO: Figure it if I can check whehter root is heap allocated
	root_allocated: bool,
}

Element :: union {
	Container,
	string,
	Cmd,
}

Container :: distinct []Element

Cmd :: enum {
	Done,
}

make_story :: proc {
	make_story_from_container,
	make_story_from_json,
}

make_story_from_json :: proc(json_data: []byte) -> (s: Story, err: json.Error) {
	j := json.parse(json_data) or_return
	defer json.destroy_value(j)

	c := convert_json(j.(json.Object)["root"])
	s = make_story(c.(Container))
	s.root_allocated = true

	return s, nil
}

make_story_from_container :: proc(c: Container) -> Story {
	s := Story {
		root     = c,
		idx_path = make([dynamic]int),
	}

	append(&s.idx_path, 0)
	s.can_continue = has_next_str(c, s.idx_path[:])
	return s
}

destroy_story :: proc(s: ^Story) {
	delete(s.idx_path)
	if s.root_allocated {
		destroy_element(s.root)
	}
}

story_continue :: proc(s: ^Story) -> string {
	if !s.can_continue {
		return ""
	}

	b := strings.builder_make()

	traverse_container(
		s.root,
		&s.idx_path,
		0,
		&b,
		proc(e: Element, data: ^strings.Builder) -> (cont: bool) {
			if str, ok := e.(string); ok {
				b := data
				strings.write_string(b, str)

				if str == "\n" {
					return false
				}
			}

			return true
		},
	)

	s.can_continue = has_next_str(s.root, s.idx_path[:])

	return strings.to_string(b)
}
