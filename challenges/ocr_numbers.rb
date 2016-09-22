class OCR

  protected

  attr_reader :binary, :rows, :string

  public

  def initialize(text)
    @binary = text
    @rows = []
    @string = ""
    binary_setup
  end

  def convert
    sort_rows
    generate_string_digits
    make_string
    string
  end

  private

  def binary_setup
    convert_tabs_to_spaces
    delete_extra_newlines
  end

  def convert_tabs_to_spaces
    binary.gsub!(/\t/, '  ')
  end

  def delete_extra_newlines
    binary.gsub!("\n\n", "\n")
  end

  def sort_rows
    binary.each_line("\n").to_a.reject { |line| line == "" }.each_slice(3) do |row|
      @rows << Row.new(row)
    end
  end

  def generate_string_digits
    rows.each(&:convert)
  end

  def make_string
    rows.each do |row|
      string << row.to_s
      string << "," unless rows[-1] == row
    end
  end
end

class Row

  protected

  attr_reader :lines, :digit_total, :digits, :string

  public

  def initialize(lines)
    @lines = lines
    @digits = []
    @string = ""
    setup
  end

  def to_s
    string
  end

  def convert
    count_digits
    digits_setup
    sort_digits
    digits.each(&:convert)
    make_string
  end

  private

  def setup
    delete_newlines
    add_spaces
  end

  def count_digits
    @digit_total = lines.map { |line| line.size }.max / 3
  end

  def delete_newlines
    lines.map! { |line| line.chomp }
  end

  def add_spaces
    lines.each { |line| add_space(line) if !divisible_by_three?(line) }
  end

  def add_space(line)
    line << " "
  end

  def divisible_by_three?(line)
    line.size % 3 == 0
  end

  def digits_setup
    digit_total.times { |digit| @digits << Digit.new }
  end

  def sort_digits
    lines.each do |line|
      counter = 0
      line.scan(/.../).each do |digit_part|
        p digit_part
        @digits[counter] << digit_part
        counter += 1
      end
    end
  end

  def make_string
    digits.each { |digit| string << digit.to_s }
  end
end

class Digit
  protected

  attr_reader :binary, :string

  public

  def initialize
    @binary = ""
  end

  def <<(part)
    @binary << part
  end

  def to_s
    string
  end

  def convert
    delete_spaces unless six_or_nine?
    @string = match
  end

  private

  def delete_spaces  
    binary.delete!(" ")
  end

  def six_or_nine?
    binary.delete(" ") == "_|_|_|"
  end

  def match
    return "0" if zero?
    return "1" if one?
    return "2" if two?
    return "3" if three?
    return "4" if four?
    return "5" if five?
    return "6" if six?
    return "7" if seven?
    return "8" if eight?
    return "9" if nine?
    "?"
  end

  def zero?
    binary == "_|||_|"
  end

  def one?
    binary == "||"
  end

  def two?
    binary == "__||_"
  end

  def three?
    binary == "__|_|"
  end

  def four?
    binary == "|_||"
  end

  def five?
    binary == "_|__|"
  end

  def six?
    binary == " _ |_ |_|"
  end

  def seven?
    binary == "_||"
  end

  def eight?
    binary == "_|_||_|"
  end

  def nine?
    binary == " _ |_| _|"
  end
end
