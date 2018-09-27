class TransactionsController < ApplicationController
  def index
    puts 'transactions index'
    @transactions = Transaction.all
  end
end
