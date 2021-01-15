RSpec.describe Report::TransitionChecker do
  let(:report) { described_class.new(user_id_pepper: "pepper").all }

  context "with no claims" do
    it "returns an empty report" do
      expect(report).to eq([])
    end
  end

  context "with claims" do
    it "#in_batches" do
      create_claim("user1", :transition_checker_state, { criteria_keys: %i[key1 key2], timestamp: Time.zone.local(2020, 1, 22, 10, 0, 0).to_i, email_topic_slug: "slug1" })
      create_claim("user2", :transition_checker_state, { criteria_keys: %i[key3], timestamp: Time.zone.local(2020, 1, 22, 11, 0, 0).to_i, email_topic_slug: "slug2" })
      create_claim("user3", :transition_checker_state, { criteria_keys: %i[key4 key5 key6], timestamp: Time.zone.local(2020, 1, 22, 12, 0, 0).to_i, email_topic_slug: "slug3" })

      batched_report = []

      described_class.new(user_id_pepper: "pepper").in_batches(batch_size: 1) do |rows|
        expect(rows.length).to eq(1)
        batched_report.concat(rows)
      end

      expect(batched_report).to eq(report)
    end

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

      expect(report.length).to eq(3)
      expect(report.map { |a| a[:user_id] }.uniq.count).to eq(3)
      expect(report.map { |a| a[:timestamp] }).to eq([t1, t2, t3])

      (ck1 + ck2 + ck3).each do |k|
        expect(report[0][k]).to eq(ck1.include?(k) ? true : nil)
        expect(report[1][k]).to eq(ck2.include?(k) ? true : nil)
        expect(report[2][k]).to eq(ck3.include?(k) ? true : nil)
      end
    end

    it "only reports transition checker claims" do
      ck1 = %i[key1 key2]
      ck2 = %i[key3]

      t1 = Time.zone.local(2020, 1, 22, 10, 0, 0)
      t2 = Time.zone.local(2020, 1, 22, 11, 0, 0)

      create_claim("user1", :transition_checker_state, { criteria_keys: ck1, timestamp: t1.to_i })
      create_claim("user2", :email, { criteria_keys: ck2, timestamp: t2.to_i })

      expect(report.length).to eq(1)
      expect(report.map { |a| a[:user_id] }.uniq.count).to eq(1)
      expect(report.map { |a| a[:timestamp] }).to eq([t1])

      (ck1 + ck2).each do |k|
        expect(report[0][k]).to eq(ck1.include?(k) ? true : nil)
      end
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
