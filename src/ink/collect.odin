package ink

import "core:strings"

collect :: proc(c: Container, idx_path: ^[dynamic]int) -> string {
	b := strings.builder_make()

	process_container(c, idx_path, &b, 0)

	return strings.to_string(b)
}

process_container :: proc(
	c: Container,
	idx_path: ^[dynamic]int,
	b: ^strings.Builder,
	deep_idx: int,
) -> (
	cont: bool,
) {
	defer if idx_path[deep_idx] == len(c) {
		pop_safe(idx_path)

		if deep_idx > 0 {
			idx_path[deep_idx - 1] += 1
		}
	}

	if len(idx_path) > deep_idx + 1 {
		process_container(c[idx_path[deep_idx]].(Container), idx_path, b, deep_idx + 1) or_return
	}

	base := idx_path[deep_idx]
	for e, i in c[base:] {
		switch v in e {
		case Container:
			append(idx_path, 0)
			process_container(v, idx_path, b, len(idx_path) - 1)
			continue
		case string:
			idx_path[deep_idx] = base + i + 1
			strings.write_string(b, v)

			if v == "\n" {
				return false
			}
		}
	}

	return true
}
