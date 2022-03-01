require "spec_helper"

describe BazaModels::Query::Pagination do
  include DatabaseHelper

  before do
    User.transaction do
      100.times { |n| User.create! email: "user#{n}@example.com" }
    end
  end

  describe "#out_of_bounds?" do
    it "returns the right values under the right conditions" do
      collection = User.all.page(5)
      expect(collection.out_of_bounds?).to be true

      collection = User.all.page(4)
      expect(collection.out_of_bounds?).to be false
    end
  end

  describe "#paginated?" do
    it "returns the right values under the right conditions" do
      collection = User.all
      expect(collection.paginated?).to be false

      collection = collection.page(3)
      expect(collection.paginated?).to be true
    end
  end

  describe "#per #total_pages" do
    it "sets a custom per_page" do
      collection = User
        .all
        .per_page(40)

      expect(collection.per_page).to eq 40
      expect(collection.per).to eq 40
      expect(collection.to_a.length).to eq 40
      expect(collection.total_pages).to eq 3
    end
  end

  describe "#page" do
    it "sets the page and returns the correct numbers" do
      collection = User
        .all
        .page(2)
        .per_page(60)

      expect(collection.page).to eq 2
      expect(collection.to_a.length).to eq 40
      expect(collection.page(1).to_a.length).to eq 60
    end
  end

  describe "#total_entries" do
    it "returns the correct number" do
      collection = User.where(email: "user5@example.com")
      expect(collection.total_entries).to eq 100
    end
  end
end
