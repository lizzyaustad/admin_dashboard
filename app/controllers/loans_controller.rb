class LoansController < ApplicationController
  def index
    puts 'Loans index'
    @loans = Loan.all
  end
end
