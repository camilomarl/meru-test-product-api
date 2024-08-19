require 'rails_helper'

RSpec.describe Product, type: :model do
  subject {
    described_class.new(
      name: "Example Product",
      sku: "123ABC",
      serial: "XYZ789",
      price: 100.50,
      stock: 10
    )
  }

  # Test presence validations
  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is not valid without a name" do
    subject.name = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without a sku" do
    subject.sku = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without a serial" do
    subject.serial = nil
    expect(subject).to_not be_valid
  end

  # Test numericality validations
  it "is not valid with a negative price" do
    subject.price = -1
    expect(subject).to_not be_valid
  end

  it "is valid with a price of 0" do
    subject.price = 0
    expect(subject).to be_valid
  end

  it "is not valid with a non-integer stock" do
    subject.stock = 1.5
    expect(subject).to_not be_valid
  end

  it "is not valid with a negative stock" do
    subject.stock = -1
    expect(subject).to_not be_valid
  end

  it "is valid with a stock of 0" do
    subject.stock = 0
    expect(subject).to be_valid
  end
end
