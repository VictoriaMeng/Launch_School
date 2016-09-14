class Sieve
  attr_reader :range

  def initialize(number)
    @range = (2..number).to_a
  end

  def primes
    range.each do |divisor|
      range.delete_if { |number| not_prime?(number, divisor) }
    end
    range
  end

  def not_prime?(number, divisor)
    number % divisor == 0 && number != divisor
  end
end

Sieve.new(100).primes