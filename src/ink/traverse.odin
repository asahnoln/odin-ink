package ink

import "core:strings"

collect :: proc(c: Container, idx_path: ^[dynamic]int) -> string {
	b := strings.builder_make()

	traverse_container(
		c,
		idx_path,
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

	return strings.to_string(b)
}

traverse_container :: proc(
	c: Container,
	idx_path: ^[dynamic]int,
	deep_idx: int,
	data: $T,
	callback: proc(e: Element, data: T) -> (cont: bool),
) -> (
	cont: bool,
) {
	switch {
	case len(idx_path) == 0:
		return
	case deep_idx >= len(idx_path):
		return
	}

	defer if idx_path[deep_idx] == len(c) {
		pop_safe(idx_path)

		if deep_idx > 0 {
			idx_path[deep_idx - 1] += 1
		}
	}

	if len(idx_path) > deep_idx + 1 {
		traverse_container(
			c[idx_path[deep_idx]].(Container),
			idx_path,
			deep_idx + 1,
			data,
			callback,
		) or_return
	}

	base := idx_path[deep_idx]
	for e, i in c[base:] {
		if cntr, ok := e.(Container); ok {
			append(idx_path, 0)
			traverse_container(cntr, idx_path, len(idx_path) - 1, data, callback) or_return
			continue
		}

		idx_path[deep_idx] = base + i + 1

		callback(e, data) or_return
	}

	return true
}
