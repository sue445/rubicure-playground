describe App do
  describe "GET /" do
    subject { get "/" }

    it { should be_ok }
  end

  describe "GET /play" do
    subject { get "/play" }

    it { should be_ok }
  end
end
