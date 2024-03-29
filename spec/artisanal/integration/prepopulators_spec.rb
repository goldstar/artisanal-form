RSpec.describe "Prepopulators" do
  module Test::Prepopulators
    class Person
      include Artisanal::Form

      attribute :name, Dry::Types::Any
      attribute :age, Dry::Types['coercible.integer']
      attribute :email, Dry::Types::Any
    end

    class PersonWithoutPrepopulator
      include Artisanal::Form

      attribute :name, Dry::Types::Any
      attribute :age, Dry::Types['coercible.integer']
      attribute :email, Dry::Types::Any
    end

    class Person::Prepopulator
      attr_reader :form, :name, :options

      def initialize(form, name, options={})
        @form, @name, @options = form, name, options
      end

      def prepopulate!
        form.assign_attributes(
          name: name,
          age: options[:age],
          email: options[:email]
        )
      end
    end
  end

  let(:person) { Test::Prepopulators::Person.new }

  let(:prepopulate) do
    person.prepopulate!("John Smith", age: "40", email: "john@example.com")
  end

  it "assigns attributes to the form from the serialized prepopulator" do
    expect { prepopulate }.
      to change { person.name }.from(nil).to("John Smith").
      and change { person.age }.from(nil).to(40).
      and change { person.email }.from(nil).to("john@example.com")
  end

  context "when a prepopulator hasn't been defined" do
    let(:person) { Test::Prepopulators::PersonWithoutPrepopulator.new }

    it "uses the null prepopulator and does nothing" do
      expect { prepopulate }.to_not change { person.name }
    end
  end
end
