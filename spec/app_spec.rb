RSpec.describe App do
  describe "GET /" do
    subject { get "/" }

    it { should be_ok }
  end

  describe "GET /play" do
    subject { get "/play" }

    it { should be_ok }
  end

  describe "POST /run" do
    subject do
      post "/run", { input: input }
      last_response
    end

    let(:input) do
      <<~RUBY
        Precure.delicious_party.title
      RUBY
    end

    let(:output) do
      <<~TEXT.strip
        > Precure.delicious_party.title
        #=> デリシャスパーティ♡プリキュア
      TEXT
    end

    it { should be_ok }

    it "run rubicure" do
      data = JSON.parse(subject.body)
      expect(data["output"]).to eq output
    end
  end

  describe ".run_script" do
    subject { App.run_script(code) }

    context "Precure.delicious_party.title" do
      let(:code) do
        <<~RUBY
          Precure.delicious_party.title
        RUBY
      end

      let(:output) do
        <<~TEXT.strip
          > Precure.delicious_party.title
          #=> デリシャスパーティ♡プリキュア
        TEXT
      end

      its([0]) { should eq output }
      its([1]) { should eq false }
    end

    context "Cure.peace.transform!" do
      let(:code) do
        <<~RUBY
          Cure.peace.transform!
        RUBY
      end

      let(:output) do
        <<~TEXT.strip
          > Cure.peace.transform!
          (レディ？)
          プリキュア・スマイルチャージ！
          (ゴー！ゴー！レッツ・ゴー！ピース！！)
          ピカピカピカリンジャンケンポン！ キュアピース！
          5つの光が導く未来！
          輝け！スマイルプリキュア！
          #=> キュアピース
        TEXT
      end

      its([0]) { should eq output }
      its([1]) { should eq false }
    end

    context "with error" do
      let(:code) do
        <<~RUBY
          aaaa
        RUBY
      end

      its([0]) { should be_start_with %q(NameError: undefined local variable or method 'aaaa' for an instance of Object) }
      its([1]) { should eq true }
    end
  end
end
