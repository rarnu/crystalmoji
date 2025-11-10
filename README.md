# crystalmoji

### CrystalMoji is a Crystal porting for Kuromoji.

```
Kuromoji is an easy to use and self-contained Japanese morphological analyzer that does

Word segmentation. Segmenting text into words (or morphemes)
Part-of-speech tagging. Assign word-categories (nouns, verbs, particles, adjectives, etc.)
Lemmatization. Get dictionary forms for inflected verbs and adjectives
Readings. Extract readings for kanji
Several other features are supported. Please consult each dictionaries' Token class for details.
```

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crystalmoji:
       github: rarnu/crystalmoji
   ```

2. Run `shards install`

## Usage

```crystal
require "crystalmoji"
```

### Use it just like Kuromoji.

```crystal
input = "高い攻撃力を誇る伝説のドラゴン。どんな相手でも粉砕する、その破壊力は計り知れない。"
tokenizer = CrystalMoji::Ipadic::Tokenizer.new
s1 = tokenizer.furigana(input)
s2 = tokenizer.remove_furigana(s1)
puts s1
puts s2
```

## Contributing

1. Fork it (<https://github.com/rarnu/crystalmoji/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [rarnu](https://github.com/rarnu) - creator and maintainer
