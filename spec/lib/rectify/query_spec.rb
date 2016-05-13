RSpec.describe Rectify::Query do
  context "when #query returns an ActiveRecord::Relation" do
    describe "#count" do
      it "returns the count of the records matched by #query" do
        User.create!(:first_name => "Andy", :age => 38)

        expect(AllUsers.new.count).to eq(1)
      end
    end

    describe "#first" do
      it "returns the first record matched by #query" do
        User.create!(:first_name => "Amber", :age => 10)
        User.create!(:first_name => "Megan", :age => 9)
        yongest = User.create!(:first_name => "Charlie", :age => 7)

        expect(AllUsers.new.first).to eq(yongest)
      end
    end

    describe "#each" do
      it "yields each record matched by #query" do
        a = User.create!(:first_name => "Amber", :age => 10)
        m = User.create!(:first_name => "Megan", :age => 9)

        expect { |b| AllUsers.new.each(&b) }.to yield_successive_args(m, a)
      end
    end

    describe "#exists?" do
      it "returns true if record matched by #query" do
        User.create!(:first_name => "Amber", :age => 10)

        expect(AllUsers.new).to be_exists
      end

      it "returns false if no records matched by #query" do
        expect(AllUsers.new).not_to be_exists
      end
    end

    describe "#none?" do
      it "returns false if record matched by #query" do
        User.create!(:first_name => "Amber", :age => 10)

        expect(AllUsers.new).not_to be_none
      end

      it "returns true if no records matched by #query" do
        expect(AllUsers.new).to be_none
      end
    end

    describe "#to_a" do
      it "returns the objects as an array" do
        a = User.create!(:first_name => "Amber", :age => 10)
        m = User.create!(:first_name => "Megan", :age => 9)

        expect(AllUsers.new.to_a).to match_array([a, m])
      end
    end

    describe "#map" do
      it "returns the mapped collection" do
        User.create!(:first_name => "Amber", :age => 10)
        User.create!(:first_name => "Megan", :age => 9)

        expect(AllUsers.new.map(&:age)).to match_array([10, 9])
      end
    end

    describe "#|" do
      it "returns the combination of two queries" do
        User.create!(:first_name => "Megan", :age => 9)
        User.create!(:first_name => "Fred", :age => 11, :active => false)
        andy = User.create!(:first_name => "Andy", :age => 38)

        active_users_over_10 = ActiveUsers.new | UsersOver.new(10)

        expect(active_users_over_10.count).to eq(1)
        expect(active_users_over_10.first).to eq(andy)
      end

      it "returns the combination of three queries" do
        User.create!(:first_name => "Megan", :age => 9)
        User.create!(:first_name => "Fred", :age => 11, :active => false)
        User.create!(:first_name => "George", :age => 40)
        andy = User.create!(:first_name => "Andy", :age => 38)

        active_users_over_10_with_name_starting_with_a = (
          ActiveUsers.new |
          UsersOver.new(10) |
          UsersWithNameStarting.new("A")
        )

        expect(active_users_over_10_with_name_starting_with_a.count).to eq(1)
        expect(active_users_over_10_with_name_starting_with_a.first).to eq(andy)
      end

      it "supports composition via constructor" do
        User.create!(:first_name => "Megan", :age => 21)

        expect(ScopedUsersOver.new(20, ActiveUsers.new).count).to eq(1)
      end
    end

    describe "#merge" do
      it "returns the combination of two queries" do
        User.create!(:first_name => "Megan", :age => 9)
        User.create!(:first_name => "Fred", :age => 11, :active => false)
        andy = User.create!(:first_name => "Andy", :age => 38)

        active_users_over_10 = ActiveUsers.new.merge(UsersOver.new(10))

        expect(active_users_over_10.count).to eq(1)
        expect(active_users_over_10.first).to eq(andy)
      end
    end

    describe ".merge" do
      context "when no queries are supplied" do
        it "returns a null query" do
          expect(described_class.merge).to be_a(Rectify::NullQuery)
        end
      end

      context "when one query is supplied" do
        it "returns the query" do
          query = ActiveUsers.new

          expect(described_class.merge(query)).to eq(query)
        end
      end

      context "when more than one query are supplied" do
        it "returns the combination of multiple queries" do
          User.create!(:first_name => "Megan", :age => 9)
          User.create!(:first_name => "Fred", :age => 11, :active => false)
          User.create!(:first_name => "Grandad", :age => 65)
          andy = User.create!(:first_name => "Andy", :age => 38)

          active_users_between_10_and_45 = described_class.merge(
            ActiveUsers.new,
            UsersOver.new(10),
            UsersUnder.new(45)
          )

          expect(active_users_between_10_and_45.count).to eq(1)
          expect(active_users_between_10_and_45.first).to eq(andy)
        end
      end
    end
  end

  context "when #query returns an array" do
    describe "#count" do
      it "returns the count of the records matched by #query" do
        User.create!(:first_name => "Amber", :age => 10)
        User.create!(:first_name => "Andy", :age => 38)

        expect(UsersOverUsingSql.new(20).count).to eq(1)
      end
    end

    describe "#first" do
      it "returns the first record matched by #query" do
        User.create!(:first_name => "Amber", :age => 10)
        User.create!(:first_name => "Megan", :age => 9)
        yongest = User.create!(:first_name => "Charlie", :age => 7)

        expect(UsersOverUsingSql.new(0).first).to eq(yongest)
      end
    end

    describe "#each" do
      it "yields each record matched by #query" do
        a = User.create!(:first_name => "Amber", :age => 10)
        m = User.create!(:first_name => "Megan", :age => 9)

        expect do |b|
          UsersOverUsingSql.new(0).each(&b)
        end.to yield_successive_args(m, a)
      end
    end

    describe "#exists?" do
      it "returns true if record matched by #query" do
        User.create!(:first_name => "Amber", :age => 10)

        expect(UsersOverUsingSql.new(0)).to be_exists
      end

      it "returns false if no records matched by #query" do
        expect(UsersOverUsingSql.new(0)).not_to be_exists
      end
    end

    describe "#none?" do
      it "returns false if record matched by #query" do
        User.create!(:first_name => "Amber", :age => 10)

        expect(UsersOverUsingSql.new(0)).not_to be_none
      end

      it "returns true if no records matched by #query" do
        expect(UsersOverUsingSql.new(0)).to be_none
      end
    end

    describe "#to_a" do
      it "returns the objects as an array" do
        a = User.create!(:first_name => "Amber", :age => 10)
        m = User.create!(:first_name => "Megan", :age => 9)

        expect(UsersOverUsingSql.new(0).to_a).to match_array([a, m])
      end
    end

    describe "#map" do
      it "returns the mapped collection" do
        User.create!(:first_name => "Amber", :age => 10)
        User.create!(:first_name => "Megan", :age => 9)

        expect(UsersOverUsingSql.new(0).map(&:age)).to match_array([10, 9])
      end
    end

    it "caches the results so subsequent calls don't hit the database" do
      query = UsersOverUsingSql.new(0)

      expect do
        query.count
        query.first
        query.each {}
        query.exists?
        query.none?
        query.to_a
      end.to make_database_queries_of(1)
    end

    describe "#|" do
      it "raises an exeception if a sql query is merged with a relation" do
        expect do
          ActiveUsers.new | UsersOverUsingSql.new(0)
        end.to raise_error(Rectify::UnableToComposeQueries)
      end

      it "joins the result arrays of two sql queries" do
        amber = User.create!(:first_name => "Amber", :age => 10)
        andy  = User.create!(:first_name => "Andy", :age => 38)

        users = UsersOverUsingSql.new(20) | UsersOverUsingSql.new(5)

        expect(users.count).to eq(2)
        expect(users.to_a).to match_array([andy, amber])
      end
    end

    describe "#merge" do
      it "raises an exeception if a sql query is merged with a relation" do
        expect do
          ActiveUsers.new.merge(UsersOverUsingSql.new(0))
        end.to raise_error(Rectify::UnableToComposeQueries)
      end

      it "joins the result arrays of two sql queries" do
        amber = User.create!(:first_name => "Amber", :age => 10)
        andy  = User.create!(:first_name => "Andy", :age => 38)

        users = UsersOverUsingSql.new(20).merge(UsersOverUsingSql.new(5))

        expect(users.count).to eq(2)
        expect(users.to_a).to match_array([andy, amber])
      end
    end
  end

  describe "stubbing query methods" do
    it "returns the provided (single) record" do
      stub_query(AllUsers, :results => User.new)

      expect(AllUsers.new.count).to eq(1)
    end

    it "returns the provided (multiple) records" do
      stub_query(AllUsers, :results => [User.new, User.new])

      expect(AllUsers.new.count).to eq(2)
    end

    it "supports #exists?" do
      stub_query(AllUsers, :results => User.new)
      expect(AllUsers.new).to be_exists

      stub_query(AllUsers, :results => [])
      expect(AllUsers.new).not_to be_exists
    end

    it "doesn't make any database queries" do
      stub_query(AllUsers, :results => [User.new, User.new])

      expect { AllUsers.new.count }.to make_database_queries_of(0)
    end
  end
end
