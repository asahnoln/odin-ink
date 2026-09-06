package ink

import "core:encoding/json"
import "core:slice"
import "core:strconv"
import "core:strings"

Element :: union {
	string,
	f64,
	bool,
	Container,
	Container_Info,
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
	Nop,
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

Idx :: union #no_nil {
	int,
	string,
}

Idx_Path :: [dynamic]Idx

Story :: struct {
	root:            Container,
	current_choices: [dynamic]Choice,
	can_continue:    bool,
	str_builder:     strings.Builder,
	stack:           [dynamic]string,
	mode:            Mode,
	idx_path:        Idx_Path,
	vars:            map[string]string,
	root_allocated:  bool,
	_last_idx:       int,
}

IDX_PATH_SEP :: "."
REL_PATH_START :: '.'
REL_PATH_PARENT :: "^"

story_make :: proc {
	story_make_empty,
	story_make_from_struct,
	story_make_from_json,
}

story_make_empty :: proc() -> Story {
	s := Story {
		str_builder     = strings.builder_make(),
		current_choices = make([dynamic]Choice),
		stack           = make([dynamic]string),
		idx_path        = make(Idx_Path),
		vars            = make(map[string]string),
		can_continue    = true,
	}

	return s
}

story_make_from_struct :: proc(c: Container) -> Story {
	s := story_make_empty()
	s.root = c
	return s
}

story_make_from_json :: proc(data: []byte) -> (s: Story, err: json.Error) {
	s = story_make_empty()

	j := json.parse(data) or_return
	defer json.destroy_value(j)

	c := json_convert(j.(json.Object)["root"])

	s.root = c.(Container)
	s.root_allocated = true

	return
}

story_destroy :: proc(s: ^Story) {
	delete(s.current_choices)
	delete(s.stack)
	delete(s.idx_path)
	delete(s.vars)
	strings.builder_destroy(&s.str_builder)

	if s.root_allocated {
		destroy_element(s.root)
	}

}

story_continue :: proc(s: ^Story) -> string {
	_process_container(s, s.root)

	s.can_continue = len(s.idx_path) > 0
	if s.can_continue {
		if _, ok := s.idx_path[len(s.idx_path) - 1].(string); ok {
			s.can_continue = false
		}
	}

	l := strings.clone(strings.to_string(s.str_builder))
	strings.builder_reset(&s.str_builder)

	return l
}

_process_container :: proc(s: ^Story, c: Container, depth: int = 0) -> (cont: bool) {
	if len(s.idx_path) == depth {
		append(&s.idx_path, 0)
	}

	from := 0
	switch v in s.idx_path[depth] {
	case int:
		from = v
	case string:
		if info, ok := c[len(c) - 1].(Container_Info); ok {
			// TODO: What happens if this container not found? Error?
			if cnt, ok := info.subs[v]; ok {
				_process_container(s, cnt, depth + 1)
				return false
			}
		}

		for e, i in c {
			if cnt, ok := e.(Container); ok {
				// TODO:: What happens if container not found? Error?
				if info, ok := cnt[len(cnt) - 1].(Container_Info); ok && info.name == v {
					from = i
					break
				}
			}
		}
	}

	for e, i in c[from:] {
		s.idx_path[depth] = i + from

		#partial switch v in e {
		case Container:
			_process_container(s, v, depth + 1) or_return
		case string:
			strings.write_string(&s.str_builder, v)
			if v == "\n" {
				s.idx_path[depth] = s.idx_path[depth].(int) + 1
				return false
			}
		case Divert:
			_convert_path(v.path, &s.idx_path)

			_process_container(s, s.root)
			return false
		}
	}

	pop(&s.idx_path)
	return true
}

choose_choice_index :: proc(s: ^Story, i: int) {
	_convert_path(s.current_choices[i].path, &s.idx_path)

	resize(&s.current_choices, 0)
}

_convert_path :: proc(path: string, idxs: ^Idx_Path) {
	p_idx := 0
	if path[0] == REL_PATH_START {
		p_idx = 1
	}

	p := strings.split(path[p_idx:], IDX_PATH_SEP)
	defer delete(p)

	idx_path_resize := slice.count(p, REL_PATH_PARENT)

	last_idx := pop(idxs)
	resize(idxs, 0 if idx_path_resize == 0 else len(idxs) - idx_path_resize + 1)

	for i in p[idx_path_resize:] {
		iu: Idx
		ix, ok := strconv.parse_int(i, 10)
		iu = ix if ok else i
		append(idxs, iu)
	}

	append(idxs, last_idx)
}
