class OCR

  attr_reader :binary, :rows, :digit_count, :digits, :string

  def initialize(text)
    @binary = text
    @rows = []
    @digit_count = count_digits
    @digits = []
    @string = ""
    digits_setup
  end

  def convert
    sort_rows
    sort_digits
    convert_digits
    string
  end

  private

  def digits_setup
    digit_count.times { |digit| @digits << "" }
  end

  def count_digits
    binary[0..binary.index("\n")].length / 3
  end

  def sort_rows
    binary.each_line("\n") { |line| @rows << line.chomp }
  end

  def sort_digits
    rows.each do |row|
      counter = 0
      row.scan(/.../).each do |digit_part|
        @digits[counter] << digit_part.delete(" ")
        counter += 1
      end
    end
  end

  def convert_digits
    digits.each { |digit| @string << match(digit) }
  end

  def match(digit)
    return "0" if zero?(digit)
    "1" if one?(digit)
  end

  def zero?(digit)
    digit == "_|||_|"
  end

  def one?(digit)
    digit == "||"
  end

end

    text = <<-NUMBER.chomp
    _ 
  || |
  ||_|

    NUMBER

result = OCR.new(text)
result.convert


