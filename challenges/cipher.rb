class Cipher
  attr_reader :coder, :decoder, :key, :key_array
  ALPHABET = ("a".."z").to_a * 2
  ALPHABET.freeze

  def initialize(key=nil)
    @key = key ? key : make_key
    @key_array = @key.split(//)
    raise ArgumentError.new(invalid_characters_text) unless valid_characters?
    raise ArgumentError.new(blank_string_text) if empty_key?

    @coder = []
    make_coder
  end

  def encode(plain_text)
    text_array = plain_text.split(//)
    run_coder(text_array).join
  end

  def decode(code_text)
    reverse_alphabet = ALPHABET.reverse
    text_array = code_text.split(//)
    run_coder(text_array, reverse_alphabet).join
  end

  private

  def valid_characters?
    key_array.all? { |letter| ALPHABET.include?(letter) }
  end

  def empty_key?
    key == " " || key == ""
  end

  def invalid_characters_text
    "Key should contain only lowercase 'a'..'z' string characters."
  end

  def blank_string_text
    "Key cannot be blank."
  end

  def make_key
    ALPHABET.sample(100).join
  end

  def make_coder
    key_array.each { |letter| coder << ALPHABET.index(letter) }
  end

  def run_coder(text_array, alphabet=ALPHABET)
    text_array.each_with_index.map do |letter, index|
      alphabet[alphabet.index(letter) + coder[index]]
    end
  end
end
