package ink

has_next_str :: proc(c: Container, idx_path: []int) -> bool {
	if len(idx_path) == 0 {
		return false
	}

	idx_path_dyn := make([dynamic]int)
	defer delete(idx_path_dyn)

	for i in idx_path {
		append(&idx_path_dyn, i)
	}

	done: bool
	return !traverse_container(
		c,
		&idx_path_dyn,
		0,
		&done,
		proc(e: Element, done: ^bool) -> (cont: bool) {
			if cmd, ok := e.(Cmd); ok && cmd == .Done {
				done^ = true
			}

			// NOTE: Works while there's only one type of Element - string
			// TODO: Check for string
			return false
		},
		) && !done
}
