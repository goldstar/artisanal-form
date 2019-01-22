RSpec.describe "Validations" do
  module Test::Validation
    class Contact
      include Artisanal::Form
      
      attribute :email, Dry::Types::Any
      attribute :phone, Dry::Types::Any

      validates :email, :phone, presence: true
      validates :email, length: { minimum: 2 }
    end

    # Normal validation
    class Person
      include Artisanal::Form

      attribute :name, Dry::Types::Any
      attribute :phone, Dry::Types::Any

      validates :name, :phone, presence: true
    end

    # Segment validation
    class PersonWithSegment < Person
      segment :contact, Contact
    end
    class PersonWithSegmentShallow < Person
      segment :contact, Contact, errors: :shallow
    end
    class PersonWithSegmentDeep < Person
      segment :contact, Contact, errors: :deep
    end
    class PersonWithSegmentNone < Person
      segment :contact, Contact, validate: false
    end

    # Association validation
    class PersonWithAssociation < Person
      attribute :contact, Contact
      validates_associated :contact
    end
    class PersonWithAssociationShallow < Person
      attribute :contact, Contact
      validates_associated :contact, errors: :shallow
    end
    class PersonWithAssociationMerge < Person
      attribute :contact, Contact
      validates_associated :contact, errors: :merge
    end
  end

  before { person.valid? }

  let(:person) { Test::Validation::Person.new }
  let(:contact) { person.contact }
  let(:errors) { person.errors }

  it "validates attributes as expected", :aggregate_failures do
    expect(errors).to include :name
    expect(errors).to include :phone
  end

  context "when segments are present" do
    let(:person) { Test::Validation::PersonWithSegment.new }

    it "validates each segment" do
      expect(contact.errors).to_not be_empty
    end

    it "does :merge errors by default", :aggregate_failures do
      expect(errors).to_not include :contact
      expect(errors).to include :email
      expect(errors[:phone]).to eq ["can't be blank"]
      expect(errors[:email]).to eq [
        "can't be blank",
        "is too short (minimum is 2 characters)"
      ]
    end

    context "and the errors option is set to :shallow" do
      let(:person) { Test::Validation::PersonWithSegmentShallow.new }

      it "specifies that the segment is invalid", :aggregate_failures do
        expect(errors).to_not include :email
        expect(errors).to include :contact
        expect(errors[:contact]).to eq ["is invalid"]
      end
    end

    context "and the errors option is set to :deep" do
      let(:person) { Test::Validation::PersonWithSegmentDeep.new }

      it "includes all the errors from the segment", :aggregate_failures do
        expect(errors).to_not include :email
        expect(errors).to include :contact
        expect(errors[:contact]).to eq [{
          email: "is too short (minimum is 2 characters)",
          phone: "can't be blank"
        }]
      end
    end

    context "and the validate option is set to false" do
      let(:person) { Test::Validation::PersonWithSegmentNone.new }

      it "does not validate the segment" do
        expect(contact.errors).to be_empty
      end
    end
  end

  context "when associations are present" do
    let(:data) {{ contact: {} }}
    let(:person) { Test::Validation::PersonWithAssociation.new(data) }

    it "validates the association" do
      expect(contact.errors).to_not be_empty
    end

    it "does :deep errors by default", :aggregate_failures do
      expect(errors).to_not include :email
      expect(errors).to include :contact
      expect(errors[:contact]).to eq [{
        email: "is too short (minimum is 2 characters)",
        phone: "can't be blank"
      }]
    end

    context "and the errors option is set to :shallow" do
      let(:person) { Test::Validation::PersonWithAssociationShallow.new(data) }

      it "specifies that the segment is invalid", :aggregate_failures do
        expect(errors).to_not include :email
        expect(errors).to include :contact
        expect(errors[:contact]).to eq ["is invalid"]
      end
    end

    context "and the errors option is set to :merge" do
      let(:person) { Test::Validation::PersonWithAssociationMerge.new(data) }

      it "includes all the errors from the segment", :aggregate_failures do
        expect(errors).to include :email
        expect(errors).to_not include :contact
      end
    end
  end
end
