require 'pry'
require 'yaml'
MESSAGES = YAML.load_file('calculator_messages.yml')

OPERATORS = ["+", "-", "*", "/"]

def print_operator_instructions
  puts MESSAGES["enter_add"]
  puts MESSAGES["enter_minus"]
  puts MESSAGES["enter_multiply"]
  puts MESSAGES["enter_divide"]
end

def number?(input)
  input == input.to_i.to_s || input == input.to_f.to_s
end

def convert_to_number(input)
  return input.to_i if input == input.to_i.to_s
  return input.to_f if input == input.to_f.to_s
end

puts MESSAGES["welcome"]

puts MESSAGES["enter_number_1"]
input_1 = gets.chomp

until number?(input_1)
  puts MESSAGES["error_not_number"]
  input_1 = gets.chomp
end

puts MESSAGES["enter_number_2"]
input_2 = gets.chomp

until number?(input_2)
  puts MESSAGES["error_not_number"]
  input_2 = gets.chomp
end

number_1 = convert_to_number(input_1)
number_2 = convert_to_number(input_2)

print_operator_instructions
operator = gets.chomp

until OPERATORS.include?(operator)
  puts MESSAGES["error_not_operator"]
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