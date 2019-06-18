RSpec.describe "Context registry" do
  let(:ns) {
    Module.new.tap do |mod|
      module mod::Examples
        class Address
          include Artisanal::Form

          def person_name
            context["name"]
          end

          def person_age
            context["memoized.age"]
          end

          def person_memoized_age
            context["memoized.age"]
          end

          def person_nonmemoized_age
            context["nonmemoized.age"]
          end
        end

        class Profile
          include Artisanal::Form

          attribute :address, Address

          register_context "memoized.age", :random_age
          register_context "nonmemoized.age", :random_age, memoize: false

          protected

          def random_age
            Time.now.to_f
          end
        end

        class Person
          include Artisanal::Form

          attribute :profile, Profile

          register_context("name") { "John Smith" }
        end
      end
    end
  }

  let(:data) {{ profile: { address: {} } }}
  
  let(:person) { ns::Examples::Person.new(data) }
  let(:address) { person.profile.address }

  it "makes values available to associated models" do
    expect(address.person_name).to eq "John Smith"
  end

  it "lazily evaluates the values" do
    expect(Time.now.to_f).to be < address.person_age
  end

  it "memoizes the values by default" do
    expect(address.person_memoized_age).to eq address.person_memoized_age
  end

  context 'when "memoize: false" is supplied' do
    it "doesn't memoize the value" do
      expect(address.person_nonmemoized_age).to_not eq address.person_nonmemoized_age
    end
  end
end
