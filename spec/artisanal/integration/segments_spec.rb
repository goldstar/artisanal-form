RSpec.describe "Segments" do
  module Test::Segments
    class Contact
      include Artisanal::Form
      
      attribute :name, Dry::Types::Any
      attribute :email, Dry::Types::Any
      attribute :phone, Dry::Types::Any
      validates :email, :phone, presence: true
    end

    class Address
      include Artisanal::Form

      attribute :city, Dry::Types::Any
      validates :city, presence: true
    end

    class Person
      include Artisanal::Form

      segment :contact, Contact
      segment :address, Address
      attribute :name, Dry::Types::Any
      validates :name, presence: true
    end
  end

  let(:data) {{
    name: "John Smith",
    email: "john@example.com",
    phone: "123-456-7890",
    city: "Portland"
  }}

  let(:person) { Test::Segments::Person.new(data) }

  it "segments the input into different forms", :aggregate_failures do
    expect(person.name).to eq data[:name]
    expect(person.contact.name).to eq data[:name]
    expect(person.contact.email).to eq data[:email]
    expect(person.contact.phone).to eq data[:phone]
    expect(person.address.city).to eq data[:city]
  end

  it "updates the segments when assigning attributes", :aggregate_failures do
    expect(person.contact.email).to eq data[:email]
    person.assign_attributes(email: "foobar@example.com")
    expect(person.contact.email).to eq "foobar@example.com"
  end

  it "merges the segment data when serializing" do
    expect(person.to_h).to eq(data)
  end

  describe "#status" do
    let(:data) {{
      name: "John Smith",
      city: "Portland"
    }}

    it "returns the validation status of each segment" do
      expect(person.status).to eq(
        contact: :invalid,
        address: :valid
      )
    end
  end
end
