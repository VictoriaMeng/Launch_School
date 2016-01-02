require "yaml"

MESSAGES = YAML.load_file("mortgage_messages.yml")
lang = "en"

loan = {}

def prompt(lang, message)
  puts "--> " + MESSAGES[lang][message]
end

def number?(input)
  input == input.to_i.to_s || input == input.to_f.to_s
end 

def yes_no(input)
  return "yes" if input.downcase == "y" || input.downcase == "yes"
  return "no" if input.downcase == "n" || input.downcase == "no"
  nil
end

def correct_for_number(input, lang, error)
  until number?(input)
    prompt(lang, error)
    input = gets.chomp
  end
    input
end

def confirm_loan_amount(input, lang)
  MESSAGES[lang]["confirm_loan_amount"] + "#{input.to_f.round(2)}" + MESSAGES[lang]["confirm_yes_no"]
  confirm = gets.chomp
  until confirm == yes_no(confirm)
    prompt(lang, "enter_yes_no")
    confirm = gets.chomp
  end
  confirm
end

prompt(lang, "welcome")

begin
  prompt(lang, "enter_loan_amount")
  input = gets.chomp
  input = correct_for_number(input, lang, "error_not_number") if !number?(input)
  confirmed = confirm_loan_amount(input, lang)
end until confirmed == "yes"



