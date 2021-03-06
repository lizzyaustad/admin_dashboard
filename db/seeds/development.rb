### Roles
print format("%-30s", 'Seeding Roles... ')
admin_role = Role.find_or_create_by!(role_name: 'admin')
officer_role = Role.find_or_create_by!(role_name: 'officer')
member_role = Role.find_or_create_by!(role_name: 'member')
puts 'Done'

### Phases
print format("%-30s", 'Seeding Phases... ')
['training', 'accepting_loans', 'repayment_only'].each do |phase_type|
  Phase.find_or_create_by!(phase_type: phase_type)
end
puts 'Done'

### Co-Ops
print format("%-30s", 'Seeding Co-Ops... ')
[
    { name: 'Co-Op 1', phase_id: 3, is_active: true, start_date: 3.years.ago, end_date: 7.years.from_now, location: 'Nairobi', initial_balance: 10000, expected_repayment: 12000, interest: 2, current_balance: 6500 },
    { name: 'Co-Op 2', phase_id: 2, is_active: true, start_date: 2.years.ago, end_date: 7.years.from_now, location: 'Mombasa', initial_balance: 9000, expected_repayment: 11000, interest: 2, current_balance: 6000 },
    { name: 'Co-Op 3', phase_id: 3, is_active: true, start_date: 1.years.ago, end_date: 7.years.from_now, location: 'Kisumu', initial_balance: 13000, expected_repayment: 15500, interest: 2, current_balance: 8000 },
    { name: 'Co-Op 4', phase_id: 2, is_active: true, start_date: 8.months.ago, end_date: 7.years.from_now, location: 'Nakuru', initial_balance: 8000, expected_repayment: 10000, interest: 2, current_balance: 5000 },
    { name: 'Co-Op 5', phase_id: 1, is_active: true, start_date: 3.months.ago, end_date: 7.years.from_now, location: 'Eldoret', initial_balance: 5000, expected_repayment: 6000, interest: 2, current_balance: 3000 }
].each do |attrs|
  CoOp.find_or_create_by!(name: attrs[:name]) do |co_op|
    co_op.attributes = attrs
  end
end
puts 'Done'

### Users
print format("%-30s", 'Seeding Users... ')

User.find_or_create_by!(email: 'admin@pangeanetwork.com') do |admin|
  admin.first_name = 'Admin'
  admin.last_name = 'User'
  admin.role = admin_role
  admin.phone = '123456789'
  admin.co_op = CoOp.first
end

CoOp.all.each do |co_op|
  User.find_or_create_by!(email: "officer@#{co_op.name.gsub(/\s+/, "").underscore.downcase}.com") do |officer|
    officer.first_name = Faker::Name.female_first_name
    officer.last_name = Faker::Name.last_name
    officer.role = officer_role
    officer.co_op = co_op
    officer.phone = Faker::PhoneNumber.phone_number
  end

  5.times do
    User.find_or_create_by!(phone: Faker::PhoneNumber.phone_number) do |member|
      member.first_name = Faker::Name.female_first_name
      member.last_name = Faker::Name.last_name
      member.role = member_role
      member.co_op = co_op
    end
  end
end
puts 'Done'

### Loans
print format("%-30s", 'Seeding Loans... ')

CoOp.all.each do |co_op|
  next if co_op.phase == 1
  co_op_balance = co_op.initial_balance
  co_op.users.each do |user|
    Loan.find_or_create_by!(user_id: user.id) do |loan|
      loan.balance = rand(200..co_op_balance/2)
      loan.initial_balance = loan.balance
      loan.total_repayed = 0
      co_op_balance = co_op_balance - loan.balance
      loan.loan_start = co_op.start_date + 6.months
      loan.loan_end = loan.loan_start + 2.years
      loan.interest = 5
    end
  end
end
puts 'Done'

### Transactions
print format("%-30s", 'Seeding Transactions... ')

Loan.all.each do |loan|
  balance = loan.balance
  amount = rand(10..loan.balance/5)
  date = loan.loan_start + 1.month
  rand(2..5).times do
    Transaction.create!(loan_id: loan.id) do |t|
      t.user_id = loan.user_id
      t.amount = amount
      t.previous_balance = balance
      balance = balance - amount
      t.new_balance = balance
      t.created_at = date
      date += 2.weeks
    end
    loan.update(balance: balance, total_repayed: loan.total_repayed + amount)
  end
end
puts 'Done'
