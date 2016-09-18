# Collect each mark into arrays.

class OCR
  attr_reader :binary

  def initialize(text)
    @binary = text
  end

  def convert
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

  private

  def zero?
    binary == <<-NUMBER.chomp
 _
| |
|_|

    NUMBER
  end

  def one?
    binary == <<-NUMBER.chomp

  |
  |

    NUMBER
  end

  def two?
    binary == <<-NUMBER.chomp
 _
 _|
|_

    NUMBER
  end

  def three?
    binary == <<-NUMBER.chomp
 _
 _|
 _|

    NUMBER
  end

  def four?
    binary == <<-NUMBER.chomp

|_|
  |

    NUMBER
  end

  def five?
    binary == <<-NUMBER.chomp
 _
|_
 _|

    NUMBER
  end

  def six?
    binary == <<-NUMBER.chomp
 _
|_
|_|

    NUMBER
  end

  def seven?
    binary == <<-NUMBER.chomp
 _
  |
  |

    NUMBER
  end

  def eight?
    binary == <<-NUMBER.chomp
 _
|_|
|_|

    NUMBER
  end

  def nine?
    binary == <<-NUMBER.chomp
 _
|_|
 _|

    NUMBER
  end
end
