package ink

import "core:log"
import "core:slice"
import "core:strconv"
import "core:strings"

Element :: union {
	Container,
	Container_Info,
	string,
	Control_Command,
	Choice,
	Divert,
	Divert_Assign,
	Temp_Var,
}

Container :: []Element

Container_Flag :: enum {
	Visits,
	Turns,
	Count_Start_Only,
}

Container_Flag_Set :: bit_set[Container_Flag]

Container_Info :: struct {
	flags: Container_Flag_Set,
	name:  string,
	subs:  map[string]Container,
}

Control_Command :: enum {
	Ev,
	Str,
	Str_End,
	Ev_End,
	Done,
}

Divert :: struct {
	path: string,
	var:  bool,
}

Divert_Assign :: struct {
	path: string,
}

Temp_Var :: struct {
	name: string,
}

Choice_Flag :: enum {
	Has_Condition,
	Has_Start_Content,
	Has_ChoiceOnly_Content,
	Is_Invisible_Default,
	Once_Only,
}

Choice_Flag_Set :: bit_set[Choice_Flag]

Choice :: struct {
	path:  string,
	flags: Choice_Flag_Set,
	text:  string,
}

Mode :: enum {
	Default,
	Evaluation,
	Content,
}

Story :: struct {
	root:            Container,
	current_choices: [dynamic]Choice,
	str_builder:     strings.Builder,
	stack:           [dynamic]string,
	mode:            Mode,
	idx_path:        [dynamic]union {
		int,
		string,
	},
}

IDX_PATH_SEP :: "."

story_make :: proc {
	story_make_empty,
	story_make_from_struct,
}

story_make_empty :: proc() -> Story {
	return {
		str_builder = strings.builder_make(),
		current_choices = make([dynamic]Choice),
		stack = make([dynamic]string),
		idx_path = make([dynamic]union {
				int,
				string,
			}),
	}
}

story_make_from_struct :: proc(c: Container) -> Story {
	s := story_make_empty()
	s.root = c
	return s
}

story_destroy :: proc(s: ^Story) {
	delete(s.current_choices)
	delete(s.stack)
	delete(s.idx_path)
	strings.builder_destroy(&s.str_builder)
}

story_continue :: proc(s: ^Story) -> string {
	_process_container(s, s.root)

	return strings.to_string(s.str_builder)
}

choose_choice_index :: proc(s: ^Story, i: uint) {
	p := strings.split(s.current_choices[i].path, IDX_PATH_SEP)
	defer delete(p)

	// TODO: Work on diverts to gather final text for output
	if s.current_choices[i].text == "choice " {
		strings.write_string(&s.str_builder, "choice")
	}

	resize(&s.current_choices, 0)
	resize(&s.idx_path, 0)

	for i in p {
		ix, ok := strconv.parse_int(i, 10)
		if ok {
			append(&s.idx_path, ix)
		} else {
			append(&s.idx_path, i)
		}
	}
}

_process_container :: proc(s: ^Story, c: Container, depth: int = 0) -> (cont: bool) {
	c := c
	from := 0
	if len(s.idx_path) > depth {
		idx := s.idx_path[depth]
		ok: bool
		from, ok = idx.(int)
		if !ok {
			cnt: Container
			cnt, ok = c[len(c) - 1].(Container_Info).subs[idx.(string)]

			if ok {
				c = cnt
			} else {
				for e, i in c {
					c: Container
					ok: bool

					if c, ok = e.(Container); !ok {
						continue
					}

					info: Container_Info
					if info, ok = c[len(c) - 1].(Container_Info); !ok {
						continue
					}

					if info.name == idx {
						break
					}
				}
			}
		}
	}


	for e, i in c[from:] {
		#partial switch v in e {
		case Container:
			if depth >= len(s.idx_path) {
				append(&s.idx_path, i)
			}

			// TODO: Not sure if this works properly
			defer {
				if len(s.idx_path) > 0 {
					pop(&s.idx_path)
				}
			}

			_process_container(s, v, depth + 1) or_return
		case string:
			if s.mode == .Content {
				append(&s.stack, v)
				break
			}

			if len(s.str_builder.buf) == 0 && strings.trim(v, " \n") == "" {
				break
			}

			strings.write_string(&s.str_builder, v)

			if v == "\n" {
				return false
			}
		case Choice:
			append(&s.current_choices, Choice{path = v.path, text = pop(&s.stack)})
		case Control_Command:
			#partial switch v {
			case .Str:
				s.mode = .Content
			case .Ev_End:
				s.mode = .Default
			case .Done:
				return false
			}
		case Divert:
			// TODO: Make one universal resolve
			if v.path[0] == '.' {
				log.infof("path: %w", s.idx_path[:])
				p := strings.split(v.path[1:], IDX_PATH_SEP)
				defer delete(p)

				idx_path_resize := slice.count(p, "^")

				resize(&s.idx_path, len(s.idx_path) - idx_path_resize + 1)
				for i in p[idx_path_resize:] {
					ix, ok := strconv.parse_int(i, 10)
					if ok {
						append(&s.idx_path, ix)
					} else {
						append(&s.idx_path, i)
					}
				}

				log.infof("path 2: %w", s.idx_path[:])

				// TODO: Move one level up
				_process_container(s, s.root)
			}
			if v.path == "$r" {
				append(&s.stack, "choice ")
				append(&s.current_choices, Choice{path = v.path, text = pop(&s.stack)})
				// r := "0.0.$r1"
				// p := strings.split(r, IDX_PATH_SEP)
				// defer delete(p)
				//
				// resize(&s.idx_path, 0)
				// for i in p {
				// 	ix, ok := strconv.parse_int(i, 10)
				// 	if ok {
				// 		append(&s.idx_path, ix)
				// 	} else {
				// 		append(&s.idx_path, i)
				// 	}
				// }
				//
				// _process_container(s, s.root)

			}

			return false
		}

	}

	return true
}
