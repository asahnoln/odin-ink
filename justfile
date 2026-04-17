alias t := test
alias wt := watch-test
alias b := build
alias r := run

collection := '-collection:src=src'
cmd := 'src/cmd'

test:
  odin test tests/ -all-packages {{collection}}

build: test
  odin build {{cmd}} {{collection}} --vet 

run input: test
  odin run {{cmd}} {{collection}} -- {{input}}

watch-test:
  watchexec -w src -w tests -c -- just --justfile={{justfile()}} test
