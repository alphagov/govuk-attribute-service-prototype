RSpec.describe "/healthcheck" do
  it "returns ok" do
    get healthcheck_path

    expect(JSON.parse(response.body)["status"]).to eq("ok")
  end
end
