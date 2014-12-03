require 'pry'
require 'csv'
require_relative 'invoice'
require_relative 'generic_repository_helper'
require_relative 'invoice_repository_helper'


class InvoiceRepository
  include GenericRepositoryHelper
  include InvoiceRepositoryHelper

  attr_reader :repository, :sales_engine
  attr_accessor :new_invoice

  def initialize(sales_engine)
    @sales_engine = sales_engine
    @repository = []
  end

  def inspect
    "I am a Invoice repo, inspect was called."
  end

  def loader(filepath)
    csv = CSV.open(File.join(filepath, 'invoices.csv'), headers: true, header_converters: :symbol)
    @repository = csv.map { |row| Invoice.new(row, self) }
  end

  def find_transactions_using_id(id)
    sales_engine.find_transcations_using_invoice(id)
  end

  def find_items_using_id(id)
    sales_engine.find_items_using_invoice(id)
  end

  def find_customer_using_customer_id(customer_id)
    sales_engine.find_customer_using_customer_id(customer_id)
  end

  def find_invoice_items_using_invoice_id(id)
    sales_engine.find_invoice_items_using_invoice_id(id)
  end

  def create(invoice_data)
    new_invoice_id = new_id
    sales_engine.create_invoice_items(invoice_data[:items], new_invoice_id)
    create_invoice(invoice_data[:customer], invoice_data[:merchant], new_invoice_id)
    insert_invoice
    new_invoice
  end

  def create_invoice(customer, merchant, new_invoice_id)
    data =
    {
      id: new_invoice_id,
      customer_id: customer.id,
      merchant_id: merchant.id,
      status: "shipped",
      created_at: Date.today.to_s,
      updated_at: Date.today.to_s
    }
    self.new_invoice = Invoice.new(data,self)
  end

  def insert_invoice
    @repository << new_invoice
  end

  def new_id
    repository.max_by {|invoice| invoice.id}.id + 1
  end

  def create_transaction(transaction_data, id)
    sales_engine.create_transaction(transaction_data, id)
  end

  def returns_revenue_for_all_merchants_on_specific_date(merchant_repository_ids, date)
    invoice_items_successful_and_verified = successful_invoices(merchant_repository_ids, date).map {|invoice| find_invoice_items_using_invoice_id(invoice.id)}.flatten
    invoice_items_successful_and_verified.reduce(0) {|sum, invoice_item| sum + (invoice_item.quantity * invoice_item.unit_price)}
  end

  def successful_invoices(merchant_repository_ids, date)
    invoices_with_verified_merchant_ids = repository.select do |invoice|
      (merchant_repository_ids.include?(invoice.merchant_id)) && (invoice.created_at == date)   #ask question about parenthesis strength. This does not work without parenthesis
    end
    invoices_with_verified_merchant_ids.select {|invoice| invoice.charged?}
  end

end
