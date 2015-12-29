require 'pry'

OPERATORS = ["+", "-", "*", "/"]

def print_operator_instructions
  puts "Type '+' to add."
  puts "Type '-' to subtract."
  puts "Type '*' to multiply."
  puts "Type '/' to divide."
end

puts "Welcome to Arithmetic Two-Number Calculator."

puts "Enter your first number."
input_1 = gets.chomp

until input_1 == input_1.to_i.to_s
  puts "That's not a number! Enter a number."
  input_1 = gets.chomp
end

puts "Enter your second number."
input_2 = gets.chomp

until input_2 == input_2.to_i.to_s
  puts "That's not a number! Enter a number."
  input_2 =gets.chomp
end

number_1 = input_1.to_i
number_2 = input_2.to_i

print_operator_instructions
operator = gets.chomp

until OPERATORS.include?(operator)
  puts "That's not an operator. Please enter an operator."
  print_operator_instructions
  operator = gets.chomp
end

answer =
  case operator
  when "+" then number_1 + number_2
  when "-" then number_1 - number_2
  when "*" then number_1 * number_2
  when "/" then number_1.to_f / number_2.to_f
  end

puts "#{number_1} #{operator} #{number_2} = #{answer}"



