RSpec.describe Report::TransitionChecker do
  let(:report) { described_class.report(user_id_pepper: "pepper") }

  context "with no claims" do
    it "returns an empty report" do
      expect(report).to eq({ answer_sets: [], criteria_keys: [] })
    end
  end

  context "with claims" do
    it "finds all the claims" do
      ck1 = %i[key1 key2]
      ck2 = %i[key3]
      ck3 = %i[key4 key5 key6]

      t1 = Time.zone.local(2020, 1, 22, 10, 0, 0)
      t2 = Time.zone.local(2020, 1, 22, 11, 0, 0)
      t3 = Time.zone.local(2020, 1, 22, 12, 0, 0)

      create_claim("user1", :transition_checker_state, { criteria_keys: ck1, timestamp: t1.to_i, email_topic_slug: "slug1" })
      create_claim("user2", :transition_checker_state, { criteria_keys: ck2, timestamp: t2.to_i, email_topic_slug: "slug2" })
      create_claim("user3", :transition_checker_state, { criteria_keys: ck3, timestamp: t3.to_i, email_topic_slug: "slug3" })

      expect(report[:answer_sets].map { |a| a[:user_id] }.uniq.count).to eq(3)
      expect(report[:answer_sets].map { |a| a[:timestamp] }).to eq([t1, t2, t3])
      expect(report[:answer_sets].map { |a| a[:criteria] }).to eq([ck1, ck2, ck3])
      expect(report[:criteria_keys]).to eq(ck1 + ck2 + ck3)
    end

    it "only reports transition checker claims" do
      ck1 = %i[key1 key2]
      ck2 = %i[key3]

      t1 = Time.zone.local(2020, 1, 22, 10, 0, 0)
      t2 = Time.zone.local(2020, 1, 22, 11, 0, 0)

      create_claim("user1", :transition_checker_state, { criteria_keys: ck1, timestamp: t1.to_i })
      create_claim("user2", :email, { criteria_keys: ck2, timestamp: t2.to_i })

      expect(report[:answer_sets].map { |a| a[:user_id] }.uniq.count).to eq(1)
      expect(report[:answer_sets].map { |a| a[:timestamp] }).to eq([t1])
      expect(report[:answer_sets].map { |a| a[:criteria] }).to eq([ck1])
      expect(report[:criteria_keys]).to eq(ck1)
    end
  end

  def create_claim(subject_id, claim_name, value)
    FactoryBot.create(
      :claim,
      subject_identifier: subject_id,
      claim_identifier: Permissions.name_to_uuid(claim_name),
      claim_value: value,
    )
  end
end
