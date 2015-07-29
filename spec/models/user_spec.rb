require 'spec_helper'

describe User do #クラスを渡してクラスのテストをしている

  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }

  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }

  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }

  it { should be_valid }
  it { should_not be_admin }

  #参考
  # it "should respond to 'name'" do
  # 	expect(@user).to respond_to(:name)
  # end

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "名前が存在しない場合" do
  	before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "電子メールは存在しない場合" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "名前の長さの確認" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "電子メールの形式が無効な時" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]

      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end

    end
  end

  describe "電子メールの形式が有効な時" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "混在ケースと電子メールアドレス" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "すべて小文字として保存する必要があり" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe "電子メールアドレスが、すでに存在している時" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "パスワードが存在しない時" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "パスワードが一致しない時" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "パスワードが短すぎる" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end


  describe "認証メソッドの戻り値" do
  	before { @user.save }
 	  let(:found_user) { User.find_by(email: @user.email) }

 	 describe "有効なパスワードを持ちました" do
   		it { should eq found_user.authenticate(@user.password) }
  	end

	  describe "無効なパスワードを使用して、" do
	    let(:user_for_invalid_password) { found_user.authenticate("invalid") }

	    it { should_not eq user_for_invalid_password }
	    specify { expect(user_for_invalid_password).to be_false }
	  end
 end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "micropost associations" do

    before { @user.save }
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end

    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right microposts in the right order" do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "should destroy associated microposts" do
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty

      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
    end
  end
end

