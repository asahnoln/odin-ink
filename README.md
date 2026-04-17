# Odin port of Ink

## API

```odin
// 1) Load story
story := ink.load(source_json_string);

// 2) Game content, line by line
for story.can_continue {
    fmt.println(story.continue());
}

// 3) Display story.current_choices list, allow player to choose one
fmt.println(story.current_choices[0].text);
story.choose_choice_index(0);
```

## TODO

- [] text
- [] text
- [] text
- [] text
- [] text
