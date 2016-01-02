require "yaml"

MESSAGES = YAML.load_file("mortgage_messages.yml")
lang = "en"

def prompt(lang, message)
  puts "--> " + MESSAGES[lang][message]
end

def positive_number?(input)
  (input == input.to_i.to_s || input == input.to_f.to_s) && input.to_f > 0
end 

def positive_integer?(input)
  input == input.to_i.to_s && input.to_i > 0
end

def yes_no(input)
  return "yes" if input.downcase == "y" || input.downcase == "yes"
  return "no" if input.downcase == "n" || input.downcase == "no"
end

def check_for_number(input, lang, error)
  until positive_number?(input)
    prompt(lang, error)
    input = gets.chomp
  end
    input
end

def check_for_integer(input, lang, error)
  until positive_integer?(input)
    prompt(lang, error)
    input = gets.chomp
  end
  input
end

def confirm_input(input, lang, item)
  puts "--> Your #{item} is: #{input} - Is this correct? (Y/N)"
  confirm = gets.chomp
  until yes_no(confirm)
    prompt(lang, "enter_yes_no")
    confirm = gets.chomp
  end
  yes_no(confirm)
end

prompt(lang, "welcome")

begin
  prompt(lang, "enter_loan_amount")
  input = gets.chomp
  input = check_for_number(input, lang, "error_not_number")
  confirmed = confirm_input("$#{input}", lang, "total Loan Amount")
end until confirmed == "yes"
loan_amount = input.to_f.round(2)

begin
  prompt(lang, "enter_annual_rate")
  input = gets.chomp
  input = check_for_number(input, lang, "error_not_number")
  confirmed = confirm_input("#{input.to_f.round(2)}%", lang, "Annual Interest Rate")
end until confirmed == "yes"
annual_rate = input.to_f / 100

begin
  prompt(lang, "enter_loan_duration_years")
  input = gets.chomp
  input = check_for_integer(input, lang, "error_not_integer")
  confirmed = confirm_input("#{input} Years", lang, "Loan Duration in Years")
end until confirmed == "yes"
duration_years = input.to_i

monthly_rate = annual_rate / 12
duration_months = duration_years * 12

monthly_payment = loan_amount * 
                  (monthly_rate * (1 + monthly_rate) ** duration_months) /
                  ((1 + monthly_rate) ** duration_months - 1)

puts "--> Your monthly payment is: $#{monthly_payment.round(2)}"


